import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = AppDimensions.radius16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerLine extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerLine({super.key, this.width = 100, this.height = 12});

  @override
  Widget build(BuildContext context) => ShimmerBox(
        width: width,
        height: height,
        radius: 4,
      );
}
