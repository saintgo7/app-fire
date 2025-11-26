// 한국어 주석: PDF 보고서 미리보기 화면
/// Displays PDF preview and allows sharing/printing.

import 'dart:typed_data';
import 'dart:io';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/report_provider.dart';
import '../../reporting/data/services/report_generator.dart';
import '../../../inspection/domain/repositories/inspection_repository.dart';
import '../../../inspection/data/repositories/inspection_repository_impl.dart';
import '../../../inspection/data/datasources/building_dao.dart';
import '../../../inspection/data/datasources/inspection_dao.dart';
import '../../../inspection/data/datasources/photo_dao.dart';
import '../../../inspection/presentation/providers/inspection_form_provider.dart';
import '../../../shared/models/checklist_item.dart';

import '../../../shared/models/inspection.dart';

class ReportScreen extends StatelessWidget {
  // inspection 객체를 arguments로 받는다
  final Inspection inspection;
  const ReportScreen({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    // Repository 임시 직접 인스턴스 — 추후 DI 적용
    final repo = InspectionRepositoryImpl(
      buildingDao: BuildingDao(),
      inspectionDao: InspectionDao(),
      photoDao: PhotoDao(),
    );

    return FutureBuilder(
      future: _initProvider(context, repo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ChangeNotifierProvider.value(
          value: snapshot.data!,
          child: const _ReportBody(),
        );
      },
    );
  }

  Future<ReportProvider> _initProvider(
    BuildContext context,
    InspectionRepository repo,
  ) async {
    // Fetch required data
    final building = await repo.fetchBuilding(inspection.buildingId);
    final photos = await repo.fetchPhotos(inspection.id!);
    // TODO: Load checklist from storage once persisted. For now use empty.
    final checklist = context.mounted
        ? context.read<InspectionFormProvider?>()?.items ?? <ChecklistItem>[]
        : <ChecklistItem>[];

    final provider = ReportProvider(generator: ReportGenerator());
    await provider.generateReport(
      building: building!,
      inspection: inspection,
      checklist: checklist,
      photos: photos,
    );
    return provider;
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('보고서')),
        body: Center(child: Text('오류: ${provider.error}')),
      );
    }
    final pdfData = provider.pdfBytes ?? Uint8List(0);

    return Scaffold(
      appBar: AppBar(title: const Text('보고서 미리보기')),
      body: PdfPreview(
        build: (format) => Future.value(pdfData),
        canPrint: true,
        canChangePageFormat: false,
        canShare: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.share),
        label: const Text('공유'),
        onPressed: () async {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/report.pdf');
          await file.writeAsBytes(pdfData);
          await share_plus.Share.shareXFiles([share_plus.XFile(file.path)], text: '소방시설 점검 보고서');
        },
      ),
    );
  }
} 