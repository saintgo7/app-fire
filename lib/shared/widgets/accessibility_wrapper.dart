// 한국어 주석: 접근성 래퍼 위젯
/// Accessibility wrapper widget for better screen reader support and usability

import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

/// 접근성을 개선한 버튼 래퍼
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? hint;
  final bool excludeSemantics;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    required this.semanticLabel,
    this.hint,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}

/// 접근성을 개선한 카드 래퍼
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final VoidCallback? onTap;

  const AccessibleCard({
    super.key,
    required this.child,
    this.semanticLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = child;

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }
}

/// 최소 터치 영역을 보장하는 위젯
class MinimumTouchTarget extends StatelessWidget {
  final Widget child;
  final double minSize;

  const MinimumTouchTarget({
    super.key,
    required this.child,
    this.minSize = AppSpacing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: minSize,
      height: minSize,
      child: Center(child: child),
    );
  }
}

/// 접근성을 개선한 아이콘 버튼
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final double? iconSize;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: tooltip,
      button: true,
      enabled: onPressed != null,
      child: MinimumTouchTarget(
        child: IconButton(
          icon: Icon(icon, size: iconSize),
          onPressed: onPressed,
          tooltip: tooltip ?? semanticLabel,
        ),
      ),
    );
  }
}

