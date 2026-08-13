import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'otp_verification_screen.dart';
import 'package:zelyo_1/screens/auth/login_screen.dart';

/// Minimal country-code entry for the phone dropdown.
/// Extend this list (or swap in a package like `country_code_picker`)
/// if you need broader coverage.
class _CountryCode {
  final String flag;
  final String dialCode;
  final String name;

  const _CountryCode(this.flag, this.dialCode, this.name);
}

const List<_CountryCode> _countryCodes = [
  _CountryCode('🇳🇬', '+234', 'Nigeria'),
  _CountryCode('🇺🇸', '+1', 'United States'),
  _CountryCode('🇬🇧', '+44', 'United Kingdom'),
  _CountryCode('🇨🇦', '+1', 'Canada'),
  _CountryCode('🇬🇭', '+233', 'Ghana'),
  _CountryCode('🇰🇪', '+254', 'Kenya'),
  _CountryCode('🇿🇦', '+27', 'South Africa'),
  _CountryCode('🇮🇳', '+91', 'India'),
  _CountryCode('🇦🇺', '+61', 'Australia'),
  _CountryCode('🇩🇪', '+49', 'Germany'),
];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  _CountryCode _selectedCountry = _countryCodes.first;
  bool _obscurePassword = true;
  bool _passwordTouched = false;

  static const int _minPasswordLength = 8;
  static final RegExp _hasLetter = RegExp(r'[A-Za-z]');
  static final RegExp _hasDigit = RegExp(r'[0-9]');
  static final RegExp _hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]+=~`/;]');

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isPasswordValid {
    final value = _passwordController.text;
    return value.length >= _minPasswordLength &&
        _hasLetter.hasMatch(value) &&
        _hasDigit.hasMatch(value) &&
        _hasSymbol.hasMatch(value);
  }

  bool get _showPasswordError => _passwordTouched && !_isPasswordValid;

  void _onPasswordChanged(String value) {
    setState(() => _passwordTouched = value.isNotEmpty);
  }

  void _onCreateAccountTap() {
    setState(() => _passwordTouched = true);

    // TODO: run your real form validation (name/email/phone/password)
    // and create the account on your backend before navigating on.
    if (!_isPasswordValid) return;

    // Email is the OTP channel — the phone/country-code fields collected
    // above are stored with the account but are not used for this step.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool isError = false,
  }) {
    OutlineInputBorder border(Color color, {double width = 1.2}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
      prefixIcon: Icon(
        prefixIcon,
        color: isError ? Colors.redAccent : AppColors.textMuted,
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: border(isError ? Colors.redAccent : AppColors.outlineBorder),
      enabledBorder:
          border(isError ? Colors.redAccent : AppColors.outlineBorder),
      focusedBorder: border(
        isError ? Colors.redAccent : AppColors.primaryBlue,
        width: 1.6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ----- Gradient orb, top-left corner -----
          Positioned(
            top: -90,
            left: -90,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlueLight,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ----- Main content -----
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // ----- Logo -----
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.primaryBlueLight,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ----- Headline -----
                  const Text(
                    'Create account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Sign up to get started with Zelyo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ----- 1. Full name field -----
                  TextField(
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    cursorColor: AppColors.primaryBlue,
                    decoration: _fieldDecoration(
                      hint: 'Full name',
                      prefixIcon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ----- 2. Email field -----
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    cursorColor: AppColors.primaryBlue,
                    decoration: _fieldDecoration(
                      hint: 'Email',
                      prefixIcon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ----- 3 & 4. Country code dropdown + phone number, same row -----
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country dial-code dropdown
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.outlineBorder, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<_CountryCode>(
                            value: _selectedCountry,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.textMuted, size: 20),
                            dropdownColor: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            selectedItemBuilder: (context) {
                              return _countryCodes.map((country) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(country.flag,
                                        style: const TextStyle(fontSize: 17)),
                                    const SizedBox(width: 6),
                                    Text(
                                      country.dialCode,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                            items: _countryCodes.map((country) {
                              return DropdownMenuItem<_CountryCode>(
                                value: country,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(country.flag,
                                        style: const TextStyle(fontSize: 17)),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${country.name}  ${country.dialCode}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedCountry = value);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Phone number field
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 15),
                          cursorColor: AppColors.primaryBlue,
                          decoration: _fieldDecoration(
                            hint: 'Phone number',
                            prefixIcon: Icons.phone_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ----- 5. Password field -----
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _onPasswordChanged,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    cursorColor: AppColors.primaryBlue,
                    decoration: _fieldDecoration(
                      hint: 'Create password',
                      prefixIcon: Icons.lock_outline,
                      isError: _showPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _showPasswordError
                              ? Colors.redAccent
                              : AppColors.textMuted,
                          size: 21,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    // controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _onPasswordChanged,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    cursorColor: AppColors.primaryBlue,
                    decoration: _fieldDecoration(
                      hint: 'Confirm password',
                      prefixIcon: Icons.lock_outline,
                      isError: _showPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _showPasswordError
                              ? Colors.redAccent
                              : AppColors.textMuted,
                          size: 21,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Password requirement helper text
                  Text(
                    _showPasswordError
                        ? 'Password must be at least 8 characters and include letters, numbers, and symbols.'
                        : 'Use 8+ characters with letters, numbers, and symbols.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _showPasswordError
                          ? Colors.redAccent
                          : AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ----- Create account button -----
                  SizedBox(
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

                  const SizedBox(height: 24),

                  // ----- Login prompt -----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style:
                            TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}