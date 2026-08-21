import 'package:flutter/material.dart';

class BounceFab extends StatefulWidget {
  final VoidCallback onPressed;

  const BounceFab({
    super.key,
    required this.onPressed,
  });

  @override
  State<BounceFab> createState() => _BounceFabState();
}

class _BounceFabState extends State<BounceFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 350,
      ),
    );

    _scale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.0,
            end: 0.82,
          ).chain(
            CurveTween(
              curve: Curves.easeOutCubic,
            ),
          ),
          weight: 35,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.82,
            end: 1.0,
          ).chain(
            CurveTween(
              curve: Curves.elasticOut,
            ),
          ),
          weight: 65,
        ),
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() {
    _controller.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton(
        onPressed: _handlePressed,
        tooltip: 'Tambah task',
        backgroundColor: const Color(0xFF5B5FEF),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
