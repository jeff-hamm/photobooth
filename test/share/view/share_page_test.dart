// ignore_for_file: prefer_const_constructors
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_photobooth/common/butts_repository.dart';
import 'package:io_photobooth/common/photos_repository.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/external_links/external_links.dart';
import 'package:io_photobooth/footer/footer.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../helpers/helpers.dart';

class FakePhotoboothEvent extends Fake implements PhotoboothEvent {}

class FakePhotoboothState extends Fake implements PhotoboothState {}

class MockPhotoboothBloc extends MockBloc<PhotoboothEvent, PhotoboothState>
    implements PhotoboothBloc {}

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

class MockPhotosRepository extends Mock implements ButtsPhotosRepository {}

class MockXFile extends Mock implements XFile {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const width = 1;
  const height = 1;
  const data = '';
  const image = CameraImageBlob(width: width, height: height, data: data);

  late PhotosRepository photosRepository;
  late PhotoboothBloc photoboothBloc;
  late ShareBloc shareBloc;
  late XFile file;
  late UrlLauncherPlatform originalUrlLauncher;

  setUpAll(() {
    registerFallbackValue(FakePhotoboothEvent());
    registerFallbackValue(FakePhotoboothState());

    registerFallbackValue(FakeShareEvent());
    registerFallbackValue(FakeShareState());

    registerFallbackValue(LaunchOptions());
  });

  setUp(() {
    file = MockXFile();
    photosRepository = MockPhotosRepository();
    when(
      () => photosRepository.composite(
        width: width,
        height: height,
        data: data,
        layers: [],
        aspectRatio: any(named: 'aspectRatio'),
      ),
    ).thenAnswer((_) async => Uint8List.fromList([]));
    photoboothBloc = MockPhotoboothBloc();
    when(() => photoboothBloc.state).thenReturn(PhotoboothState(false, mostRecentImage: image));

    shareBloc = MockShareBloc();
    whenListen(
      shareBloc,
      Stream.fromIterable([ShareState()]),
      initialState: ShareState(),
    );

    originalUrlLauncher = UrlLauncherPlatform.instance;
  });

  tearDown(() {
    UrlLauncherPlatform.instance = originalUrlLauncher;
  });

  group('SharePage', () {
    test('is routable', () {
      expect(SharePage.route(), isA<MaterialPageRoute<void>>());
    });

    testWidgets('renders a ShareView', (tester) async {
      await tester.pumpApp(
        SharePage(),
        photosRepository: photosRepository,
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(ShareView), findsOneWidget);
    });
  });

  group('ShareView', () {
    testWidgets('displays a ShareBackground', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(ShareBackground), findsOneWidget);
    });

