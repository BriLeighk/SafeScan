package com.example.spyware

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import android.util.Log
import java.io.ByteArrayOutputStream

// Android-side handling for app-scan page
object SpywareChannelHandler {
    private const val CHANNEL = "samples.flutter.dev/spyware"

    // Method call handler
    fun setup(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSpywareApps" -> {
                    val csvData = call.argument<List<List<String>>>("csvData")
                    if (csvData != null) {
                        val spywareApps = SpywareDetector.getDetectedSpywareApps(csvData)
                        result.success(spywareApps)
                    } else {
                        result.error("INVALID_ARGUMENT", "CSV data is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
        
} 