import 'package:flutter/material.dart';

/// A single virtual card — one per currency, each with its own gradient
/// and decorative pattern so they're visually distinct in the carousel.
class VirtualCardData {
  final String code;
  final String flag;
  final String symbol;
  final List<Color> gradientColors;
  final CardPattern pattern;
  final String maskedNumber; // "•••• •••• •••• 4821" — safe to always show
  final String fullNumber;   // only revealed after PIN verification
  final String expiry;
  final String cvv;
  final String holderName;

  const VirtualCardData({
    required this.code,
    required this.flag,
    required this.symbol,
    required this.gradientColors,
    required this.pattern,
    required this.maskedNumber,
    required this.fullNumber,
    required this.expiry,
    required this.cvv,
    required this.holderName,
  });
}

/// Decorative background pattern drawn behind each card's content —
/// gives each currency's card a distinct texture, not just a color.
enum CardPattern { diagonalLines, dots, waves, grid, rings }

// TODO: replace with the user's real issued virtual cards.
const List<VirtualCardData> sampleVirtualCards = [
  VirtualCardData(
    code: 'NGN',
    flag: '🇳🇬',
    symbol: '₦',
    gradientColors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    pattern: CardPattern.diagonalLines,
    maskedNumber: '•••• •••• •••• 4821',
    fullNumber: '5399 1187 4402 4821',
    expiry: '09/29',
    cvv: '482',
    holderName: 'AMARA JOHNSON',
  ),
  VirtualCardData(
    code: 'USD',
    flag: '🇺🇸',
    symbol: '\$',
    gradientColors: [Color(0xFF2563FF), Color(0xFF1E40C7)],
    pattern: CardPattern.dots,
    maskedNumber: '•••• •••• •••• 7734',
    fullNumber: '4916 2280 9917 7734',
    expiry: '11/28',
    cvv: '917',
    holderName: 'AMARA JOHNSON',
  ),
  VirtualCardData(
    code: 'EUR',
    flag: '🇪🇺',
    symbol: '€',
    gradientColors: [Color(0xFF7C5CFC), Color(0xFF4C1D95)],
    pattern: CardPattern.waves,
    maskedNumber: '•••• •••• •••• 5502',
    fullNumber: '5218 8834 6630 5502',
    expiry: '03/29',
    cvv: '663',
    holderName: 'AMARA JOHNSON',
  ),
  VirtualCardData(
    code: 'GBP',
    flag: '🇬🇧',
    symbol: '£',
    gradientColors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
    pattern: CardPattern.grid,
    maskedNumber: '•••• •••• •••• 4402',
    fullNumber: '5310 7719 2588 4402',
    expiry: '07/28',
    cvv: '258',
    holderName: 'AMARA JOHNSON',
  ),
  VirtualCardData(
    code: 'JPY',
    flag: '🇯🇵',
    symbol: '¥',
    gradientColors: [Color(0xFFF59E0B), Color(0xFFB45309)],
    pattern: CardPattern.rings,
    maskedNumber: '•••• •••• •••• 1187',
    fullNumber: '5044 3390 5522 1187',
    expiry: '01/30',
    cvv: '552',
    holderName: 'AMARA JOHNSON',
  ),
];