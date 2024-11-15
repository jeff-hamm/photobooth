import 'package:flutter/material.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:io_photobooth/common/image_color_switcher.dart';
import 'package:io_photobooth/common/widgets.dart';

class ShareErrorBottomSheet extends StatelessWidget {
  const ShareErrorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 58),
                  child: AssetColorSwitcher(
                    'assets/images/error_photo_mobile.png',
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  l10n.shareErrorDialogHeading,
                  key: const Key('shareErrorBottomSheet_heading'),
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.shareErrorDialogSubheading,
                  key: const Key('shareErrorBottomSheet_subheading'),
                  style: theme.textTheme.displaySmall?.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 42),
                const ShareTryAgainButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Positioned(
          right: 24,
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
    );
  }
}
