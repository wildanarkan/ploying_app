import 'package:flutter/material.dart';
import 'package:ploying_app/common/app_info.dart';
import 'package:ploying_app/data/source/user_source.dart';

class UpdatePassword {
  static void showResetPasswordDialog(BuildContext context, int userId) {
    final TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: newPasswordController,
            decoration: const InputDecoration(hintText: 'Enter new password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newPassword = newPasswordController.text;
                if (newPassword.isNotEmpty) {
                  bool success =
                      await UserSource.updatePassword(userId, newPassword);
                  Navigator.of(context).pop();
                  if (success) {
                    AppInfo.success(context, 'Berhasil Update Password!');
                  } else {
                    AppInfo.failed(context, 'Gagal Update Password!');
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
