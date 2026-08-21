import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_colors.dart';
import 'screens/welcome_screen.dart';

void main() {
  // Match the system status/nav bar chrome to the dark theme so there's no
  // light flash from the OS chrome either, only the app content.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope must sit above MaterialApp — it's what makes every
    // Riverpod provider (accountsProvider now, more as we migrate other
    // screens) reachable from anywhere in the widget tree via
    // ref.watch/ref.read. Forgetting this is the #1 cause of "provider
    // not found" errors.
    const ProviderScope(
      child: ZelyoApp(),
    ),
  );
}

class ZelyoApp extends StatelessWidget {
  const ZelyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zelyo',
      debugShowCheckedModeBanner: false,

      // Setting this at the MaterialApp level (not just per-Scaffold) is
      // what actually kills the white flash: it's the color the route's
      // canvas paints *before* your screen's own Scaffold has painted,
      // which is exactly the gap you see during a page transition.
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryBlueLight,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        fontFamily: 'Inter', // swap/remove if you're not using this font
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FadeSlidePageTransitionsBuilder(),
            TargetPlatform.iOS: _FadeSlidePageTransitionsBuilder(),
          },
        ),
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
      ), // fallback theme kept dark too, in case themeMode ever changes

      home: const WelcomeScreen(),
    );
  }
}

/// Applies the same fade + slide-up motion to *every* pushed route by
/// default, so individual screens don't need to remember to use
/// AppTransitions.fadeSlide(...) manually for standard navigation.
class _FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}