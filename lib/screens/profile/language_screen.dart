import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';

class _Language {
  final String name;
  final String nativeName;
  final String flag;

  const _Language({required this.name, required this.nativeName, required this.flag});
}

/// Language selection with search. Sub-screen of Profile — has a back
/// button.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const List<_Language> _languages = [
    _Language(name: 'English', nativeName: 'English', flag: '🇬🇧'),
    _Language(name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    _Language(name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    _Language(name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    _Language(name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    _Language(name: 'Swahili', nativeName: 'Kiswahili', flag: '🇰🇪'),
    _Language(name: 'Hausa', nativeName: 'Hausa', flag: '🇳🇬'),
    _Language(name: 'Yoruba', nativeName: 'Yorùbá', flag: '🇳🇬'),
  ];

  String _selected = 'English';
  String _query = '';

  List<_Language> get _filtered {
    if (_query.isEmpty) return _languages;
    return _languages.where((l) => l.name.toLowerCase().contains(_query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineBorder, width: 1)),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 19),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        cursorColor: AppColors.primaryBlue,
                        decoration: const InputDecoration(hintText: 'Search language', hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14), border: InputBorder.none, isDense: true),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: _filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final lang = _filtered[index];
                  final isSelected = lang.name == _selected;
                  return InkWell(
                    onTap: () => setState(() => _selected = lang.name),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.outlineBorder, width: isSelected ? 1.6 : 1),
                      ),
                      child: Row(
                        children: [
                          Text(lang.flag, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lang.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(lang.nativeName, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20),
                        ],
                      ),
                    ),
                  );
                },
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
          const Text('Language', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}