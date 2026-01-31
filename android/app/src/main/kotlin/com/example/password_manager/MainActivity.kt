package com.example.password_manager

import io.flutter.embedding.android.FlutterFragmentActivity
import android.view.WindowManager.LayoutParams
import android.os.Bundle

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE)
    }
}
