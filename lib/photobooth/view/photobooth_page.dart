import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/landing/widgets/landing_background.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/photobooth/view/loading_body.dart';
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
      create: (_) => PhotoboothBloc(),
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

class _PhotoboothViewState extends State<PhotoboothView> {
  CameraController? _controller;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int seed = Random().nextInt(1<<31);
  bool get _isCameraAvailable => _controller?.value.isInitialized ?? false;

  Future<void> _play() async {
    if (!_isCameraAvailable) return;
    return _controller?.resumePreview();
  }

  Future<void> _stop() async {
    if (!_isCameraAvailable) return;
    return _controller?.pausePreview();
  }

  @override
  void initState() {
    super.initState();
    _initializeCameraController(null);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }
  List<CameraDescription>? _cameras;
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
  Future<void> _initializeCameraController(
      CameraDescription? cameraDescription) async {
      try {

        if(cameraDescription == null) {
          _cameras ??= await availableCameras();
          if(_cameras == null || _cameras!.isEmpty) {
            return;
          }
          final d =           _cameras!.first;
          cameraDescription = 
          CameraDescription(name: d.name, lensDirection: d.lensDirection, sensorOrientation: 90);
        }
      final cameraController = CameraController(
      cameraDescription!,
      config.CameraResolution,
      enableAudio: false,
      imageFormatGroup: config.CameraImageFormat,
    );

    _controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...<Future<Object?>>[],
        // cameraController
        //     .getMaxZoomLevel()
        //     .then((double value) => _maxAvailableZoom = value),
        // cameraController
        //     .getMinZoomLevel()
        //     .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
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

    if (mounted) {
      setState(() {});
    }
  }
  
  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Future<void> _onSnapPressed() async {
    final navigator = Navigator.of(context);
    final photoboothBloc = context.read<PhotoboothBloc>();
    if(_controller == null)
    {
      showInSnackBar("Unexpected error, missing controller");
      return;
    }
    final size = _controller?.value.previewSize;
    final aspectRatio = _controller?.value.aspectRatio;
    final picture = await _controller?.takePicture();
    if(picture == null) {
      showInSnackBar("Error taking picture, try again");
      return;
    }
    photoboothBloc.add(PhotoCaptured(aspectRatio: aspectRatio!, image:
      CameraImageBlob(data: picture.path, width:size?.width.toInt()??1, height: size?.height.toInt()??1)
      ));
    final stickersPage = StickersPage.route();
    await _stop();
    unawaited(navigator.pushReplacement(stickersPage));
  }

  @override
  Widget build(BuildContext context) {
    if(_controller == null) {
      return const LoadingBody();
    }
    return Scaffold(
      body: PhotoboothBackgroundStack(
        child: Camera(
          controller: _controller!,
          placeholder: (_) => const SizedBox(),
          preview: (context, preview) => PhotoboothPreview(
            preview: preview,
            onSnapPressed: () => _onSnapPressed(),
            seed: seed
          ),
          error: (context, error) => PhotoboothError(error: error),
        ),
      ),
    );
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
      children: [
        const PhotoboothBackground(),
        Center(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: ColoredBox(
              color: PhotoboothColors.black,
              child: child,
            ),
          ),
        ),
      ],
      );
    });
  }
}
