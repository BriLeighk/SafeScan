package com.example.spyware

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.example.spyware.AppContextHolder

object SettingsChannelHandler {
    private const val CHANNEL = "com.example.spyware/settings"

    fun setup(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openAppSettings" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        appContext().startActivity(intent)
                        result.success(null)
                    } else {
                        result.error("ERROR", "No package name provided", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun appContext() = AppContextHolder.context
}
