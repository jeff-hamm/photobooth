import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:io_photobooth/app/router.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/common/theme.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/main.dart';
import 'package:logger_screen/logger_screen.dart';
import 'package:provider/provider.dart';

import '../common/photos_repository.dart';
import '../config.dart' as config;

class App extends StatelessWidget {
  const App({
  //  required this.authenticationRepository,
    required this.photosRepository,
    required this.cameraService,
    super.key,
  });
//  final AuthenticationRepository authenticationRepository;
  final PhotosRepository photosRepository;
  final CameraService cameraService;
  @override
  Widget build(BuildContext context) {

    return MultiProvider(providers: 
      [
        RepositoryProvider.value(value: photosRepository),
        ChangeNotifierProvider.value(value: cameraService)
      ],
      child: AnimatedFadeIn(
        child: ResponsiveLayoutBuilder(
          small: (_, __) => _App(theme: PhotoboothTheme.small),
          medium: (_, __) => _App(theme: PhotoboothTheme.medium),
          large: (_, __) => _App(theme: PhotoboothTheme.standard),
        ),
      ),
    );
  }
}

  final appRouter = AppRouter();

class _App extends StatelessWidget {
  _App({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: config.SITE_NAME,
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter.config(),
      builder: (context, widget) {
//        Widget? error;
        if (widget is Scaffold || widget is Navigator) {
          errorHandler.onError('Builder error? ${widget?.runtimeType}');
//          error = const Scaffold(body: Center(child: Text('...rendering error...')));
        }
        ErrorWidget.builder = (details) {
          final Object exception = details.exception;
          return ErrorWidget.withDetails(message: 
            '${details.exception} - ${details.stack} - ${details.summary}',
           error: exception is FlutterError ? exception : null);
        };
        if (widget != null) return widget;
        throw StateError('widget is null');
      },
    //   home: Scaffold(
    //     body: const LandingPage()
    // )
    );
  }
}
