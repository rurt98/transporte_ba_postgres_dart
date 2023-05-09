import 'package:flutter/material.dart';

class PageLoadingAbsorbPointer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  const PageLoadingAbsorbPointer({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isLoading,
          child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isLoading ? 0.75 : 1,
              child: child),
        ),
        if (isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
