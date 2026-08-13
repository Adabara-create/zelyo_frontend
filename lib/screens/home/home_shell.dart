import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/screens/home/home_screen.dart';
import 'card_screen.dart';
import 'profile_screen.dart';

/// Wraps the four main app tabs (Home, Transactions, Card, Profile) with
/// a custom animated bottom navigation bar. This is what [PasscodeScreen]
/// and [WelcomeBackScreen] should ultimately navigate into instead of
/// their current placeholder screens.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CardScreen(),
    ProfileScreen(),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _AnimatedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

/// Bare stand-in for each tab's real content. Delete once the actual
/// Home/Transactions/Card/Profile screens exist.


class _NavItemData {
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;

  const _NavItemData({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
  });
}

const List<_NavItemData> _navItems = [
  _NavItemData(
    outlineIcon: Icons.home_outlined,
    filledIcon: Icons.home_rounded,
    label: 'Home',
  ),

  _NavItemData(
    outlineIcon: Icons.credit_card_outlined,
    filledIcon: Icons.credit_card_rounded,
    label: 'Card',
  ),
  _NavItemData(
    outlineIcon: Icons.person_outline_rounded,
    filledIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];

/// Simple, flat, edge-to-edge bottom nav bar — no floating card, no
/// active pill, just icons that swap between outline (inactive) and
/// filled blue (active).
class _AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AnimatedBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final isSelected = index == currentIndex;
              return Expanded(
                child: _NavBarButton(
                  item: _navItems[index],
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// A single nav bar icon: crossfades between outline (inactive) and
/// filled + blue (active), with a springy bounce whenever it becomes
/// the selected tab.
class _NavBarButton extends StatefulWidget {
  final _NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarButton> createState() => _NavBarButtonState();
}

class _NavBarButtonState extends State<_NavBarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.28).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.28, end: 0.94).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.94, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_bounceController);

    if (widget.isSelected) _bounceController.value = 1;
  }

  @override
  void didUpdateWidget(covariant _NavBarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: AppColors.primaryBlue.withOpacity(0.12),
        highlightColor: AppColors.primaryBlue.withOpacity(0.06),
        child: Center(
          child: AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) => Transform.scale(
              scale: widget.isSelected ? _bounceAnimation.value : 1.0,
              child: child,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Icon(
                widget.isSelected ? widget.item.filledIcon : widget.item.outlineIcon,
                key: ValueKey<bool>(widget.isSelected),
                color: widget.isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textMuted,
                size: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}