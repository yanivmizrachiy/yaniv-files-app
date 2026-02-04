import 'dart:io';
import 'package:flutter/material.dart';
import '../../share/services/whatsapp_self_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

class PreviewScreen extends StatefulWidget {
  final List<String> paths; // up to 5
  const PreviewScreen({super.key, required this.paths});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late List<String> _paths;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _paths = List.of(widget.paths);
  }

  Future<void> _sendToSelf() async {
    setState(() => _busy = true);
    final svc = WhatsAppSelfService();
    final ok = await svc.sendFilesToSelf(_paths);
    setState(() => _busy = false);

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('לא הצלחתי לפתוח שליחה ישירה לוואטסאפ. נפתחת שליחה רגילה…')),
      );
      await _sendToOther();
    }
  }

  Future<void> _sendToOther() async {
    final xfiles = _paths.map((p) => XFile(p)).toList();
    await Share.shareXFiles(xfiles);
  }

  Future<void> _deleteSelected() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('מחיקה'),
        content: Text('למחוק ${_paths.length} קבצים?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ביטול')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('מחק')),
        ],
      ),
    );
    if (sure != true) return;

    setState(() => _busy = true);
    for (final p in List.of(_paths)) {
      try { await File(p).delete(); } catch (_) {}
    }
    setState(() => _busy = false);

    if (!mounted) return;
    Navigator.pop(context, true); // signal that deletions happened
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('תצוגה לפני שליחה')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('אפשר לבחור עד ${AppConstants.maxSelection} קבצים. כרגע: ${_paths.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _paths.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final path = _paths[i];
                  final name = path.split('/').last;
                  final f = File(path);
                  return FutureBuilder<FileStat>(
                    future: f.stat(),
                    builder: (ctx, snap) {
                      final size = snap.hasData ? formatBytes(snap.data!.size) : '';
                      return ListTile(
                        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: size.isEmpty ? null : Text(size),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _busy ? null : () => setState(() => _paths.removeAt(i)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: (_busy || _paths.isEmpty) ? null : _sendToSelf,
                    icon: const Icon(Icons.send),
                    label: Text('שלח ל-WhatsApp שלי (${AppConstants.waSelfFullPhone})'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: (_busy || _paths.isEmpty) ? null : _sendToOther,
                    child: const Text('שלח למישהו אחר'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: (_busy || _paths.isEmpty) ? null : _deleteSelected,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('מחק את הנבחרים'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
