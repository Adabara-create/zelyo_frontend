import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A dot indicator row where the active dot stretches into a pill shape
/// and inactive dots stay small circles.
class CarouselDots extends StatelessWidget {
  final int itemCount;
  final int activeIndex;

  const CarouselDots({
    super.key,
    required this.itemCount,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8, // pill shape when active
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : AppColors.dotInactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}