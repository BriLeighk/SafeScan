package com.example.spyware
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.ByteArrayOutputStream
import android.util.Log
import android.util.Base64
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.provider.Settings
import android.net.Uri

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "samples.flutter.dev/spyware"
        private const val SETTINGS_CHANNEL = "com.example.spyware/settings"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) { //when the method getSpywareApps is called
                    "getSpywareApps" -> {
                        val spywareApps = getDetectedSpywareApps() //call the method to retrieve apps from device and do comparison
                        if (spywareApps != null) {
                            result.success(spywareApps)
                        } else {
                            result.error("UNAVAILABLE", "Error retrieving list of apps from the device.", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
            //ADD SETTINGS METHOD CHANNEL
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openAppSettings" -> {
                        val packageName = call.argument<String>("package")
                        if (packageName != null) {
                            openAppSettings(packageName)
                            result.success(null)  // No need to send back the package name
                        } else {
                            result.error("ERROR", "No package name provided", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

    }
    private lateinit var spywareAppIds: Set<String>
    private lateinit var appTypes: Map<String, String>
    
    private fun loadSpywareData() {
        val ids = mutableSetOf<String>()
        val types = mutableMapOf<String, String>()
        try {
            assets.open("app-ids-research.csv").bufferedReader().use { reader ->
                reader.readLine()  // Skip the header
                reader.forEachLine { line ->
                    line.split(",").let {
                        if (it.size > 2) {
                            ids.add(it[0].trim())
                            types[it[0].trim()] = it[2].trim()
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("SpywareDetection", "Failed to read spyware IDs from CSV", e)
        }
        spywareAppIds = ids
        appTypes = types
    }

    /*
    * Method to retrieve apps on device and compare against database of spyware apps
    */
    private fun getDetectedSpywareApps(): List<Map<String, Any>>? {
        if (!::spywareAppIds.isInitialized) {
            loadSpywareData()
        }
    
        val detectedSpywareApps = mutableListOf<Map<String, Any>>()
        // Iterate over installed applications and collect data only for spyware apps
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        installedApps.parallelStream().forEach { app ->
            val appID = app.packageName
            if (appID in spywareAppIds) {
                // Fetch detailed information only for apps identified as spyware
                val appName = app.loadLabel(packageManager).toString()
                val iconBase64 = getBase64IconFromDrawable(app.loadIcon(packageManager))
                val installer = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
                    val installSourceInfo = packageManager.getInstallSourceInfo(appID)
                    installSourceInfo.installingPackageName ?: "Unknown"
                } else {
                    packageManager.getInstallerPackageName(appID) ?: "Unknown"
                }
                val appType = appTypes[appID] ?: "Unknown" // Defaults to unknown if not in map
                val appInfo = mapOf(
                    "id" to appID,
                    "name" to appName,
                    "icon" to iconBase64,
                    "installer" to installer,
                    "type" to appType
                    // "permissions" to permissions
                )
                synchronized(detectedSpywareApps) {
                    detectedSpywareApps.add(appInfo)
                }
            }
        }
    
        return detectedSpywareApps
    }
    
    private fun getBase64IconFromDrawable(drawable: Drawable): String {
        val bitmap = (drawable as? BitmapDrawable)?.bitmap ?: Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888).also {
            val canvas = Canvas(it)
            drawable.setBounds(0, 0, drawable.intrinsicWidth, drawable.intrinsicHeight)
            drawable.draw(canvas)
        }
        ByteArrayOutputStream().also { baos ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
            return Base64.encodeToString(baos.toByteArray(), Base64.NO_WRAP)
        }
    }

    private fun openAppSettings(packageName: String) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:$packageName")
        startActivity(intent)
    }






    // NOT IN USE ///////////////////////////////////////////////////////////
    private fun getEnabledPermissions(appPackageName: String): List<String> {
        val grantedPermissions = mutableListOf<String>()
        try {
            val permissions = packageManager.getPackageInfo(appPackageName, PackageManager.GET_PERMISSIONS).requestedPermissions
            if (permissions != null) {
                for (permission in permissions) {
                    if (packageManager.checkPermission(permission, appPackageName) == PackageManager.PERMISSION_GRANTED) {
                        grantedPermissions.add(permission)
                        Log.d("EnabledPermissions", "Permission granted: $permission")
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("PermissionsError", "Error fetching permissions for $appPackageName", e)
        }
        return grantedPermissions
    }
    /////////////////////////////////////////////////////////////////////////
    
}




