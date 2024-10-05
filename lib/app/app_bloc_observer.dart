import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:io_photobooth/main.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    final message = 'onTransition(${bloc.runtimeType}, $transition)';
    // log(message);
    // errorHandler.onDebug(message);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    final message = 'onEvent(${bloc.runtimeType}, $event)';
    errorHandler.onDebug(message);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    final message = 'onError(${bloc.runtimeType}, $error, $stackTrace)';
    log(message);
    errorHandler.onError(message);
  }
}
