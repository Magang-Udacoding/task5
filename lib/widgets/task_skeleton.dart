import 'package:flutter/material.dart';

class TaskSkeletonList extends StatefulWidget {
  const TaskSkeletonList({
    super.key,
  });

  @override
  State<TaskSkeletonList> createState() => _TaskSkeletonListState();
}

class _TaskSkeletonListState extends State<TaskSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            20,
          ),
          child: Column(
            children: [
              for (int i = 0; i < 4; i++)
                _buildSkeletonCard(
                  _controller.value,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard(
    double progress,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildShimmerBox(
            progress,
            width: 24,
            height: 24,
            radius: 8,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(
                  progress,
                  width: 170,
                  height: 14,
                  radius: 7,
                ),
                const SizedBox(height: 9),
                _buildShimmerBox(
                  progress,
                  width: 110,
                  height: 10,
                  radius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(
    double progress, {
    required double width,
    required double height,
    required double radius,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final shift = (progress * 3 - 1) * bounds.width;

        return LinearGradient(
          colors: const [
            Color(0xFFE2E4EC),
            Color(0xFFFFFFFF),
            Color(0xFFE2E4EC),
          ],
          stops: const [
            0.1,
            0.5,
            0.9,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          transform: _ShimmerGradientTransform(
            shift,
          ),
        ).createShader(bounds);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E4EC),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _ShimmerGradientTransform extends GradientTransform {
  final double offset;

  const _ShimmerGradientTransform(
    this.offset,
  );

  @override
  Matrix4 transform(
    Rect bounds, {
    TextDirection? textDirection,
  }) {
    return Matrix4.translationValues(
      offset,
      0,
      0,
    );
  }
}
