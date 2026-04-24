import 'package:flutter/material.dart';

void showCustomSnackbar({
  required BuildContext context,
  required String message,
  Color? backgroundColor,
  IconData icon = Icons.check_circle,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(message, style: const TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: backgroundColor ?? Colors.green,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
