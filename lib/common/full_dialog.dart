import 'package:flutter/material.dart';
import 'package:io_photobooth/common/theme/colors.dart';

/// Displays a dialog above the current contents of the app.
Future<T?> showFullDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) =>
    showDialog<T>(
      context: context,
      
      barrierColor: PhotoboothColors.charcoal,
      barrierDismissible: barrierDismissible,
      builder: (context) => _FullDialog(child: child),
    );

class _FullDialog extends StatelessWidget {
  const _FullDialog({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: Container(
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
        child: child,
      ),
    );
  }
}
