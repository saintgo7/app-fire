// 한국어 주석: 점검 체크리스트 화면
/// Screen for performing fire safety inspections checklist UI.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'providers/inspection_form_provider.dart';
import '../../../shared/models/checklist_item.dart';

class InspectionScreen extends StatelessWidget {
  const InspectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultItems = [
      ChecklistItem(title: '소화기: 위치 표시'),
      ChecklistItem(title: '소화기: 압력 게이지'),
      ChecklistItem(title: '소화기: 안전핀 상태'),
      ChecklistItem(title: '옥내소화전: 호스 상태'),
      ChecklistItem(title: '옥내소화전: 밸브 개폐'),
      ChecklistItem(title: '옥내소화전: 방수압'),
      ChecklistItem(title: '자동화재탐지: 감지기 상태'),
      ChecklistItem(title: '자동화재탐지: 수신기 표시등'),
      ChecklistItem(title: '스프링클러: 헤드 상태'),
      ChecklistItem(title: '스프링클러: 배관 압력'),
      ChecklistItem(title: '스프링클러: 물공급'),
    ];

    return ChangeNotifierProvider(
      create: (_) => InspectionFormProvider(defaultItems),
      child: const _InspectionFormBody(),
    );
  }
}

class _InspectionFormBody extends StatelessWidget {
  const _InspectionFormBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InspectionFormProvider>();
    final picker = ImagePicker();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '점검 진행',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          // 임시 저장 버튼
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: '임시 저장',
            onPressed: () async {
              await provider.saveDraft();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '임시 저장되었습니다',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppColors.statusGood,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행률 표시
          _buildProgressHeader(context, provider),

          // 체크리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];
                return _buildInspectionCard(
                  context,
                  item,
                  index,
                  provider,
                  picker,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 점검 완료 및 저장
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '점검 완료 및 제출',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.primaryLight,
            ),
          );
        },
        icon: const Icon(Icons.check_circle),
        label: Text(
          '점검 완료',
          style: AppTextStyles.labelLarge,
        ),
      ),
    );
  }

  /// 진행률 헤더
  Widget _buildProgressHeader(
    BuildContext context,
    InspectionFormProvider provider,
  ) {
    final completedCount =
        provider.items.where((item) => item.status != null).length;
    final totalCount = provider.items.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '점검 진행률',
                style: AppTextStyles.titleSmall,
              ),
              Text(
                '$completedCount / $totalCount',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: provider.progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariantLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                provider.progress == 1.0
                    ? AppColors.statusGood
                    : AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 점검 항목 카드
  Widget _buildInspectionCard(
    BuildContext context,
    ChecklistItem item,
    int index,
    InspectionFormProvider provider,
    ImagePicker picker,
  ) {
    // 상태별 색상
    Color? statusColor;
    if (item.status == ChecklistStatus.normal) {
      statusColor = AppColors.statusGood;
    } else if (item.status == ChecklistStatus.defective) {
      statusColor = AppColors.statusDefective;
    } else if (item.status == ChecklistStatus.notApplicable) {
      statusColor = AppColors.statusPending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: item.status != null ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: statusColor != null
            ? BorderSide(color: statusColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 및 번호
            Row(
              children: [
                // 번호 뱃지
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor?.withOpacity(0.1) ??
                        AppColors.surfaceVariantLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: statusColor ?? AppColors.onSurfaceVariantLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: AppTextStyles.inspectionItemTitle,
                  ),
                ),
                // 상태 아이콘
                if (item.status != null)
                  Icon(
                    item.status == ChecklistStatus.normal
                        ? Icons.check_circle
                        : item.status == ChecklistStatus.defective
                            ? Icons.error
                            : Icons.remove_circle,
                    color: statusColor,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 상태 선택 칩
            Text(
              '상태 선택',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ChecklistStatus.values.map((status) {
                final selected = item.status == status;
                return ChoiceChip(
                  label: Text(_statusLabel(status)),
                  selected: selected,
                  onSelected: (_) => provider.setStatus(index, status),
                  selectedColor: _getStatusColor(status).withOpacity(0.2),
                  checkmarkColor: _getStatusColor(status),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: selected
                        ? _getStatusColor(status)
                        : AppColors.onSurfaceLight,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 사진 섹션
            Text(
              '사진 (${item.photos.length})',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // 카메라 버튼
                OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: const Text('촬영'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () async {
                    final photo = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 90,
                    );
                    if (photo != null) {
                      provider.addPhoto(index, photo);
                    }
                  },
                ),
                const SizedBox(width: 8),
                // 갤러리 버튼
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library, size: 20),
                  label: const Text('갤러리'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () async {
                    final photo = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 90,
                    );
                    if (photo != null) {
                      provider.addPhoto(index, photo);
                    }
                  },
                ),
              ],
            ),
            if (item.photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.photos.length,
                  itemBuilder: (context, photoIndex) {
                    final photo = item.photos[photoIndex];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(photo.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),

            // 메모 입력
            TextField(
              decoration: InputDecoration(
                hintText: '메모 입력 (선택)',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariantLight.withOpacity(0.6),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariantLight.withOpacity(0.5),
              ),
              maxLines: 3,
              style: AppTextStyles.bodyMedium,
              onChanged: (v) => provider.updateMemo(index, v),
              controller: TextEditingController(text: item.memo)
                ..selection = TextSelection.collapsed(
                  offset: item.memo.length,
                ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(ChecklistStatus status) {
    switch (status) {
      case ChecklistStatus.normal:
        return '정상';
      case ChecklistStatus.defective:
        return '불량';
      case ChecklistStatus.notApplicable:
        return '해당없음';
    }
  }

  Color _getStatusColor(ChecklistStatus status) {
    switch (status) {
      case ChecklistStatus.normal:
        return AppColors.statusGood;
      case ChecklistStatus.defective:
        return AppColors.statusDefective;
      case ChecklistStatus.notApplicable:
        return AppColors.statusPending;
    }
  }
}
