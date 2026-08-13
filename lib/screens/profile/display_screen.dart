import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';

enum _ThemeOption { light, dark, system }

/// Theme selection — the screen is majorly about picking Light / Dark /
/// System, each shown as a large preview card rather than a plain radio
/// list. Sub-screen of Profile — has a back button.
///
/// HONESTY NOTE: Zelyo's AppColors is currently a single fixed dark
/// palette — there's no light theme implementation yet. This screen is
/// fully built and lets the user pick, but selecting "Light" or
/// "System" won't visually change anything until a real light
/// ColorScheme and a ThemeMode-aware MaterialApp exist. That's flagged
/// to the user inline rather than silently pretending it works.
class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  _ThemeOption _selected = _ThemeOption.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  const Text('Theme', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose how Zelyo looks on this device.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _ThemePreviewCard(
                          label: 'Light',
                          isSelected: _selected == _ThemeOption.light,
                          isLight: true,
                          onTap: () => setState(() => _selected = _ThemeOption.light),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ThemePreviewCard(
                          label: 'Dark',
                          isSelected: _selected == _ThemeOption.dark,
                          isLight: false,
                          onTap: () => setState(() => _selected = _ThemeOption.dark),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  InkWell(
                    onTap: () => setState(() => _selected = _ThemeOption.system),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _selected == _ThemeOption.system ? AppColors.primaryBlue : AppColors.outlineBorder,
                          width: _selected == _ThemeOption.system ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.14), borderRadius: BorderRadius.circular(11)),
                            child: const Icon(Icons.brightness_auto_rounded, color: AppColors.primaryBlueLight, size: 19),
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Match system', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                                SizedBox(height: 2),
                                Text('Follows your device\'s appearance setting.', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          _SelectionCircle(isSelected: _selected == _ThemeOption.system),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_selected != _ThemeOption.dark)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Light theme is coming soon — Zelyo will stay in dark mode until then.',
                              style: TextStyle(color: const Color(0xFFF59E0B), fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 4),
          const Text('Display', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// A large tappable card previewing what the theme roughly looks like —
/// a tiny mock header + content lines rendered in the theme's own tones
/// — rather than just a plain labeled radio row.
class _ThemePreviewCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLight;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.label,
    required this.isSelected,
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewBg = isLight ? const Color(0xFFF5F6FA) : AppColors.background;
    final previewSurface = isLight ? Colors.white : AppColors.surface;
    final previewText = isLight ? const Color(0xFF101828) : AppColors.textPrimary;
    final previewMuted = isLight ? const Color(0xFFAEB4C2) : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.outlineBorder,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            // Mini mock screen preview.
            Container(
              height: 96,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: previewBg, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue)),
                      const SizedBox(width: 6),
                      Container(width: 30, height: 6, decoration: BoxDecoration(color: previewMuted, borderRadius: BorderRadius.circular(3))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 26,
                    decoration: BoxDecoration(color: previewSurface, borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(width: 40, height: 6, decoration: BoxDecoration(color: previewText.withOpacity(0.7), borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 6),
                      Container(width: 22, height: 6, decoration: BoxDecoration(color: previewMuted, borderRadius: BorderRadius.circular(3))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(isLight ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: AppColors.textSecondary, size: 15),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                const Spacer(),
                _SelectionCircle(isSelected: isSelected),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCircle extends StatelessWidget {
  final bool isSelected;

  const _SelectionCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primaryBlue : Colors.transparent,
        border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.outlineBorder, width: 1.6),
      ),
      child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
    );
  }
}