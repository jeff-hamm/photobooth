import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import '../common/photos_repository.dart';
import '../config.dart' as config;
import '../landing/view/landing_page.dart';

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

class _App extends StatelessWidget {
  const _App({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.SITE_NAME,
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: const LandingPage()
    ));
  }
}
