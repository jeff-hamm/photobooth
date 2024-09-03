import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import 'package:platform_helper/platform_helper.dart';

class ShareStateListener extends StatelessWidget {
  ShareStateListener({
    required this.child,
    super.key,
    PlatformHelper? platformHelper,
  }) : platformHelper = platformHelper ?? PlatformHelper();

  final Widget child;

  /// Optional [PlatformHelper] instance.
  final PlatformHelper platformHelper;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShareBloc, ShareState>(
      listener: _onShareStateChange,
      child: child,
    );
  }

  void _onShareStateChange(BuildContext context, ShareState state) {
    if (state.uploadStatus.isFailure) {
      _onShareError(context, state);
    } else if (state.uploadStatus.isSuccess) {
      _onShareSuccess(context, state);
    }
    if(state.aiStatus.isSuccess) {
      _onAiSuccess(context,state);
    }
  }

  void _onShareError(BuildContext context, ShareState state) {
    showAppModal<void>(
      platformHelper: platformHelper,
      context: context,
      portraitChild: const ShareErrorBottomSheet(),
      landscapeChild: const ShareErrorDialog(),
    );
  }
  void _onAiSuccess(BuildContext context, ShareState state) {
    final w =             AnimatedFadeIn(
      child: 
      ColoredBox(
      color: PhotoboothColors.black.withOpacity(0.8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const SuccessHeading("AI Generated Image"),
                  const SizedBox(height: 20),
                  SuccessSubheading(state.aiPrompt),
                  state.aiImages != null ?
                    AnimatedPhotoboothPhoto(image: state.aiImages![0]) :
                   const AppCircularProgressIndicator()
                  ]
                )
        )
      )
      ));
    showAppModal<void>(
      platformHelper: platformHelper,
      context: context,
      portraitChild: w,
      landscapeChild: w,
    );
  }

  void _onShareSuccess(BuildContext context, ShareState state) {
    if(state.shareUrl == ShareUrl.none){
      return;
    }
    openLink(
      state.shareUrl == ShareUrl.twitter
          ? state.twitterShareUrl
          : state.facebookShareUrl,
    );
  }
}
