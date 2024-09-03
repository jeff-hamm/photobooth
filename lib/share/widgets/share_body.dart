import 'dart:typed_data';

import 'package:analytics/analytics.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/retake_button.dart';
import 'package:io_photobooth/external_links/external_links.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareBody extends StatelessWidget {
  const ShareBody({super.key});

  @override
  Widget build(BuildContext context) {
    final image = context.select((PhotoboothBloc bloc) => bloc.state.image)?.data;
    final file = context.select((ShareBloc bloc) => bloc.state.file);
    final compositeStatus = context.select(
      (ShareBloc bloc) => bloc.state.compositeStatus,
    );
    final compositedImage = context.select(
      (ShareBloc bloc) => bloc.state.bytes,
    );
    final isUploadSuccess = context.select(
      (ShareBloc bloc) => bloc.state.uploadStatus.isSuccess,
    );
    final shareUrl = context.select(
      (ShareBloc bloc) => bloc.state.explicitShareUrl,
    );
    final aiStatus = context.select(
      (ShareBloc bloc) => bloc.state.aiStatus,
    );
    final aiImages = context.select((ShareBloc bloc) => bloc.state.aiImages);
    final aiPrompt = context.select((ShareBloc bloc) => bloc.state.aiPrompt);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AnimatedPhotoIndicator(),
          AnimatedPhotoboothPhoto(image: image),
          if (compositeStatus.isSuccess)
            AnimatedFadeIn(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60),
                  if (isUploadSuccess)
                    const ShareSuccessHeading()
                  else
                    const ShareHeading(),
                  const SizedBox(height: 20),
                  if (isUploadSuccess)
                    const ShareSuccessSubheading()
                  else
                    const ShareSubheading(),
                  const SizedBox(height: 30),
                  if (isUploadSuccess)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        bottom: 30,
                      ),
                      child: ShareCopyableLink(link: shareUrl),
                    ),
                  if (compositedImage != null && file != null)
                    ResponsiveLayoutBuilder(
                      small: (_, __) => ShareButtonsLayout(
                        image: compositedImage,
                        file: file,
                        size: const Size(0,20),
                        shareUrl: isUploadSuccess ? shareUrl : null,
                      ),
                      large: (_, __) => ShareButtonsLayout(
                        image: compositedImage,
                        file: file,
                        size: const Size(36,0),
                        shareUrl: isUploadSuccess ? shareUrl : null,
                      ),
                    ),
                ],
              ),
            ),
          if (compositeStatus.isFailure)
            const AnimatedFadeIn(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  ShareErrorHeading(),
                  SizedBox(height: 20),
                  ShareErrorSubheading(),
                  SizedBox(height: 30),
                ],
              ),
            ),
          if(aiStatus == ShareStatus.success || aiStatus == ShareStatus.loading)
            AnimatedFadeIn(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const SuccessHeading("AI Generated Image"),
                  const SizedBox(height: 20),
                  SuccessSubheading(aiPrompt),
                  aiImages != null ?
                    AnimatedPhotoboothPhoto(image: aiImages![0]) :
                   const AppCircularProgressIndicator(),
                ]))

        ],
      ),
    );
  }
}

@visibleForTesting
class ShareButtonsLayout extends StatelessWidget {
  const ShareButtonsLayout({
    required this.image,
    required this.file,
    required this.size,
    this.shareUrl,
    super.key,
  });

  final String? shareUrl;
  final Uint8List image;
  final XFile file;
  final Size size;
  final prompt = 'A photo booth in a mystical forest';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: DownloadButton(file: file)),
        SizedBox(width: size.width > 0 ? size.width : null, height: size.height > 0 ? size.height : null),
        Flexible(child: RetakeButton()),
        SizedBox(width: size.width > 0 ? size.width : null, height: size.height > 0 ? size.height : null),
      ],
    ),
    if(shareUrl != null)
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [        
                   SizedBox(height: 50),
         QrImageView(
            data: shareUrl!,
            version: QrVersions.auto,
            size: 200.0,

          ),
                   SizedBox(height: 50),
          QrImageView(
              data: 'http://127.0.0.1:5023/wedding?image=' + Uri.encodeComponent( shareUrl!) + '&prompt=' + Uri.encodeComponent(prompt) + '&tenant=wedding',
              version: QrVersions.auto,
              size: 200.0,
            ),
    ])]);
  }
}

// @visibleForTesting
// class MobileButtonsLayout extends StatelessWidget {
//   const MobileButtonsLayout({
//     required this.image,
//     required this.file,
//     this.shareUrl,
//     super.key,
//   });
//   final String? shareUrl;
//   final Uint8List image;
//   final XFile file;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         DownloadButton(file: file),
//         const SizedBox(height: 20),
//         RetakeButton(),
//         const SizedBox(height: 20),
//         if(shareUrl != null && context.read<PhotoboothBloc>().state.isPrimaryClient)
//           QrImageView(
//             data: shareUrl!,
//             version: QrVersions.auto,
//             size: 50.0,
//           ),
//       ],
//     );
//   }
// }

@visibleForTesting
class DownloadButton extends StatelessWidget {
  const DownloadButton({required this.file, super.key});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: PhotoboothColors.accent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        side: const BorderSide(color: PhotoboothColors.accent, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(208, 54),
      ),
      onPressed: () {
        trackEvent(
          category: 'button',
          action: 'click-download-photo',
          label: 'download-photo',
        );
        file.saveTo('');
      },
      child: Text(l10n.sharePageDownloadButtonText),
    );
  }
}
