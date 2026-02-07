package com.example.password_manager

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.PersistableBundle
import android.view.WindowManager.LayoutParams
import android.os.Bundle

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "klypt/clipboard"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "writeSecure") {
                val text = call.arguments as String
                val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                val clip = ClipData.newPlainText("Sensitive", text)
                
                // Android 13 (API 33) Feature: Mark sensitive content to hide from clipboard overlay
                if (Build.VERSION.SDK_INT >= 33) {
                    clip.description.extras = PersistableBundle().apply {
                        putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true)
                    }
                }
                
                clipboard.setPrimaryClip(clip)
                result.success(null)
            } else if (call.method == "clearSecure") {
                val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                if (Build.VERSION.SDK_INT >= 28) {
                    // API 28+ supports explicit clearing without triggering "Copied" toast
                    clipboard.clearPrimaryClip()
                } else {
                    // Fallback for older Android (might show toast, but unavoidable)
                    clipboard.setPrimaryClip(ClipData.newPlainText("", ""))
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
