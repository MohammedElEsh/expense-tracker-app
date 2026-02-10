import 'package:flutter/material.dart';

class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final AnimationType animationType;
  final Duration duration;

  AnimatedPageRoute({
    required this.child,
    this.animationType = AnimationType.slideUp,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransition(
             animation,
             secondaryAnimation,
             child,
             animationType,
           );
         },
       );

  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    AnimationType type,
  ) {
    switch (type) {
      case AnimationType.fade:
        return FadeTransition(opacity: animation, child: child);

      case AnimationType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );

      case AnimationType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );

      case AnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );

      case AnimationType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: ScaleTransition(scale: animation, child: child),
        );

      case AnimationType.slideAndFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
    }
  }
}

enum AnimationType { fade, slideUp, slideRight, scale, rotation, slideAndFade }

// Extension for easy navigation with animations
extension NavigatorExtension on NavigatorState {
  Future<T?> pushWithAnimation<T extends Object?>(
    Widget page, {
    AnimationType animationType = AnimationType.slideUp,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return push<T>(
      AnimatedPageRoute<T>(
        child: page,
        animationType: animationType,
        duration: duration,
      ),
    );
  }

  Future<T?>
  pushReplacementWithAnimation<T extends Object?, TO extends Object?>(
    Widget page, {
    AnimationType animationType = AnimationType.fade,
    Duration duration = const Duration(milliseconds: 400),
    TO? result,
  }) {
    return pushReplacement<T, TO>(
      AnimatedPageRoute<T>(
        child: page,
        animationType: animationType,
        duration: duration,
      ),
      result: result,
    );
  }
}
