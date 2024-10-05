import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/share/widgets/facebook_button.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({required this.image, super.key});

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PhotoboothColors.whiteBackground,
            PhotoboothColors.white,
          ],
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 60,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SharePreviewPhoto(image: image),
                    const SizedBox(height: 60),
                    SelectableText(
                      l10n.shareDialogHeading,
                      key: const Key('shareDialog_heading'),
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SelectableText(
                      l10n.shareDialogSubheading,
                      key: const Key('shareDialog_subheading'),
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 36),
                        FacebookButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 24,
            child: IconButton(
              icon: const Icon(
                Icons.clear,
                color: PhotoboothColors.black54,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
