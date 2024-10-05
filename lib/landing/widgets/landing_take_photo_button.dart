import 'package:auto_route/auto_route.dart';
import 'package:analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';

class LandingTakePhotoButton extends StatelessWidget {
  const LandingTakePhotoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ElevatedButton(
      onPressed: () {
        trackEvent(
          category: 'button',
          action: 'click-start-photobooth',
          label: 'start-photobooth',
        );
                AutoRouter.of(context).pushNamed("/booth");

//        context.go("/booth");
      },
      child: Text(l10n.landingPageTakePhotoButtonText),
    );
  }
}
