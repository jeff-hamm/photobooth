import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/app/router.gr.dart';
import 'package:io_photobooth/common/camera_image_blob.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:io_photobooth/common/widgets.dart';
import '../../common/photos_repository.dart';
import '../../config.dart' as config;
@RoutePage()
class SharePage extends StatelessWidget {
  const SharePage({super.key, this.imageId});

  final String? imageId;
  static Route<void> route() {
    return AppPageRoute(builder: (_) => const SharePage());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final photoBloc = context.watch<PhotoboothBloc>();
    if (photoBloc.state.mostRecentImage == null && imageId == null) {
      AutoRouter.of(context).replace(const PhotobothViewRoute());
      return const SizedBox();
    }

    return BlocProvider(
      create: (context) {
        final state = photoBloc!.state;
        return ShareBloc(
          photosRepository: context.read<PhotosRepository>(),
          imageId: state.imageId,
          image: CameraImageBlob(
              data: state.mostRecentImage.path, width: 0, height: 0),
          assets: state.assets,
          aspectRatio: state.aspectRatio,
          shareText: l10n.socialMediaShareLinkText,
        )..add(const ShareViewLoaded());
      },
      child: const ShareView(),
    );
  }
}

class ShareView extends StatelessWidget {
  const ShareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShareStateListener(
        child: AppPageView(
          background: PhotoboothBackground(),
          body: ShareBody(),
          footer: Container(),
          overlays: [
            _ShareRetakeButton(),
//            ShareProgressOverlay(),
            Positioned.fill(
                child: GestureDetector(
              onTap: () =>
                  AutoRouter.of(context).replace(const PhotobothViewRoute()),
            )),
          ],
        ),
      ),
    );
  }
}

class _ShareRetakeButton extends StatelessWidget {
  const _ShareRetakeButton();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = context.select(
      (ShareBloc bloc) => bloc.state.compositeStatus.isLoading,
    );
    if (isLoading) return const SizedBox();
    return Positioned(
      left: 15,
      top: 15,
      child: const RetakeButton()
    );
  }
}