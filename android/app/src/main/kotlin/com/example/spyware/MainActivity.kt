package com.example.spyware
import io.flutter.embedding.android.FlutterActivity
import android.content.pm.PackageManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import android.util.Log

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "samples.flutter.dev/spyware"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSpywareApps" -> {
                        val spywareApps = getDetectedSpywareApps()
                        if (spywareApps != null) {
                            result.success(spywareApps)
                        } else {
                            result.error("UNAVAILABLE", "Could not retrieve spyware apps.", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getDetectedSpywareApps(): List<String>? {
        val infos = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        val apps = mutableListOf<String>()
        val detectedSpywareApps = mutableListOf<String>()

        infos.forEach { info ->
            apps.add(info.packageName)
        }

        try {
            // Log before attempting to access file
            Log.d("SpywareDetection", "Attempting to open app-ids-research.csv")
            assets.open("app-ids-research.csv").use { inputStream ->
            BufferedReader(InputStreamReader(inputStream)).use { reader ->
                reader.readLine() // Skip header line
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    val tokens = line!!.split(",")
                    if (tokens.isNotEmpty() && apps.contains(tokens[0].trim())) {
                        detectedSpywareApps.add(tokens[0].trim())
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

