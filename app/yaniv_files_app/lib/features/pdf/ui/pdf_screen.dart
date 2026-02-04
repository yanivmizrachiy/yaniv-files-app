import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/permissions_service.dart';
import '../../../core/utils/formatters.dart';
import '../models/pdf_item.dart';
import '../services/pdf_scan_service.dart';
import '../../preview/ui/preview_screen.dart';
import 'package:share_plus/share_plus.dart';

enum PdfSort { byDateDesc, byNameAsc, bySizeDesc }

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});
  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final _perm = PermissionsService();
  final _svc = PdfScanService();

  List<PdfItem> _all = [];
  List<PdfItem> _filtered = [];
  final Set<String> _selected = {};
  bool _loading = true;
  String _q = '';
  PdfSort _sort = PdfSort.byDateDesc;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _perm.ensureAllFilesAccess(); // request if needed
    final items = await _svc.scanDownloadsForPdf();
    _all = items;
    _apply();
    setState(() => _loading = false);
  }

  void _apply() {
    var list = _all.where((x) => x.name.toLowerCase().contains(_q.toLowerCase())).toList();
    list.sort((a, b) {
      switch (_sort) {
        case PdfSort.byDateDesc: return b.modified.compareTo(a.modified);
        case PdfSort.byNameAsc: return a.name.compareTo(b.name);
        case PdfSort.bySizeDesc: return b.sizeBytes.compareTo(a.sizeBytes);
      }
    });
    _filtered = list;
  }

  void _toggleSelect(String path) {
    setState(() {
      if (_selected.contains(path)) {
        _selected.remove(path);
      } else {
        if (_selected.length >= AppConstants.maxSelection) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('אפשר לבחור עד ${AppConstants.maxSelection} קבצים')),
          );
          return;
        }
        _selected.add(path);
      }
    });
  }

  Future<void> _openPreview() async {
    final paths = _selected.toList();
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(paths: paths)),
    );
    if (changed == true) {
      // deletions may have happened
      await _load();
      _selected.clear();
    }
  }

  Future<void> _shareToOtherQuick() async {
    final paths = _selected.toList();
    if (paths.isEmpty) return;
    await Share.shareXFiles(paths.map((p) => XFile(p)).toList());
  }

  Future<void> _deleteSelectedQuick() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('מחיקה'),
        content: Text('למחוק ${_selected.length} קבצים?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ביטול')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('מחק')),
        ],
      ),
    );
    if (sure != true) return;
    for (final p in _selected.toList()) {
      try { await File(p).delete(); } catch (_) {}
    }
    await _load();
    _selected.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('בוצעה מחיקה')));
  }

  @override
  Widget build(BuildContext context) {
    final sel = _selected.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(sel > 0 ? 'PDF — נבחרו $sel' : 'PDF'),
          actions: [
            PopupMenuButton<PdfSort>(
              onSelected: (v) => setState(() { _sort = v; _apply(); }),
              itemBuilder: (_) => const [
                PopupMenuItem(value: PdfSort.byDateDesc, child: Text('מיון: תאריך (חדש→ישן)')),
                PopupMenuItem(value: PdfSort.byNameAsc, child: Text('מיון: שם (א-ת)')),
                PopupMenuItem(value: PdfSort.bySizeDesc, child: Text('מיון: גודל (גדול→קטן)')),
              ],
            ),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'חפש לפי שם קובץ…',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() { _q = v; _apply(); }),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final it = _filtered[i];
                        final checked = _selected.contains(it.path);
                        return ListTile(
                          leading: Checkbox(
                            value: checked,
                            onChanged: (_) => _toggleSelect(it.path),
                          ),
                          title: Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${formatBytes(it.sizeBytes)} • ${it.modified.toLocal()}'),
                          onLongPress: () => _toggleSelect(it.path),
                          onTap: () {
                            if (_selected.isNotEmpty) _toggleSelect(it.path);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar: sel == 0
            ? null
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed: _openPreview,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                      child: const Text('שליחה (תצוגה לפני שליחה)'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _shareToOtherQuick,
                            child: const Text('שלח למישהו אחר'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _deleteSelectedQuick,
                            child: const Text('מחק'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
