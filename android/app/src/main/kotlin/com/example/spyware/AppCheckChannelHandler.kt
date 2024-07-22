package com.example.spyware

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.example.spyware.AppChecker

object AppCheckChannelHandler {
    private const val CHANNEL = "com.example.spyware/app_check"

    fun setup(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAppInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val isInstalled = AppChecker.isAppInstalled(packageName)
                        result.success(isInstalled)
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
