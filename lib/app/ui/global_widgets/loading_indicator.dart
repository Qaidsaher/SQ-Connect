// loading_indicator.dart
import 'package:flutter/material.dart';
import 'package:sq_connect/app/config/app_colors.dart'; // Assuming you have this

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
        ),
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    // You would need a shimmer package for this, e.g., `shimmer`
    // For now, a placeholder:
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.grey[300]!,
        shape: shapeBorder,
      ),
    );
    // Example with shimmer package:
    // return Shimmer.fromColors(
    //   baseColor: Colors.grey[300]!,
    //   highlightColor: Colors.grey[100]!,
    //   child: Container(
    //     width: width,
    //     height: height,
    //     decoration: ShapeDecoration(
    //       color: Colors.white, // Shimmer works by overlaying on a base color
    //       shape: shapeBorder,
    //     ),
    //   ),
    // );
  }
}