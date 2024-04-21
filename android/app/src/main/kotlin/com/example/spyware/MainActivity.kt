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
import android.provider.Settings

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

    }
    /*
    * Method to retrieve apps on device and compare against database of spyware apps
    */
    private fun getDetectedSpywareApps(): List<Map<String, Any>>? {
        val apps = mutableListOf<Map<String, Any>>() //to store all app data from device

        val infos = packageManager.getInstalledApplications(PackageManager.GET_META_DATA) //gets all app info
        val detectedSpywareApps = mutableListOf<Map<String, Any>>() //to store all apps from device detected as spyware

        infos.forEach { info -> //for each app and it's corresponding information:
            val appName = info.loadLabel(packageManager).toString() //store its app name
            val appID = info.packageName //store its unique app id
            val permissions = packageManager.getPackageInfo(appID, PackageManager.GET_PERMISSIONS)
            .requestedPermissions?.toList() ?: listOf<String>()

            val drawableIcon = info.loadIcon(packageManager) //store its app icon bits

            val iconBitmap = if (drawableIcon is BitmapDrawable) { //creates icon bitmap
                drawableIcon.bitmap
            } else {
                Bitmap.createBitmap(drawableIcon.intrinsicWidth, drawableIcon.intrinsicHeight, 
                Bitmap.Config.ARGB_8888).apply {
                    val canvas = Canvas(this)
                    drawableIcon.setBounds(0, 0, canvas.width, canvas.height)
                    drawableIcon.draw(canvas)
                }
            }
            val baos = ByteArrayOutputStream() 
            iconBitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
            val iconBytes = baos.toByteArray()
            val iconBase64 = Base64.encodeToString(iconBytes, Base64.NO_WRAP)
            
            Log.d("AppIconBase64", "Icon Base64 for $appName: $iconBase64")
            val appInfo = mapOf(
                "id" to appID, 
                "name" to appName, 
                "icon" to iconBase64,
                "permissions" to permissions
                ) //adds app info to list of all apps from device
            
            apps.add(appInfo)
        }

        try {
            // Log before attempting to access file
            Log.d("SpywareDetection", "Attempting to open app-ids-research.csv")
            assets.open("app-ids-research.csv").use { inputStream -> //opens the csv file
            BufferedReader(InputStreamReader(inputStream)).use { reader ->
                reader.readLine() // Skip header line
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    val tokens = line!!.split(",")
                    if (tokens.isNotEmpty()) {

                        val csvAppId = tokens[0].trim() // Extract app ID from current line in CSV file
                        // Do comparison, see if app is downloaded on the device
                        val isInstalled = apps.any { app -> app["id"] == csvAppId}
                        if (isInstalled) {
                            apps.firstOrNull { app -> app["id"] == csvAppId }?.let {detectedApp ->
                            detectedSpywareApps.add(detectedApp)}
                        }
                    }
                }

                // Log after reading file
                Log.d("SpywareDetection", "Successfully read from app-ids-research.csv")
                Log.d("SpywareDetection", "Detected apps: $detectedSpywareApps \n")
            }
        } 
    } catch (e: Exception) {
            Log.e("SpywareDetection", "Error accessing app-ids-research.csv")
            return null
        }

        
        return detectedSpywareApps
    }
}

