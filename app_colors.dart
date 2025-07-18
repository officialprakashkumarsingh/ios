import 'package:flutter/material.dart';

/// Colors based on the Atom One Light theme.
class AppColors {
  static const Color _background = Color(0xFFFAFAFA);
  static const Color _surface = Colors.white;
  static const Color _primaryText = Color(0xFF383A42);
  static const Color _secondaryText = Color(0xFF686B77);

  static Color background(BuildContext context) => _background;
  static Color surface(BuildContext context) => _surface;
  static Color primaryText(BuildContext context) => _primaryText;
  static Color secondaryText(BuildContext context) => _secondaryText;
  static Color icon(BuildContext context) => _primaryText;
}
