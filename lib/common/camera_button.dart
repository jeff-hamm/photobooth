
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:io_photobooth/common/widgets.dart';
import 'package:io_photobooth/l10n/l10n.dart';

typedef ContextCallback = void Function(BuildContext context);

class CameraButton extends StatelessWidget {
  const CameraButton({this.onPressed, this.icon='assets/icons/camera_button_icon.png', super.key});

  final VoidCallback? onPressed;
  final String icon;

  void onButtonPressed(BuildContext context) {
    onPressed?.call();
  }
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      focusable: true,
      button: true,
      label: l10n.shutterButtonLabelText,
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: const CircleBorder(),
        color: PhotoboothColors.transparent,
        child: InkWell(
          onTap: () => onButtonPressed(context),
          child: IconAssetColorSwitcher(this.icon), 
          )
          // Image.asset(
          //   this.icon,
          //   height: 100,
          //   width: 100,
          // ),
//        ),
      ),
    );
  }
}