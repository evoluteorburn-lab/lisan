import 'package:flutter/material.dart';
import '../theme/ramadan_theme.dart';

/// Matte gold button with Ramadan Kareem styling
class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isActive;
  final IconData? icon;

  const GoldButton({
    Key? key,
    required this.text,
    this.onTap,
    this.isActive = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isActive
            ? RamadanTheme.goldButtonGradientActive
            : RamadanTheme.goldButtonGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: RamadanTheme.goldButtonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: RamadanTheme.textOnGold,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: RamadanTheme.buttonTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Language selection button with flag indicator
class LanguageButton extends StatelessWidget {
  final String language;
  final String flag;
  final bool isSelected;
  final VoidCallback? onTap;

  const LanguageButton({
    Key? key,
    required this.language,
    required this.flag,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? RamadanTheme.goldButtonGradientActive
            : RamadanTheme.goldButtonGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: RamadanTheme.goldButtonShadow,
        border: isSelected
            ? Border.all(
                color: RamadanTheme.goldLight,
                width: 2,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  flag,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 4),
                Text(
                  language,
                  style: RamadanTheme.buttonTextStyle.copyWith(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
