import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/common/utils/links_helper.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/share/share.dart';

class FacebookButton extends StatelessWidget {
  const FacebookButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ElevatedButton(
      onPressed: () {
        final state = context.read<ShareBloc>().state;
        if (state.uploadStatus.isSuccess) {
          Navigator.of(context).pop();
          openLink(state.facebookShareUrl);
          return;
        }
        context.read<ShareBloc>().add(const ShareOnFacebookTapped());

        Navigator.of(context).pop();
      },
      child: Text(l10n.shareDialogFacebookButtonText),
    );
  }
}
