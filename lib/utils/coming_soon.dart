import 'package:flutter/material.dart';

void showComingSoon(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('🚀 Coming Soon', textAlign: TextAlign.center),
      content: const Text(
        'This feature is under development.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
    ),
  );
}
