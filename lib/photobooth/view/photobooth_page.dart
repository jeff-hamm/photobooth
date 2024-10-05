import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/app/router.gr.dart';
import 'package:io_photobooth/common/buttons/retake_row.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/common/photos_repository.dart';
import 'package:io_photobooth/common/theme.dart';
import 'package:io_photobooth/common/utils/logger_screen_wrapper.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/main.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/common/models/ImagePath.dart';
import 'package:logger_screen/logger_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import './camera.dart';

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

//
// class PhotoBlocWrapper extends AutoRouteWrapper {
//   @override
//   Widget wrappedRoute(BuildContext context) {
//     return BlocProvider(create: (ctx) => PhotoboothBloc(null, isPrimaryClient: Uri.base.queryParameters['primary'] == '1'),
//     child: const PhotoboothPage());
//   }
// }
@RoutePage()
class PhotoboothPage extends StatelessWidget implements AutoRouteWrapper {
  final bool isLocked;
  final bool isDebug;

  const PhotoboothPage({super.key, this.isLocked = false, bool? isDebug})
      : isDebug = isDebug ?? kDebugMode;

  static Route<void> route() {
    return AppPageRoute(builder: (_) => const PhotoboothPage());
  }
  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
        create: (ctx) => PhotoboothBloc(null,
            photosRepository: context.read<PhotosRepository>(),
            isLockedClient: isLocked),
        child: this);
  }

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
    //  BlocProvider(
    //   create: (_) => PhotoboothBloc(null, isPrimaryClient: Uri.base.queryParameters['primary'] == '1'),
    //   child: Navigator(
    //     onGenerateRoute: (_) => AppPageRoute(
    //       builder: (_) => ,
    //     ),
    //   ),
    // );
  }
}

@RoutePage(name: "PhotobothViewRoute")
class PhotoboothView extends StatefulWidget {
  const PhotoboothView({super.key});

  @override
  State<PhotoboothView> createState() => _PhotoboothViewState();
}

class _PhotoboothViewState extends State<PhotoboothView>
    with WidgetsBindingObserver {
  int seed = Random().nextInt(1 << 31);
  var _hasSplashShown = false;
  @override
  void initState() {
    super.initState();
    final service = context.read<CameraService>();
    if (service.value.cameraError != null) {
      displayCameraError(service.value.cameraError!);
    }
    service.addListener(_onCameraServiceChanged);
    unawaited(service.initState());
// //    unawaited(service.initState());
//     timer = Timer(const Duration(seconds: 2), () async {
//       await service.initState();
//       setState(()  {
//         _hasSplashShown = true;
//       });
//     });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<CameraService>().updateLifecycle(state);
  }

  void displayCameraError(CameraException e) {
    switch (e.code) {
      case 'CameraAccessDenied':
        showInSnackBar(
            'You have denied camera access. Please enable it and refresh the page.');
        break;
      case 'CameraAccessDeniedWithoutPrompt':
        // iOS only
        showInSnackBar('Please go to Settings app to enable camera access.');
        break;
      case 'CameraAccessRestricted':
        // iOS only
        showInSnackBar('Camera access is restricted.');
        break;
      default:
        _showCameraException(e);
        break;
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Reload',
        onPressed: () {
          setState(() {});
        },
      ),
    ));
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Future<void> _onFlipPressed() async {
    await context.read<CameraService>().flipCamera();
  }

  void _onPhotosComplete() {
    final cameraService = context.read<CameraService>()
      ..removeListener(_onCameraServiceChanged);
    final photoboothBloc = context.read<PhotoboothBloc>();
    Future<void> navToPusher() async {
      await context.router.replace(PickerRoute(
          images: photoboothBloc.state.images
              .map((m) => ImagePath.from(m))
              .followedBy(photoboothBloc.state.aiImage)
              .toList()));
      //await cameraService.disposeController();
    }

    unawaited(navToPusher());
//    unawaited(context.router.replace(const StickersRoute()));
  }

  Future<void> _onTakePhoto() async {
    final cameraService = context.read<CameraService>();
    final photoboothBloc = context.read<PhotoboothBloc>();
    if (!cameraService.isCameraAvailable) {
      showInSnackBar("Unexpected error, missing controller");
      return;
    }
    final value = cameraService.value.controllerValue;
    final aspectRatio = value.aspectRatio;
    final picture = await cameraService.takePicture();
    if (picture == null) {
      showInSnackBar("Error taking picture, try again");
      return;
    }
    photoboothBloc
        .add(PhotoCaptured(aspectRatio: aspectRatio!, image: picture));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  late final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    final service = context.watch<CameraService>();
    return Scaffold(
        // body: AppAnimatedCrossFade(crossFadeState: service.isCameraAvailable && _hasSplashShown ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        // firstChild: const LoadingBody(),

        // secondChild:
        body: SmartRefresher(
            enablePullDown: true,
            controller: _refreshController,
            child: PhotoboothBackgroundStack(
              child: Camera(
                placeholder: (_) => const ColoredBox(color: Colors.black),
                preview: (context, preview) => PhotoboothPreview(
                    preview: preview,
                    onTakePhoto: _onTakePhoto,
                    onFlipPressed: _onFlipPressed,
                    onPhotosComplete: _onPhotosComplete,
//              onShutterPressed: _onShutterPressed,
                    seed: seed),
                error: (context, error) => PhotoboothError(error: error),
              ),
            ))
//      )
        );
  }

  void _onCameraServiceChanged() {
    if (mounted) {
      setState(() {});
      final error = context.read<CameraService>().value.cameraError;
      if (error != null) {
        _showCameraException(error);
      }
    }
  }
}

class PhotoboothBackgroundStack extends StatelessWidget {
  const PhotoboothBackgroundStack({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectBuilder(builder: (c, orientation, newRatio, isNew) {
      final bloc = c.read<PhotoboothBloc?>();
      final cameraService = c.read<CameraService>();
      if (isNew) {
        bloc?.add(OrientationChanged(orientation: orientation));
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          const PhotoboothBackground(),
          child,
          // FittedBox(
          //   fit: BoxFit
          //       .fitWidth, // This ensures the width is fully covered without stretching.
          //   child: SizedBox(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //     child: child,
          //   ),
          // ),
          //const ActionsRow(retakeButton: false,)

          // Center(
          //   child: AspectRatio(
          //     aspectRatio: aspectRatio,
          //     child: ColoredBox(
          //       color: PhotoboothColors.black,
          //       child: child,
          //     ),
          //   ),
          // ),
        ],
      );
    });
  }
}
