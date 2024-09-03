import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/retake_button.dart';
import 'package:io_photobooth/footer/footer.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import '../../common/photos_repository.dart';
import '../../config.dart' as config;
class SharePage extends StatelessWidget {
  const SharePage({super.key});

  static Route<void> route() {
    return AppPageRoute(builder: (_) => const SharePage());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) {
        final state = context.read<PhotoboothBloc>().state;
        return ShareBloc(
          photosRepository: context.read<PhotosRepository>(),
          imageId: state.imageId,
          image: state.image!,
          assets: state.assets,
          aspectRatio: state.aspectRatio,
          shareText: l10n.socialMediaShareLinkText,
          aiPrompt: config.AiPrompt,
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
            ShareProgressOverlay(),
            
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