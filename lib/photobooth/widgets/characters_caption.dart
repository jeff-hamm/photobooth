import 'package:flutter/material.dart';
import 'package:io_photobooth/common/app_tooltip.dart';
import 'package:io_photobooth/l10n/l10n.dart';

class CharactersCaption extends StatelessWidget {
  const CharactersCaption({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: false,
      child: AppTooltip.custom(
        visible: true,
        message: l10n.charactersCaptionText,
      ),
    );
  }
}
