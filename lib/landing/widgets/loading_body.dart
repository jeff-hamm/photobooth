import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/common/booth_background_image.dart';
import 'package:io_photobooth/common/buttons/retake_row.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/landing/landing.dart';
import 'package:io_photobooth/common/theme/theme.dart';

class LoadingBody extends StatelessWidget {
  const LoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    return 
    Stack(
      fit: StackFit.expand,
      children: [
        const LandingBackground(),
        const BoothBackgroundImage(),
       Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 48),
            SelectableText(
              l10n.landingPageHeading,
              key: const Key('landingPage_heading_text'),
              style: theme.textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SelectableText(
              l10n.landingPageSubheading,
              key: const Key('landingPage_subheading_text'),
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
              const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: DropShadowImage(
                offset: Offset(10,10),
            scale: 1,
            blurRadius: 10,
            borderRadius: 10,
            image: Image.asset(
                'assets/backgrounds/landing_background.jpg',
                height: size.width <= PhotoboothBreakpoints.small
                    ? size.height * 0.4
                    : size.height * 0.5,
              ),
              
             ),
            )
          ],
        )
    ),
                  const ActionsRow(retakeButton: false,),
    ]
    );
  }
}
