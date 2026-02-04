String formatBytes(int bytes) {
  const suffixes = ['B','KB','MB','GB','TB'];
  double b = bytes.toDouble();
  int i = 0;
  while (b >= 1024 && i < suffixes.length - 1) { b /= 1024; i++; }
  final s = b >= 10 || i == 0 ? b.toStringAsFixed(0) : b.toStringAsFixed(1);
  return '$s ${suffixes[i]}';
}
