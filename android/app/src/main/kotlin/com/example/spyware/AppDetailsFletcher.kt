package com.example.spyware

import android.content.pm.PackageManager
import android.content.pm.PackageInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import android.util.Log
import java.io.ByteArrayOutputStream
import com.example.spyware.AppContextHolder

object AppDetailsFetcher {
    fun getAppDetails(packageName: String): Map<String, String>? {
        return try {
            val packageManager = AppContextHolder.context.packageManager
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            val appName = packageManager.getApplicationLabel(appInfo).toString()
            val iconBase64 = getBase64IconFromDrawable(packageManager.getApplicationIcon(packageName))
            mapOf("name" to appName, "icon" to iconBase64, "package" to packageName)
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
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

    fun getAppPermissions(packageName: String): List<Map<String, String>> {
        val permissionGroups = mapOf(
            "android.permission.ACCESS_FINE_LOCATION" to "location",
            "android.permission.ACCESS_COARSE_LOCATION" to "location",
            "android.permission.ACCESS_BACKGROUND_LOCATION" to "location",
            "android.permission.CAMERA" to "camera",
            "android.permission.RECORD_AUDIO" to "microphone",
            "android.permission.READ_EXTERNAL_STORAGE" to "storage",
            "android.permission.WRITE_EXTERNAL_STORAGE" to "storage",
            "android.permission.MANAGE_EXTERNAL_STORAGE" to "storage",
            "android.permission.READ_MEDIA_IMAGES" to "storage",
            "android.permission.READ_MEDIA_VIDEO" to "storage"
        )

        val addedGroups = mutableSetOf<String>()
        val grantedPermissions = mutableListOf<Map<String, String>>()

        try {
            val packageInfo = AppContextHolder.context.packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
            val requestedPermissions = packageInfo.requestedPermissions
            val requestedPermissionsFlags = packageInfo.requestedPermissionsFlags

            requestedPermissions?.forEachIndexed { index, permission ->
                val group = permissionGroups[permission]
                if (group != null && !addedGroups.contains(group) && requestedPermissionsFlags[index] and PackageInfo.REQUESTED_PERMISSION_GRANTED != 0) {
                    val iconName = getPermissionIconName(permission)
                    grantedPermissions.add(mapOf(
                        "permission" to permission,
                        "icon" to iconName
                    ))
                    addedGroups.add(group)
                }
            }
        } catch (e: Exception) {
            Log.e("PermissionsError", "Error fetching permissions for $packageName", e)
        }

        return grantedPermissions
    }

    private fun getPermissionIconName(permission: String): String {
        return when (permission) {
            "android.permission.ACCESS_FINE_LOCATION",
            "android.permission.ACCESS_COARSE_LOCATION",
            "android.permission.ACCESS_BACKGROUND_LOCATION",
            "android.permission.ACCESS_MEDIA_LOCATION" -> "location"
            "android.permission.CAMERA" -> "camera"
            "android.permission.RECORD_AUDIO" -> "microphone"
            "android.permission.READ_EXTERNAL_STORAGE",
            "android.permission.WRITE_EXTERNAL_STORAGE",
            "android.permission.MANAGE_EXTERNAL_STORAGE",
            "android.permission.READ_MEDIA_IMAGES",
            "android.permission.READ_MEDIA_VIDEO" -> "storage"
            else -> "unknown"
        }
    }
}
