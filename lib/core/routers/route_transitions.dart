import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wraps a route child in a fade + subtle scale transition for GoRouter [pageBuilder].
Page<void> buildTransitionPage({
  required LocalKey pageKey,
  required Widget child,
  Duration duration = const Duration(milliseconds: 800),
}) {
  return CustomTransitionPage<void>(
    key: pageKey,
    child: child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        ),
      );
    },
  );
}
