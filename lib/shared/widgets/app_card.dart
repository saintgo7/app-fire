// 한국어 주석: 공통 카드 위젯
/// Reusable card widget following app design guidelines with accessibility support

import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import 'accessibility_wrapper.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final String? semanticLabel;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      elevation: elevation,
      margin: margin ?? const EdgeInsets.all(AppSpacing.cardMargin),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );

    Widget result = card;
    
    if (onTap != null) {
      result = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    // 접근성 래퍼 추가
    if (semanticLabel != null) {
      result = AccessibleCard(
        semanticLabel: semanticLabel,
        onTap: onTap,
        child: result,
      );
    }

    return result;
  }
}

