import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../../../shared/models/building.dart';
import '../../../../shared/models/inspection.dart';
import '../../../../shared/models/checklist_item.dart';
import '../../../../shared/models/photo.dart';

class ReportGenerator {
  Future<Uint8List> generate({
    required Building building,
    required Inspection inspection,
    required List<ChecklistItem> checklist,
    required List<InspectionPhoto> photos,
  }) async {
    final doc = pw.Document();

    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFmt.format(inspection.date);

    // 사진 위젯 생성
    final photoWidgets = <pw.Widget>[];
    for (final p in photos) {
      try {
        final bytes = await File(p.path).readAsBytes();
        final image = pw.MemoryImage(bytes);
        photoWidgets.add(pw.Container(
          width: 140,
          height: 140,
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          child: pw.Image(image, fit: pw.BoxFit.cover),
        ));
      } catch (_) {
        // ignore
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(building, inspection, formattedDate),
          pw.SizedBox(height: 16),
          _buildSummaryTable(checklist),
          pw.SizedBox(height: 16),
          _buildChecklistDetails(checklist),
          if (photoWidgets.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _buildPhotoSection(photoWidgets),
          ],
          pw.SizedBox(height: 32),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('점검자 서명: ______________________'),
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHeader(Building building, Inspection inspection, String formattedDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('소방시설 점검 결과 보고서',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('건축물: ${building.name}'),
        pw.Text('주소: ${building.address}'),
        pw.Text('점검 일시: $formattedDate'),
        pw.Text('점검 유형: ${inspection.type == InspectionType.monthly ? '작동기능점검' : '종합정밀점검'}'),
      ],
    );
  }

  pw.Widget _buildSummaryTable(List<ChecklistItem> checklist) {
    final total = checklist.length;
    final normal = checklist.where((e) => e.status == ChecklistStatus.normal).length;
    final defective = checklist.where((e) => e.status == ChecklistStatus.defective).length;
    final na = checklist.where((e) => e.status == ChecklistStatus.notApplicable).length;

    return pw.Table.fromTextArray(
      headerAlignment: pw.Alignment.center,
      headers: ['총 항목', '정상', '불량', '해당없음'],
      data: [
        [total.toString(), normal.toString(), defective.toString(), na.toString()],
      ],
    );
  }

  pw.Widget _buildChecklistDetails(List<ChecklistItem> checklist) {
    return pw.Table.fromTextArray(
      headers: ['항목', '상태', '메모'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      data: checklist.map((e) {
        String status;
        switch (e.status) {
          case ChecklistStatus.normal:
            status = '정상';
            break;
          case ChecklistStatus.defective:
            status = '불량';
            break;
          case ChecklistStatus.notApplicable:
            status = '해당없음';
            break;
          default:
            status = '-';
        }
        return [e.title, status, e.memo];
      }).toList(),
      cellAlignment: pw.Alignment.topLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(3),
      },
    );
  }

  pw.Widget _buildPhotoSection(List<pw.Widget> photoWidgets) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('첨부 사진',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Wrap(spacing: 8, runSpacing: 8, children: photoWidgets),
      ],
    );
  }
} 