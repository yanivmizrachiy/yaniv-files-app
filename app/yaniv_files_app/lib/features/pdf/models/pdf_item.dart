class PdfItem {
  final String path;
  final String name;
  final int sizeBytes;
  final DateTime modified;

  PdfItem({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.modified,
  });
}
