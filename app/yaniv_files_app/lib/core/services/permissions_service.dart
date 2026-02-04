import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> ensureAllFilesAccess() async {
    // On Android 11+ this maps to MANAGE_EXTERNAL_STORAGE.
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) return true;
    final res = await Permission.manageExternalStorage.request();
    return res.isGranted;
  }
}
