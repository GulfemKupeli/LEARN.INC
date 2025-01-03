import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LiveController {
  static Future<void> reduceLive(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentLives = userProvider.user?.lives ?? 0;

    if (currentLives > 0) {
      print('Current lives: $currentLives');
      print('Reducing lives by 1...');
      await userProvider.updateLives(currentLives - 1);
      print('Lives after reduction: ${userProvider.user?.lives}');
    } else {
      print('No lives left. Showing pop-up.');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Out of Lives'),
          content: const Text('You have no lives left! Try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
