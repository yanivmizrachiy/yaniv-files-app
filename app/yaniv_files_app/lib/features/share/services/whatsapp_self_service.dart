import 'package:flutter/services.dart';

class WhatsAppSelfService {
  static const MethodChannel _ch = MethodChannel('yaniv_files/whatsapp');

  Future<bool> sendFilesToSelf(List<String> filePaths) async {
    try {
      final ok = await _ch.invokeMethod<bool>('sendToSelf', {'paths': filePaths});
      return ok == true;
    } catch (_) {
      return false;
    }
  }
}
