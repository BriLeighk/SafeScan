package com.example.spyware

import android.content.pm.PackageManager
import android.util.Log
import java.io.BufferedReader
import java.io.InputStreamReader

object AppChecker {
    fun isAppInstalled(packageName: String): Boolean {
        return try {
            AppContextHolder.context.packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    fun checkInstalledAppsOnSource(): List<Map<String, String>> {
        return getInstalledApps(AppContextHolder.context.packageManager)
    }

    fun checkInstalledAppsOnTarget(): List<Map<String, String>> {
        return try {
            val process = Runtime.getRuntime().exec("adb shell pm list packages")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val installedApps = mutableListOf<Map<String, String>>()
            var line: String?

            while (reader.readLine().also { line = it } != null) {
                val packageName = line?.substringAfter("package:")?.trim()
                if (packageName != null) {
                    val appDetails = AppDetailsFetcher.getAppDetails(packageName)
                    if (appDetails != null) {
                        installedApps.add(appDetails)
                    }
                }
            }
            reader.close()
            installedApps
        } catch (e: Exception) {
            Log.e("ADBError", "Error checking installed apps on target device", e)
            emptyList()
        }
    }

    private fun getInstalledApps(packageManager: PackageManager): List<Map<String, String>> {
        val installedApps = mutableListOf<Map<String, String>>()
        val packages = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        packages.forEach { app ->
            val appDetails = AppDetailsFetcher.getAppDetails(app.packageName)
            if (appDetails != null) {
                installedApps.add(appDetails)
            }
        }
        return installedApps
    }
}
