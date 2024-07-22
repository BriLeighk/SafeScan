package com.example.spyware

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "samples.flutter.dev/spyware"
        private const val SETTINGS_CHANNEL = "com.example.spyware/settings"
        private const val PRIVACY_CHANNEL = "com.example.spyware/privacy"
        private const val APP_CHECK_CHANNEL = "com.example.spyware/app_check"
        private const val APP_DETAILS_CHANNEL = "com.example.spyware/app_details"
        private const val ADB_CHANNEL = "com.example.spyware/adb"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        SpywareChannelHandler.setup(flutterEngine.dartExecutor.binaryMessenger)
        SettingsChannelHandler.setup(flutterEngine.dartExecutor.binaryMessenger)
        PrivacyChannelHandler.setup(flutterEngine.dartExecutor.binaryMessenger)
        AppCheckChannelHandler.setup(flutterEngine.dartExecutor.binaryMessenger)
        AppDetailsChannelHandler.setup(flutterEngine.dartExecutor.binaryMessenger)
        AdbChannelHandler.setup(flutterEngine.dartExecutor.binaryMessenger)
    }

    private fun openAppSettings(packageName: String) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:$packageName")
        startActivity(intent)
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun launchPrivacyCheckup() {
        try {
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse("https://myaccount.google.com/privacycheckup")
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("OpenBrowser", "Error opening browser", e)
        }
    }

    private fun openApp(packageName: String) {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        if (launchIntent != null) {
            startActivity(launchIntent)
        } else {
            Log.e("LaunchApp", "Unable to launch app: $packageName")
        }
    }
}
