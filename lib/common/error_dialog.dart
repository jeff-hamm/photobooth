import 'package:flutter/material.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:photobooth_ui/photobooth_ui.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key,this.text,this.title});
  final String? title;
  final String? text;
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
                    SizedBox(
                      height: 300,
                      child: Image.asset(
                        'assets/images/error_photo_desktop.png',
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      title ?? l10n.shareErrorDialogHeading,
                      key: const Key('errorDialog_heading'),
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    // const SizedBox(height: 24),
                    // Text(
                    //   l10n.shareErrorDialogSubheading,
                    //   key: const Key('errorDialog_subheading'),
                    //   style: theme.textTheme.displaySmall,
                    //   textAlign: TextAlign.center,
                    // ),
                    const SizedBox(height:80),
                    Text(
                      text ?? 'Error',
                      key: const Key('errorDialog_text'),
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
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
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
