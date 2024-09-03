// ignore_for_file: avoid_print
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/app/app.dart';
import 'package:io_photobooth/app/app_bloc_observer.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/landing/loading_indicator_io.dart'
if (dart.library.html) 'landing/loading_indicator_web.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import 'common/butts_repository.dart';
import 'package:camera/camera.dart';
void main() async {
  await runZonedGuarded(
    () async { 
      WidgetsFlutterBinding.ensureInitialized();
      Bloc.observer = AppBlocObserver();
  // FlutterError.onError = (details) {
  //   print(details.exceptionAsString());
  //   print(details.stack);
  // };
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // final authenticationRepository = AuthenticationRepository(
  //   firebaseAuth: FirebaseAuth.instance,
  // );

  final photosRepository = ButtsPhotosRepository();
  final cameraService = CameraService();

  // unawaited(
  //   authenticationRepository.signInAnonymously(),
  // );
  
  unawaited(
    Future.wait([
      Flame.images.load('android_spritesheet.png'),
      Flame.images.load('dash_spritesheet.png'),
      Flame.images.load('dino_spritesheet.png'),
      Flame.images.load('sparky_spritesheet.png'),
      Flame.images.load('photo_frame_spritesheet_landscape.jpg'),
      Flame.images.load('photo_frame_spritesheet_portrait.png'),
      Flame.images.load('photo_indicator_spritesheet.png'),
      Flame.images.load('train_smooch.jpg'),
      Flame.images.load('train_smooch2.jpg'),

    ]),
  );
  runApp(
      App(
//        authenticationRepository: authenticationRepository,
        photosRepository: photosRepository,
        cameraService: cameraService
      ));
    },
    (error, stackTrace) {
      print(error);
      print(stackTrace);
    },
  );

  SchedulerBinding.instance.addPostFrameCallback(
    (_) => removeLoadingIndicator(),
  );
}
