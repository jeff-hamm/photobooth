import 'package:flutter/material.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import '../../config.dart' as config;

class SideIconButton extends StatelessWidget {
  const SideIconButton({
    required this.icon,
    required this.isSelected,
    this.label,
    this.onPressed,
    super.key,
  });

  final AssetImage icon;
  final VoidCallback? onPressed;
  final bool isSelected;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Semantics(
      focusable: true,
      button: true,
      label: label,
      onTap: onPressed,
      child: Opacity(
        opacity: isSelected ? 0.6 : 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: PhotoboothColors.black25,
            borderOnForeground: false,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink.image(
              fit: BoxFit.cover,
              image: icon,
              width: orientation == Orientation.landscape
                  ? config.SideIconButtonSizeLandscape
                  : config.SideIconButtonSizePortait,
              height: orientation == Orientation.landscape
                  ? config.SideIconButtonSizeLandscape
                  : config.SideIconButtonSizePortait,
              child: InkWell(onTap: onPressed),
            ),
          ),
        ),
      ),
    );
  }
}
