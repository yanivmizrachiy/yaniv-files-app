import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../core/constants/app_constants.dart';
import '../models/pdf_item.dart';

class PdfScanService {
  Future<List<PdfItem>> scanDownloadsForPdf() async {
    final root = Directory(AppConstants.downloadRoot);
    if (!await root.exists()) return [];

    final items = <PdfItem>[];
    await for (final ent in root.list(recursive: true, followLinks: false)) {
      if (ent is File) {
        final lower = ent.path.toLowerCase();
        if (lower.endsWith('.pdf')) {
          final stat = await ent.stat();
          items.add(PdfItem(
            path: ent.path,
            name: p.basename(ent.path),
            sizeBytes: stat.size,
            modified: stat.modified,
          ));
        }
      }
    }
    return items;
  }
}
