import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/common/app_dialog.dart';
import 'package:io_photobooth/common/utils/logger_screen_wrapper.dart';
import 'package:io_photobooth/main.dart';
import 'package:io_photobooth/config.dart' as config;

Future<void> openWithStyle(BuildContext context, ScreenStyle screenStyle) {
  final page = LoggerScreenWrapper(
    screenStyle: screenStyle,
    printer: errorHandler.logger,
  );
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //   content: page,
  //   action: SnackBarAction(
  //     label: 'Reload',
  //     onPressed: () {
  //     },
  //   ),
  // ));
  return showAppDialog(context: context, child: page);
//    return Future.value();
}

class ShowLogsButton extends StatelessWidget {
  const ShowLogsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!config.IsDebug) {
      return const SizedBox();
    }

    return IconButton(
      icon: const Icon(Icons.bug_report),
      onPressed: () async {
        await openWithStyle(context, ScreenStyle.material);
      },
    );
  }
}
