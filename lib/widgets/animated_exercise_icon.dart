import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedExerciseIcon extends StatefulWidget {
  final String icon;
  final String exerciseType;
  final bool isActive;
  final double size;

  const AnimatedExerciseIcon({
    super.key,
    required this.icon,
    required this.exerciseType,
    required this.isActive,
    this.size = 40,
  });

  @override
  State<AnimatedExerciseIcon> createState() => _AnimatedExerciseIconState();
}

class _AnimatedExerciseIconState extends State<AnimatedExerciseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedExerciseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget animatedIcon;

    if (widget.exerciseType.contains('Cardio') || 
        widget.icon == '🏃' || widget.icon == '🏃‍♂️' || 
        widget.icon == '🚣' || widget.icon == '🚲') {
      animatedIcon = AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: widget.isActive ? _rotationAnimation.value : 0,
            child: child,
          );
        },
        child: Text(widget.icon, style: TextStyle(fontSize: widget.size)),
      );
    } 
    else if (widget.exerciseType.contains('Strength') || 
             widget.icon == '💪' || widget.icon == '🏋️' || 
             widget.icon == '🔱') {
      animatedIcon = AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.isActive ? _bounceAnimation.value : 0),
            child: Transform.scale(
              scale: widget.isActive ? _scaleAnimation.value : 1.0,
              child: child,
            ),
          );
        },
        child: Text(widget.icon, style: TextStyle(fontSize: widget.size)),
      );
    }
    else {
      animatedIcon = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isActive ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: Text(widget.icon, style: TextStyle(fontSize: widget.size)),
      );
    }

    return animatedIcon;
  }
}