// 한국어 주석: 점검 체크리스트 화면
/// Screen for performing fire safety inspections checklist UI.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ChecklistStatus.values.map((status) {
                            final selected = item.status == status;
                            return ChoiceChip(
                              label: Text(_statusLabel(status)),
                              selected: selected,
                              onSelected: (_) =>
                                  provider.setStatus(index, status),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () async {
                                final photo = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 90);
                                if (photo != null) {
                                  provider.addPhoto(index, photo);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.photo_library),
                              onPressed: () async {
                                final photo = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 90);
                                if (photo != null) {
                                  provider.addPhoto(index, photo);
                                }
                              },
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 60,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: item.photos
                                      .map((p) => Padding(
                                            padding:
                                                const EdgeInsets.only(right: 4),
                                            child: Image.file(
                                              File(p.path),
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              hintText: '메모 입력', border: OutlineInputBorder()),
                          maxLines: null,
                          onChanged: (v) => provider.updateMemo(index, v),
                          controller: TextEditingController(text: item.memo)
                            ..selection = TextSelection.collapsed(
                                offset: item.memo.length),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
} 