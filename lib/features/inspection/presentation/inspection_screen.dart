// 한국어 주석: 점검 체크리스트 화면
/// Screen for performing fire safety inspections checklist UI.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'providers/inspection_form_provider.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/models/checklist_item.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/app_card.dart';

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
      appBar: AppBar(
        title: const Text('점검 진행'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '임시 저장',
            onPressed: () async {
              await provider.saveDraft();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('임시 저장되었습니다')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: provider.progress),
          Expanded(
            child: ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${index + 1}/${provider.items.length}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: ChecklistStatus.values.map((status) {
                          final selected = item.status == status;
                          return StatusChip(
                            status: status,
                            selected: selected,
                            onTap: () => provider.setStatus(index, status),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // 사진 섹션
                      Text(
                        '사진',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final photo = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 90,
                              );
                              if (photo != null && context.mounted) {
                                provider.addPhoto(index, photo);
                              }
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('촬영'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final photo = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 90,
                              );
                              if (photo != null && context.mounted) {
                                provider.addPhoto(index, photo);
                              }
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('갤러리'),
                          ),
                        ],
                      ),
                      if (item.photos.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: item.photos.length,
                            itemBuilder: (context, photoIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.sm),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(item.photos[photoIndex].path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        color: Colors.white,
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                          padding: const EdgeInsets.all(4),
                                        ),
                                        onPressed: () {
                                          provider.removePhoto(index, photoIndex);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: '메모',
                          hintText: '메모를 입력하세요',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (v) => provider.updateMemo(index, v),
                        controller: TextEditingController(text: item.memo)
                          ..selection = TextSelection.collapsed(
                            offset: item.memo.length,
                          ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

} 