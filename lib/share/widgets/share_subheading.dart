import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/external_links/external_links.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:photobooth_ui/photobooth_ui.dart';

class ShareSubheading extends StatelessWidget {
  const ShareSubheading({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SelectableText.rich(
      TextSpan(
        text: l10n.sharePageLearnMoreAboutTextPart1,
        style: theme.textTheme.displaySmall?.copyWith(
          fontWeight: PhotoboothFontWeight.regular,
          color: PhotoboothColors.accent,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ShareSuccessSubheading extends StatelessWidget {
  const ShareSuccessSubheading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SelectableText(
      l10n.sharePageSuccessSubheading,
      style: theme.textTheme.displaySmall?.copyWith(
        color: PhotoboothColors.accent,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ShareErrorSubheading extends StatelessWidget {
  const ShareErrorSubheading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SelectableText(
      l10n.sharePageErrorSubheading,
      style: theme.textTheme.displaySmall?.copyWith(
        color: PhotoboothColors.accent,
      ),
      textAlign: TextAlign.center,
    );
  }
}
