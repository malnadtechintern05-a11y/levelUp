import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Smooth, high-performance PageTransitionsBuilder for silky 60fps route animations.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final secondaryCurvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.04, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.9).animate(secondaryCurvedAnimation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.98).animate(secondaryCurvedAnimation),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Custom PageRouteBuilder with smooth transitions and customizable duration.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration transitionDurationCustom;

  SmoothPageRoute({
    required this.child,
    this.transitionDurationCustom = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: transitionDurationCustom,
          reverseTransitionDuration: transitionDurationCustom,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Tactile bounce micro-interaction for buttons and interactive cards.
/// Shrinks slightly on press and springs back on release with optional haptic feedback.
class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleAmount;
  final Duration duration;
  final bool enableHaptic;
  final HitTestBehavior behavior;

  const BounceTap({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleAmount = 0.95,
    this.duration = const Duration(milliseconds: 120),
    this.enableHaptic = true,
    this.behavior = HitTestBehavior.opaque,
  }) : super(key: key);

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleAmount).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad, reverseCurve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      if (widget.enableHaptic) {
        HapticFeedback.lightImpact();
      }
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress != null
          ? () {
              if (widget.enableHaptic) {
                HapticFeedback.mediumImpact();
              }
              widget.onLongPress?.call();
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
