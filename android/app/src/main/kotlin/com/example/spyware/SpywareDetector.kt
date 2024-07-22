package com.example.spyware

import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import android.util.Log
import java.io.ByteArrayOutputStream
import com.example.spyware.AppDetailsFetcher

object SpywareDetector {
    fun getDetectedSpywareApps(csvData: List<List<String>>): List<Map<String, Any?>> {
        val ids = mutableSetOf<String>()
        val types = mutableMapOf<String, String>()

        for (line in csvData) {
            if (line.size > 2) {
                ids.add(line[0].trim())
                types[line[0].trim()] = line[2].trim()
            }
        }

        val detectedSpywareApps = mutableListOf<Map<String, Any?>>()
        val packageManager = AppContextHolder.context.packageManager
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        installedApps.forEach { app ->
            val appID = app.packageName
            if (appID in ids) {
                val appName = app.loadLabel(packageManager).toString()
                val iconBase64 = getBase64IconFromDrawable(app.loadIcon(packageManager))
                val installer = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
                    val installSourceInfo = packageManager.getInstallSourceInfo(appID)
                    installSourceInfo.installingPackageName ?: "Unknown"
                } else {
                    packageManager.getInstallerPackageName(appID) ?: "Unknown"
                }
                val storeLink = getStoreLink(appID, installer)
                val appType = types[appID] ?: "Unknown"
                val permissions = AppDetailsFetcher.getAppPermissions(appID)
                val appInfo: Map<String, Any?> = mapOf(
                    "id" to appID,
                    "name" to appName,
                    "icon" to iconBase64,
                    "installer" to installer,
                    "storeLink" to storeLink,
                    "type" to appType,
                    "permissions" to permissions
                )
                detectedSpywareApps.add(appInfo)
            }
        }
        return detectedSpywareApps
    }

    private fun getBase64IconFromDrawable(drawable: Drawable): String {
        val bitmap = (drawable as? BitmapDrawable)?.bitmap
            ?: Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888).also {
                val canvas = Canvas(it)
                drawable.setBounds(0, 0, drawable.intrinsicWidth, drawable.intrinsicHeight)
                drawable.draw(canvas)
            }
        ByteArrayOutputStream().also { baos ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
            return Base64.encodeToString(baos.toByteArray(), Base64.NO_WRAP)
        }
    }

    private fun getStoreLink(packageName: String, installer: String): String? {
        return when (installer) {
            "com.android.vending" -> "https://play.google.com/store/apps/details?id=$packageName"
            "com.amazon.venezia" -> "https://www.amazon.com/gp/mas/dl/android?p=$packageName"
            else -> null
        }
    }
}
