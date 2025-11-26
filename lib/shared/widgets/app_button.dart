// 한국어 주석: 공통 버튼 위젯
/// Reusable button widget following app design guidelines with accessibility support

import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import 'accessibility_wrapper.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final String? semanticLabel;
  final String? hint;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.semanticLabel,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = _buildButton(context);

    if (width != null) {
      return SizedBox(width: width, child: buttonWidget);
    }

    return buttonWidget;
  }

  Widget _buildButton(BuildContext context) {
    final hasIcon = icon != null;
    final content = isLoading
        ? const SizedBox(
            height: AppSpacing.iconSize,
            width: AppSpacing.iconSize,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasIcon) ...[
                Icon(icon, size: AppSpacing.iconSizeSmall),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(text),
            ],
          );

    final buttonWidget = switch (type) {
      AppButtonType.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        ),
      AppButtonType.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: content,
        ),
      AppButtonType.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        ),
      AppButtonType.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        ),
    };

    // 접근성 래퍼 추가
    return AccessibleButton(
      semanticLabel: semanticLabel ?? text,
      hint: hint ?? (isLoading ? '로딩 중입니다' : null),
      onPressed: isLoading ? null : onPressed,
      child: buttonWidget,
    );
  }
}