    testWidgets('displays a ShareBody', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(ShareBody), findsOneWidget);
    });


    testWidgets('displays a ShareRetakeButton', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(
        find.byKey(const Key('sharePage_retake_appTooltipButton')),
        findsOneWidget,
      );
    });

    testWidgets('displays a ShareProgressOverlay', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(ShareProgressOverlay), findsOneWidget);
    });
  });

  group('ShareBody', () {
    setUp(() {
      when(() => shareBloc.state).thenReturn(
        ShareState(
          compositeStatus: ShareStatus.success,
          bytes: Uint8List(0),
          file: file,
        ),
      );
    });

    testWidgets('renders', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ShareBody()),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(ShareBody), findsOneWidget);
    });

    testWidgets('displays a AnimatedPhotoIndicator', (tester) async {
      tester.setDisplaySize(Size(PhotoboothBreakpoints.medium, 800));
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(AnimatedPhotoIndicator), findsOneWidget);
    });

    testWidgets('displays a AnimatedPhotoboothPhoto', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(AnimatedPhotoboothPhoto), findsOneWidget);
    });

    testWidgets('displays a ShareHeading', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );

      expect(
        find.byType(ShareHeading),
        findsOneWidget,
      );
    });

    testWidgets(
        'displays a ShareSuccessHeading '
        'when uploadStatus is success', (tester) async {
      when(() => shareBloc.state).thenReturn(
        ShareState(
          compositeStatus: ShareStatus.success,
          uploadStatus: ShareStatus.success,
          file: file,
        ),
      );
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );

      expect(
        find.byType(ShareSuccessHeading),
        findsOneWidget,
      );
    });

    testWidgets(
        'displays a ShareErrorHeading '
        'when compositeStatus is failure', (tester) async {
      when(() => shareBloc.state).thenReturn(
        ShareState(
          compositeStatus: ShareStatus.failure,
          file: file,
        ),
      );
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );

      expect(
        find.byType(ShareErrorHeading),
        findsOneWidget,
      );
    });

    testWidgets('displays a ShareSubheading', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );

      expect(find.byType(ShareSubheading), findsOneWidget);
    });

    testWidgets(
        'displays a ShareSuccessSubheading '
        'when uploadStatus is success', (tester) async {
      when(() => shareBloc.state).thenReturn(
        ShareState(
          compositeStatus: ShareStatus.success,
          uploadStatus: ShareStatus.success,
          file: file,
        ),
      );
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );

      expect(find.byType(ShareSuccessSubheading), findsOneWidget);
    });

    testWidgets(
        'displays a ShareErrorSubheading '
        'when compositeStatus is failure', (tester) async {
      when(() => shareBloc.state).thenReturn(
        ShareState(
          compositeStatus: ShareStatus.failure,
          file: file,
        ),
      );
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );

      expect(find.byType(ShareErrorSubheading), findsOneWidget);
    });
    testWidgets(
        'displays a ShareCopyableLink '
        'when uploadStatus is success', (tester) async {
      when(() => shareBloc.state).thenReturn(
        ShareState(
          compositeStatus: ShareStatus.success,
          uploadStatus: ShareStatus.success,
          file: file,
        ),
      );
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );

      expect(find.byType(ShareCopyableLink), findsOneWidget);
    });

    testWidgets('displays a RetakeButton', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );

      expect(
        find.byKey(const Key('sharePage_retake_appTooltipButton')),
        findsOneWidget,
      );
    });

    testWidgets('displays a ShareButton', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(ShareButton), findsOneWidget);
    });

    testWidgets('displays a DownloadButton', (tester) async {
      await tester.pumpApp(
        ShareView(),
        photoboothBloc: photoboothBloc,
        shareBloc: shareBloc,
      );
      expect(find.byType(DownloadButton), findsOneWidget);
    });

    group('RetakeButton', () {
      testWidgets(
          'tapping on retake button + close '
          'does not go back to PhotoboothPage', (tester) async {
        await tester.pumpApp(
          ShareView(),
          photoboothBloc: photoboothBloc,
          shareBloc: shareBloc,
        );

        final retakeButtonFinder = find.byKey(
          const Key('sharePage_retake_appTooltipButton'),
        );
        tester.widget<AppTooltipButton>(retakeButtonFinder).onPressed();

        await tester.pumpAndSettle();

        tester.widget<IconButton>(find.byType(IconButton)).onPressed!();

        await tester.pumpAndSettle();

        expect(retakeButtonFinder, findsOneWidget);
        expect(find.byType(PhotoboothPage), findsNothing);

        verifyNever(() => photoboothBloc.add(PhotoClearAllTapped()));
      });

      testWidgets(
          'tapping on retake button + cancel '
          'does not go back to PhotoboothPage', (tester) async {
        await tester.pumpApp(
          ShareView(),
          photoboothBloc: photoboothBloc,
          shareBloc: shareBloc,
        );

        final retakeButtonFinder = find.byKey(
          const Key('sharePage_retake_appTooltipButton'),
        );
        tester.widget<AppTooltipButton>(retakeButtonFinder).onPressed();

        await tester.pumpAndSettle();

        final cancelButtonFinder = find.byKey(
          const Key('sharePage_retakeCancel_elevatedButton'),
        );

        tester.widget<OutlinedButton>(cancelButtonFinder).onPressed!();

        await tester.pumpAndSettle();

        expect(retakeButtonFinder, findsOneWidget);
        expect(find.byType(PhotoboothPage), findsNothing);

        verifyNever(() => photoboothBloc.add(PhotoClearAllTapped()));
      });

      testWidgets(
          'tapping on retake button + confirm goes back to PhotoboothPage',
          (tester) async {
        await tester.pumpApp(
          ShareView(),
          photoboothBloc: photoboothBloc,
          shareBloc: shareBloc,
        );

        final retakeButtonFinder = find.byKey(
          const Key('sharePage_retake_appTooltipButton'),
        );
        tester.widget<AppTooltipButton>(retakeButtonFinder).onPressed();

        await tester.pumpAndSettle();

        final confirmButtonFinder = find.byKey(
          const Key('sharePage_retakeConfirm_elevatedButton'),
        );

        tester.widget<ElevatedButton>(confirmButtonFinder).onPressed!();

        await tester.pumpAndSettle();

        expect(retakeButtonFinder, findsNothing);
        expect(find.byType(PhotoboothPage), findsOneWidget);

        verify(() => photoboothBloc.add(PhotoClearAllTapped())).called(1);
      });
    });

  });
}
