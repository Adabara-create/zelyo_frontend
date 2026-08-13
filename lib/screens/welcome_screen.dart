import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/carousel_dots.dart';
import '../widgets/onboarding_slide.dart';
import 'package:zelyo_1/screens/auth/login_screen.dart';
import 'package:zelyo_1/screens/auth/signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _activeIndex = 0;

  // Each slide is a network image URL + its own unique headline/subtitle.
  // Swap these URLs for your real photography whenever you like — nothing
  // else needs to change.
  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      imageUrl:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1200&q=80',
      title: 'A new way of\npayment system',
      subtitle: 'Send, spend, and save — all from one simple wallet.',
    ),
    OnboardingSlideData(
      imageUrl:
          'https://images.unsplash.com/photo-1621761191319-c6fb62004040?w=1200&q=80',
      title: 'Exchange currencies\nat real rates',
      subtitle: 'No hidden markups. Just the rate you see on the news.',
    ),
    OnboardingSlideData(
      imageUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&q=80',
      title: 'Bank from anywhere\nin the world',
      subtitle: 'Your money moves with you, wherever life takes you.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCreateAccountTap() {
    // Navigate to the sign up screen when the "Create Account" button is tapped.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _onLoginTap() {
    // Navigate to the login screen when the "Login" button is tapped.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ----- Full-screen swipeable image background -----
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() => _activeIndex = index);
              },
              itemBuilder: (context, index) => OnboardingBackgroundSlide(
                imageUrl: _slides[index].imageUrl,
              ),
            ),
          ),

          // ----- Foreground content, pinned to the bottom over the scrim -----
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Headline + subtitle crossfade per slide.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                    key: ValueKey<int>(_activeIndex),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          _slides[_activeIndex].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _slides[_activeIndex].subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ----- Pill-style dot indicator -----
                CarouselDots(
                  itemCount: _slides.length,
                  activeIndex: _activeIndex,
                ),

                const SizedBox(height: 28),

                // ----- Buttons + terms -----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Create account - filled blue curved button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onCreateAccountTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Login - outlined curved button (white outline since
                      // it now sits on top of a photo, not a light bg)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _onLoginTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white70,
                              width: 1.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Terms and policy text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'By continuing, you agree to Zelyo\'s ',
                              ),
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: null, // hook up TapGestureRecognizer when the terms screen exists
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: null,
                              ),
                              const TextSpan(
                                text:
                                    '. Zelyo keeps your funds and personal data secure across every currency you hold.',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}