// 한국어 주석: 점검 상태 표시 칩 위젯
/// Status chip widget for inspection status display

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/checklist_item.dart';

class StatusChip extends StatelessWidget {
  final ChecklistStatus status;
  final bool selected;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.status,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(_getStatusLabel(status)),
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      selectedColor: _getStatusColor(status).withOpacity(0.2),
      checkmarkColor: _getStatusColor(status),
      labelStyle: TextStyle(
        color: selected ? _getStatusColor(status) : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? _getStatusColor(status) : Colors.grey,
        width: selected ? 2 : 1,
      ),
    );
  }

  Color _getStatusColor(ChecklistStatus status) {
    switch (status) {
      case ChecklistStatus.normal:
        return AppColors.statusNormal;
      case ChecklistStatus.defective:
        return AppColors.statusDefective;
      case ChecklistStatus.notApplicable:
        return AppColors.statusNotApplicable;
    }
  }

  String _getStatusLabel(ChecklistStatus status) {
    switch (status) {
      case ChecklistStatus.normal:
        return '정상';
      case ChecklistStatus.defective:
        return '불량';
      case ChecklistStatus.notApplicable:
        return '해당없음';
    }
  }
}

