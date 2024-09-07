import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/stickers/stickers.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import '../../config.dart' as config;
import './camera.dart';

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class PhotoboothPage extends StatelessWidget {
  const PhotoboothPage({super.key});

  static Route<void> route() {
    return AppPageRoute(builder: (_) => const PhotoboothPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhotoboothBloc(null, isPrimaryClient: Uri.base.queryParameters['primary'] == '1'),
      child: Navigator(
        onGenerateRoute: (_) => AppPageRoute(
          builder: (_) => const PhotoboothView(),
        ),
      ),
    );
  }
}

class PhotoboothView extends StatefulWidget {
  const PhotoboothView({super.key});

  @override
  State<PhotoboothView> createState() => _PhotoboothViewState();
}

class _PhotoboothViewState extends State<PhotoboothView> with WidgetsBindingObserver {
  int seed = Random().nextInt(1<<31);
  var _hasSplashShown = false;
  @override
  void initState() {
    super.initState();
    final service =context.read<CameraService>(); 
    if(service.value.cameraError != null) {
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
          showInSnackBar('You have denied camera access. Please enable it and refresh the page.'); 
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.'); break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.'); break;
        default:
          _showCameraException(e);
        break;
      }

  }
  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message),
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

  Future<void> _onSnapPressed() async {
    final navigator = Navigator.of(context);
    final photoboothBloc = context.read<PhotoboothBloc>();
    final cameraService = context.read<CameraService>();
    if(!cameraService.isCameraAvailable)
    {
      showInSnackBar("Unexpected error, missing controller");
      return;
    }
    final value = cameraService.value.controllerValue;
    final size = value.previewSize;
    final aspectRatio = value.aspectRatio;
    final picture = await cameraService.takePicture();
    if(picture == null) {
      showInSnackBar("Error taking picture, try again");
      return;
    }
    photoboothBloc.add(PhotoCaptured(aspectRatio: aspectRatio!, image:
      CameraImageBlob(data: picture.path, width:size?.width.toInt()??1, height: size?.height.toInt()??1)
      ));
    final stickersPage = StickersPage.route();
    cameraService.removeListener(_onCameraServiceChanged);
//    await cameraService.stop();
    unawaited(navigator.pushReplacement(stickersPage));
//    await cameraService.play();
  }


  @override
  Widget build(BuildContext context) {
    final service = context.watch<CameraService>();
    return  
    Scaffold(
      // body: AppAnimatedCrossFade(crossFadeState: service.isCameraAvailable && _hasSplashShown ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      // firstChild: const LoadingBody(),

      // secondChild:
    body: PhotoboothBackgroundStack(
          child: Camera(
            placeholder: (_) => const SizedBox(),
            preview: (context, preview) => PhotoboothPreview(
              preview: preview,
              onSnapPressed: () => _onSnapPressed(),
              onFlipPressed: () => _onFlipPressed(),
              seed: seed
            ),
            error: (context, error) => PhotoboothError(error: error),
          ),
        )
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
    return OrientationBuilder(builder: (c, orientation) {
      
      final bloc = c.read<PhotoboothBloc?>();
        var aspectRatio = bloc?.state.aspectRatio;
        final newRatio = ( orientation == Orientation.portrait
        ? PhotoboothAspectRatio.portrait
        : PhotoboothAspectRatio.landscape);
        if(aspectRatio == null || aspectRatio != newRatio) {
          bloc?.add(OrientationChanged(orientation: orientation));
          aspectRatio = newRatio;
        }
      return Stack(
        fit: StackFit.expand,
      children: [
        const PhotoboothBackground(),
        FittedBox(
    fit: BoxFit.fitWidth,  // This ensures the width is fully covered without stretching.
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: child,
    ),
  ),

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
