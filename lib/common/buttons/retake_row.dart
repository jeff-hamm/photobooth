import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/common/buttons/show_logs.dart';
import 'package:io_photobooth/config.dart' as config;
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/photobooth/view/camera.dart';
import 'retake_button.dart';

class ActionsRow extends StatelessWidget {
  const ActionsRow(
      {this.retakeButton = true,
      this.sendItButton = false,
      this.refreshButton = true,
      this.showLogsButton = config.IsDebug,
      super.key});

  final bool retakeButton;
  final bool refreshButton;
  final bool showLogsButton;
  final bool sendItButton;

  @override
  Widget build(BuildContext context) {
    if (!retakeButton && !showLogsButton) {
      return const SizedBox();
    }
    return Positioned(
      left: 15,
      top: 15,
      child: Row(
        children: [
          if (retakeButton) const RefreshButton(isStickers: true),
          if (retakeButton) const RetakeButton(isStickers: true),
          if (showLogsButton) const ShowLogsButton(),
        ],
      ),
    );
  }
}
