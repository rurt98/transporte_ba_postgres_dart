import 'package:flutter/material.dart';

abstract class ShowSnackBar {
  static SnackBar errorSnackBar({String? message}) => SnackBar(
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.pink[100]?.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: <InlineSpan>[
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.warning, color: Colors.black, size: 15),
                    ),
                    TextSpan(
                      text: '  ${message ?? 'Error, inténtelo más tarde'}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  static void showError(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(message: message));
  }

  static SnackBar successfulSnackBar({String? message}) => SnackBar(
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green[100]?.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.black, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    message ?? 'Se ha realizado la petición con éxito',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  static SnackBar warningSnackbar({String? message}) => SnackBar(
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green[100]?.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.black, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    message ?? 'Se ha realizado la petición con éxito',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  static void showSuccessful(BuildContext context, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      successfulSnackBar(message: message),
    );
  }
}
