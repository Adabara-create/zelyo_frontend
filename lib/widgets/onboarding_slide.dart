import 'package:flutter/material.dart';

/// Data for a single onboarding page: a background image (loaded from a
/// URL, so no bundled asset is needed) plus its own headline/subtitle.
class OnboardingSlideData {
  final String imageUrl;
  final String title;
  final String subtitle;

  const OnboardingSlideData({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
}

/// Renders a single slide as a full-bleed background image with a dark
/// gradient scrim so the headline/buttons stay legible on top of it.
class OnboardingBackgroundSlide extends StatelessWidget {
  final String imageUrl;

  const OnboardingBackgroundSlide({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Network image fills the entire slide.
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black26,
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  color: Colors.white70, size: 40),
            ),
          ),
        ),

        // Gradient scrim: clear near the top, dark toward the bottom where
        // the headline, dots, buttons and terms text sit.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.45, 0.75, 1.0],
              colors: [
                Colors.transparent,
                Colors.transparent,
                Color(0xCC000000),
                Color(0xF2000000),
              ],
            ),
          ),
        ),
      ],
    );
  }
}