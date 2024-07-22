package com.example.spyware

import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.example.spyware.AppContextHolder

object PrivacyChannelHandler {
    private const val CHANNEL = "com.example.spyware/privacy"

    fun setup(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchPrivacyCheckup" -> {
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        data = Uri.parse("https://myaccount.google.com/privacycheckup")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    appContext().startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun appContext() = AppContextHolder.context
}
