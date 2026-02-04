package com.yaniv.files

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {

  private val CHANNEL = "yaniv_files/whatsapp"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "sendToSelf" -> {
          val args = call.arguments as? Map<*, *>
          val paths = (args?.get("paths") as? List<*>)?.filterIsInstance<String>() ?: emptyList()
          val ok = trySendToWhatsAppSelf(paths)
          result.success(ok)
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun trySendToWhatsAppSelf(paths: List<String>): Boolean {
    if (paths.isEmpty()) return false

    // Ensure "All files access" is granted on Android 11+ (user must enable in settings)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      if (!android.os.Environment.isExternalStorageManager()) {
        try {
          val i = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
          i.data = Uri.parse("package:$packageName")
          startActivity(i)
        } catch (_: Exception) {}
        return false
      }
    }

    val uris = ArrayList<Uri>()
    for (p in paths) {
      val f = File(p)
      if (!f.exists()) continue
      val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", f)
      uris.add(uri)
    }
    if (uris.isEmpty()) return false

    val intent = Intent()
    intent.action = if (uris.size == 1) Intent.ACTION_SEND else Intent.ACTION_SEND_MULTIPLE
    intent.type = "*/*"
    intent.`package` = "com.whatsapp"

    // Direct to specific chat (jid)
    val jid = "972523748115@s.whatsapp.net"
    intent.putExtra("jid", jid)

    if (uris.size == 1) {
      intent.putExtra(Intent.EXTRA_STREAM, uris[0])
    } else {
      intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris)
    }
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

    return try {
      startActivity(intent)
      true
    } catch (_: Exception) {
      false
    }
  }
}
