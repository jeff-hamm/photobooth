import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_photobooth/app/app.dart';
import 'package:io_photobooth/common/camera_service.dart';
import 'package:io_photobooth/landing/landing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import 'package:io_photobooth/common/photos_repository.dart';


import 'helpers/helpers.dart';

class MockPhotosRepository extends Mock implements PhotosRepository {}
class MockCameraService extends Mock implements CameraService {}

void main() {
  group('App', () {
    testWidgets('uses default theme on large devices', (tester) async {
      tester.setDisplaySize(const Size(PhotoboothBreakpoints.large, 1000));
      await tester.pumpWidget(
        App(
          photosRepository: MockPhotosRepository(),
          cameraService: MockCameraService(),
        ),
      );
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        materialApp.theme!.textTheme.displayLarge!.fontSize,
        equals(PhotoboothTheme.standard.textTheme.displayLarge!.fontSize),
      );
    });

    testWidgets('uses small theme on small devices', (tester) async {
      tester.setDisplaySize(const Size(PhotoboothBreakpoints.small, 500));
      await tester.pumpWidget(
        App(
          photosRepository: MockPhotosRepository(),
          cameraService: MockCameraService(),
        ),
      );
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        materialApp.theme!.textTheme.displayLarge!.fontSize,
        equals(PhotoboothTheme.small.textTheme.displayLarge!.fontSize),
      );
    });

    testWidgets('renders LandingPage', (tester) async {
      await tester.pumpWidget(
        App(
          photosRepository: MockPhotosRepository(),
          cameraService: MockCameraService(),
        ),
      );
      expect(find.byType(LandingPage), findsOneWidget);
    });
  });
}
