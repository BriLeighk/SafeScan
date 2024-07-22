package com.example.spyware

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.example.spyware.AppDetailsFetcher

object AppDetailsChannelHandler {
    private const val CHANNEL = "com.example.spyware/app_details"

    fun setup(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppDetails" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val appDetails = AppDetailsFetcher.getAppDetails(packageName)
                        result.success(appDetails)
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
