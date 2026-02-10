import 'package:flutter/material.dart';

/// Animated page route with smooth, modern transitions.
/// Uses Material 3 motion principles for natural-feeling navigation.
class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final AnimationType animationType;
  final Duration duration;

  AnimatedPageRoute({
    required this.child,
    this.animationType = AnimationType.slideUp,
    this.duration = const Duration(milliseconds: 350),
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
    // Material 3 emphasize easing curve for enter transitions
    const enterCurve = Curves.easeOutCubic;
    // Fade for all transitions to feel smoother
    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.65, curve: enterCurve),
      ),
    );

    switch (type) {
      case AnimationType.fade:
        return FadeTransition(opacity: animation, child: child);

      case AnimationType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: enterCurve)),
          child: FadeTransition(opacity: fadeIn, child: child),
        );

      case AnimationType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.25, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: enterCurve)),
          child: FadeTransition(opacity: fadeIn, child: child),
        );

      case AnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.92,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: enterCurve)),
          child: FadeTransition(opacity: fadeIn, child: child),
        );

      case AnimationType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: enterCurve)),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: enterCurve)),
            child: FadeTransition(opacity: fadeIn, child: child),
          ),
        );

      case AnimationType.slideAndFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: enterCurve)),
          child: FadeTransition(opacity: fadeIn, child: child),
        );

      case AnimationType.sharedAxis:
        // Material 3 shared axis transition (forward-backward navigation)
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: enterCurve)),
          child: FadeTransition(opacity: fadeIn, child: child),
        );
    }
  }
}

/// Animation types for page transitions.
/// Each type creates a different visual effect for navigation.
enum AnimationType {
  /// Simple fade in/out
  fade,

  /// Subtle slide up with fade (best for modal-like screens)
  slideUp,

  /// Slide from right with fade (best for forward navigation)
  slideRight,

  /// Scale up with fade (best for dialogs/overlays)
  scale,

  /// Rotation with scale (special effect)
  rotation,

  /// Very subtle slide with fade (best for tab changes)
  slideAndFade,

  /// Material 3 shared axis (best for peer navigation)
  sharedAxis,
}

/// Extension on NavigatorState for easy animated navigation.
extension NavigatorExtension on NavigatorState {
  /// Push a new page with animation.
  Future<T?> pushWithAnimation<T extends Object?>(
    Widget page, {
    AnimationType animationType = AnimationType.slideRight,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return push<T>(
      AnimatedPageRoute<T>(
        child: page,
        animationType: animationType,
        duration: duration,
      ),
    );
  }

  /// Replace current page with animation.
  Future<T?>
  pushReplacementWithAnimation<T extends Object?, TO extends Object?>(
    Widget page, {
    AnimationType animationType = AnimationType.fade,
    Duration duration = const Duration(milliseconds: 350),
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
