import 'package:flutter/material.dart';

abstract class ShowDialog {
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    String? txtCancelar,
    String? txtAceptar,
  }) async =>
      showDialog<bool?>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(title),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(txtCancelar ?? "Cancelar"),
              ),
              TextButton(
                onPressed: () async => Navigator.of(context).pop(true),
                child: Text(txtAceptar ?? "Aceptar"),
              )
            ],
          );
        },
      );

  static Future<T?> showSimpleRightDialog<T extends Object?>(
    BuildContext context, {
    required Widget child,
    AlignmentGeometry? alignment,
    double? widthFactor,
    Color? barrierColor,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierColor:
          barrierColor ?? Colors.black12.withOpacity(0.4), // background color
      barrierDismissible:
          barrierDismissible, // should dialog be dismissed when tapped outside
      barrierLabel: "Dialog", // label for barrier
      transitionDuration: const Duration(
        milliseconds: 400,
      ), // how long it takes to popup dialog after button click
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      pageBuilder: (_, __, ___) {
        if (widthFactor == null) {
          return Align(
            alignment: alignment ?? Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 50),
              child: SizedBox(
                width: 550,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: child,
                ),
              ),
            ),
          );
        } else {
          return Align(
            alignment: alignment ?? Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: child,
              ),
            ),
          );
        }
      },
    );
  }
}
