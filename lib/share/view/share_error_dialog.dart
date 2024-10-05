import 'package:flutter/material.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:io_photobooth/common/image_color_switcher.dart';
import 'package:io_photobooth/common/widgets.dart';

class ShareErrorDialog extends StatelessWidget {
  const ShareErrorDialog({super.key});

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
                      AssetColorSwitcher(
                        'assets/images/error_photo_desktop.png',
                        height: 300,
                      ),
                    const SizedBox(height: 60),
                    Text(
                      l10n.shareErrorDialogHeading,
                      key: const Key('shareErrorDialog_heading'),
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.shareErrorDialogSubheading,
                      key: const Key('shareErrorDialog_subheading'),
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 42),
                    const ShareTryAgainButton(),
                    const SizedBox(height: 16),
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
