import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aturan standar teks aplikasi Servisin Aja.
///
/// - Small:  Poppins, 12
/// - Medium: Poppins, 14
class AppTextStyles {
  // ═══════════════════════════════════════
  // BASE STYLES
  // ═══════════════════════════════════════

  /// Font small — Poppins, 12
  static TextStyle small({
    Color color = Colors.black,
    FontWeight weight = FontWeight.w400,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: weight,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }

  /// Font medium — Poppins, 14
  static TextStyle medium({
    Color color = Colors.black,
    FontWeight weight = FontWeight.w400,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: weight,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }
}