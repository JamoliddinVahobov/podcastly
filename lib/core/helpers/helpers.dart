import 'package:flutter/material.dart';

import '../services/token_management_service.dart';

class Helpers {
  static final tokenService = TokenManagementService();

  static Future<String> getAccessToken() async {
    return await tokenService.getAccessToken();
  }

  static void showSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            )),
        backgroundColor: Colors.red,
      ),
    );
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}
