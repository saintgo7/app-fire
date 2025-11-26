// 한국어 주석: 접근성 테마 확장
/// Accessibility theme extensions for better usability

import 'dart:math' as math;
import 'package:flutter/material.dart';

class AccessibilityHelper {
  AccessibilityHelper._();

  /// 텍스트 크기 조절 지원을 위한 스타일 조정
  static TextStyle responsiveTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final scaleFactor = mediaQuery.textScaler.scale(1.0);

    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize != null
          ? baseStyle.fontSize! * scaleFactor.clamp(0.8, 1.5)
          : null,
    );
  }

  /// 고대비 모드 감지
  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// 접근성 모드 감지
  static bool isAccessibilityMode(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.boldText ||
           mediaQuery.textScaler.scale(1.0) > 1.0 ||
           mediaQuery.highContrast;
  }

  /// 색상 대비 비율 계산 (WCAG AA 기준: 4.5:1)
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _getLuminance(foreground);
    final bgLuminance = _getLuminance(background);
    
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance < bgLuminance ? fgLuminance : bgLuminance;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _getLuminance(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255) / 255.0;
    final g = (color.g * 255.0).round().clamp(0, 255) / 255.0;
    final b = (color.b * 255.0).round().clamp(0, 255) / 255.0;

    final rLinear = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gLinear = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bLinear = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
  }

  static double pow(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }
}

/// 접근성 정보를 제공하는 위젯
class AccessibilityInfo extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final bool? button;
  final bool? header;
  final bool? image;
  final bool? textField;

  const AccessibilityInfo({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.button,
    this.header,
    this.image,
    this.textField,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      header: header,
      image: image,
      textField: textField,
      child: child,
    );
  }
}

