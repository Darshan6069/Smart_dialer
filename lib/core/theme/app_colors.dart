import 'package:flutter/material.dart';

class AppColors {
  // Light Palette (Clean Premium Minimalist Theme)
  static const Color background = Color(0xFFF6F8FC); // Ultra light slate
  static const Color surface = Color(0xFFFFFFFF); // Pure crisp white
  static const Color cardBg = Color(0xFFEFF2F8); // Gentle highlight light grey
  
  // Primary & Accent Cyber Colors
  static const Color primary = Color(0xFF2962FF); // Rich royal blue
  static const Color secondary = Color(0xFF0091EA); // Vivid Cyan Accent
  static const Color accent = Color(0xFF6200EA); // Vibrant Purple
  
  // Semantic Colors
  static const Color success = Color(0xFF00C853); // Premium green
  static const Color error = Color(0xFFD50000); // Premium red
  static const Color warning = Color(0xFFFFD600); // Amber warning
  static const Color info = Color(0xFF0091EA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E2230); // Charcoal for high readability
  static const Color textSecondary = Color(0xFF5E677C); // Modern grey
  static const Color textMuted = Color(0xFF8F9BB3); // Soft muted grey
  static const Color textDisabled = Color(0xFFC5CBD9);
  
  // Borders and Dividers
  static const Color border = Color(0xFFE2E6F0); // Delicate borders
  static const Color divider = Color(0xFFECEFF5);
  
  // Shimmer and Overlay Colors
  static const Color shimmerBase = Color(0xFFECEFF5);
  static const Color shimmerHighlight = Color(0xFFF6F8FC);
  static const Color overlay = Color(0x22000000);
  
  // Gradient Definitions for Premium Visuals
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient recordingGradient = LinearGradient(
    colors: [error, Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
