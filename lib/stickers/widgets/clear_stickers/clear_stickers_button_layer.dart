import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:io_photobooth/stickers/stickers.dart';
import 'package:io_photobooth/common/image_color_switcher.dart';
import 'package:io_photobooth/common/widgets.dart';

class ClearStickersButtonLayer extends StatelessWidget {
  const ClearStickersButtonLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isHidden = context.select(
      (PhotoboothBloc bloc) => bloc.state.stickers.isEmpty,
    ) && context.select(
      (ShareBloc bloc) => bloc.state.aiImages?.isEmpty != false,
    );
    if (isHidden) return const SizedBox();
    return ClearStickersButton(
      onPressed: () async {
        final photoboothBloc = context.read<PhotoboothBloc>();
        final confirmed = await showAppDialog<bool>(
          context: context,
          child: const ClearStickersDialog(),
        );
        if (confirmed ?? false) {
          photoboothBloc.add(const PhotoClearStickersTapped());
        }
      },
    );
  }
}

class ClearStickersButton extends StatelessWidget {
  const ClearStickersButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      focusable: true,
      button: true,
      label: l10n.clearAllStickersButtonLabelText,
      child: AppTooltipButton(
        onPressed: onPressed,
        message: l10n.clearStickersButtonTooltip,
        verticalOffset: 50,
        child: const IconAssetColorSwitcher('assets/icons/delete_icon.png'),
      ),
    );
  }
}
