package com.example.mehrab

import android.os.Build
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge for backward compatibility with Android 15+ (API 35)
        if (Build.VERSION.SDK_INT >= 35) {
            enableEdgeToEdge()
        }
        super.onCreate(savedInstanceState)
    }
}