import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:io_photobooth/common/widgets.dart';

/// Overlay displayed on top of the [SharePage] when [ShareBloc] is
/// in the in progress state.
class AiGeneratedOverlay extends StatelessWidget {
  const AiGeneratedOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShareBloc, ShareState>(
      builder: (context, state) => state.aiStatus.isSuccess
          ? const _AiGeneratedOverlay(
              key: Key('AiGeneratedOverlay_loading'),
            )
          : const SizedBox(key: Key('AiGeneratedOverlay_nothing')),
    );
  }
}

class _AiGeneratedOverlay extends StatelessWidget {
  const _AiGeneratedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return 
      AnimatedFadeIn(child:
      ColoredBox(
      color: PhotoboothColors.black.withOpacity(0.8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: ResponsiveLayoutBuilder(
            small: (_, __) => const _MobileAiGeneratedOverlay(
              key: Key('AiGeneratedOverlay_mobile'),
            ),
            large: (_, __) => const _DesktopAiGeneratedOverlay(
              key: Key('AiGeneratedOverlay_desktop'),
            ),
          ),
        ),
      ),
    )
      );
  }
}

class _DesktopAiGeneratedOverlay extends StatelessWidget {
  const _DesktopAiGeneratedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final aiImages = context.select((ShareBloc bloc) => bloc.state.aiImages);
    final prompt = context.select((ShareBloc bloc) => bloc.state.aiPrompt);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [        
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 258),
          child: Text(
            "AI Generated an Image",
            style: theme.textTheme.displayLarge?.copyWith(
              color: PhotoboothColors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          prompt,
          style: theme.textTheme.displaySmall?.copyWith(
            color: PhotoboothColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        AnimatedPhotoboothPhoto(image: aiImages![0]),

      ],
    );
  }
}

class _MobileAiGeneratedOverlay extends StatelessWidget {
  const _MobileAiGeneratedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final aiImages = context.select((ShareBloc bloc) => bloc.state.aiImages);
    final prompt = context.select((ShareBloc bloc) => bloc.state.aiPrompt);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            "AI Generated an Image",
            style: theme.textTheme.displayLarge?.copyWith(
              color: PhotoboothColors.white,
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          prompt,
          style: theme.textTheme.displaySmall?.copyWith(
            color: PhotoboothColors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
