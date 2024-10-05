// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/app/app.dart';
import 'package:io_photobooth/app/app_bloc_observer.dart';
import 'package:io_photobooth/app/camera_observer.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/landing/loading_indicator_io.dart'
    if (dart.library.html) 'landing/loading_indicator_web.dart';
import 'package:logger/logger.dart' show Level, LogEvent;
import 'package:logger_screen/logger_screen.dart';

import 'common/butts_repository.dart';

final DisplayedErrorsHandler errorHandler = DisplayedErrorsHandler();
void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      Bloc.observer = AppBlocObserver();
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );

      // final authenticationRepository = AuthenticationRepository(
      //   firebaseAuth: FirebaseAuth.instance,
      // );

      // await SystemChrome.setPreferredOrientations(
      //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

      final photosRepository = ButtsPhotosRepository();

      final cameraService = CameraService();
//      final cameraObserver = AppCameraObserver(cameraService);

      //    cameraService.addListener(cameraObserver.listener);

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
      await errorHandler.initialize();
      FlutterError.onError = (details) {
        // print(details.exceptionAsString());
        // print(details.stack);
        FlutterError.presentError(details);
        errorHandler.onError(details);
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        errorHandler.onErrorStack(error, stackTrace);
        print(error);
        print(stackTrace);
        return true;
      };
      runApp(App(
//        authenticationRepository: authenticationRepository,
          photosRepository: photosRepository,
          cameraService: cameraService));
    },
    (error, stackTrace) {
      errorHandler.onErrorStack(error, stackTrace);
      print(error);
      print(stackTrace);
    },
  );

  SchedulerBinding.instance.addPostFrameCallback(
    (_) => removeLoadingIndicator(),
  );
}

class DisplayedErrorsHandler {
  final logger = LoggerScreenPrinter(
//    fileName: "logs" + DateTime.now().toString() + ".log",

      );
  Future<void> initialize() async {
    await logger.initialize();
    await logger.applyFilter(const Filter(search: ''));
  }

  void onError(dynamic details) {
    print(details);
    logger.log(LogEvent(Level.error, details));
  }

  void onLog(Level level, dynamic message) {
    log(message.toString());
    logger.log(LogEvent(level, message));
  }

  void onDebug(dynamic message) {
    log(message.toString());
    logger.log(LogEvent(Level.debug, message));
  }

  void onErrorStack(Object error, StackTrace stack) {
    logger.log(LogEvent(Level.error, error.toString()));
    logger.log(LogEvent(Level.error, stack.toString()));
    // debugPrint('onError');
    // debugPrint(error.toString());
    // debugPrint(stack.toString());
  }
}
