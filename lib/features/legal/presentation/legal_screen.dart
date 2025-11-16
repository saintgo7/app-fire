// 한국어 주석: 소방 관련 법령 정보 화면
/// Fire safety legal information screen with categorized laws and regulations.

import 'package:flutter/material.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  String _selectedCategory = '전체';

  final List<String> _categories = [
    '전체',
    '소방시설법',
    '화재예방법',
    '위험물안전법',
    '시행령',
    '시행규칙',
  ];

  final List<LegalItem> _legalItems = [
    LegalItem(
      title: '소방시설 설치 및 관리에 관한 법률',
      category: '소방시설법',
      date: '2023-01-01',
      summary: '소방시설의 설치·관리 및 소방대상물의 안전관리에 필요한 사항을 정함',
      isImportant: true,
    ),
    LegalItem(
      title: '화재예방, 소방시설 설치·유지 및 안전관리에 관한 법률',
      category: '화재예방법',
      date: '2022-12-01',
      summary: '화재와 재난·재해, 그 밖의 위급한 상황으로부터 국민의 생명·신체 및 재산을 보호',
      isImportant: true,
    ),
    LegalItem(
      title: '위험물안전관리법',
      category: '위험물안전법',
      date: '2023-03-15',
      summary: '위험물의 저장·취급 및 운반과 이에 따른 안전관리에 관한 사항을 규정',
      isImportant: false,
    ),
    LegalItem(
      title: '소방시설법 시행령',
      category: '시행령',
      date: '2023-02-01',
      summary: '소방시설 설치 및 관리에 관한 법률 시행령',
      isImportant: false,
    ),
    LegalItem(
      title: '소방시설법 시행규칙',
      category: '시행규칙',
      date: '2023-02-15',
      summary: '소방시설 설치 및 관리에 관한 법률 시행규칙',
      isImportant: false,
    ),
    LegalItem(
      title: '특정소방대상물의 소방시설 설치기준',
      category: '시행규칙',
      date: '2023-01-20',
      summary: '건축물 등급별 소방시설 설치 기준 및 유지관리 방법',
      isImportant: true,
    ),
  ];

  List<LegalItem> get _filteredItems {
    if (_selectedCategory == '전체') {
      return _legalItems;
    }
    return _legalItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('법령 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '검색',
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),

          // Legal Items List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '해당 카테고리에 법령이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _LegalItemCard(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegalItemCard extends StatelessWidget {
  final LegalItem item;

  const _LegalItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () {
          _showLegalDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (item.isImportant)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '중요',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    item.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegalDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(item.category),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '시행일: ${item.date}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    '법령 개요',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.summary),
                  const SizedBox(height: 24),
                  Text(
                    '주요 내용',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '이 법령의 상세 내용은 국가법령정보센터에서 확인하실 수 있습니다.\n\n'
                    '• 소방시설의 종류 및 설치 기준\n'
                    '• 소방시설의 유지관리 기준\n'
                    '• 안전관리자 선임 기준\n'
                    '• 점검 및 검사 절차',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Open law.go.kr or related website
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('국가법령정보센터에서 보기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LegalItem {
  final String title;
  final String category;
  final String date;
  final String summary;
  final bool isImportant;

  LegalItem({
    required this.title,
    required this.category,
    required this.date,
    required this.summary,
    this.isImportant = false,
  });
}
