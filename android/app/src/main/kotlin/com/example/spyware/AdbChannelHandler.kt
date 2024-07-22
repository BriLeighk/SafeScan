package com.example.spyware

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import android.util.Log
import java.io.BufferedReader
import java.io.InputStreamReader

object AdbChannelHandler {
    private const val CHANNEL = "com.example.spyware/adb"

    fun setup(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectToDevice" -> {
                    val connectionResult = AdbConnector.connectToDevice()
                    result.success(connectionResult)
                }
                "scanDevice" -> {
                    val csvData = call.argument<List<List<String>>>("csvData")
                    if (csvData != null) {
                        val scanResult = AdbScanner.scanDevice(csvData)
                        result.success(scanResult)
                    } else {
                        result.error("INVALID_DATA", "CSV data is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    object AdbConnector {
        fun connectToDevice(): Boolean {
            return try {
                // Ensure both devices are connected
                val process = Runtime.getRuntime().exec("adb devices")
                val reader = BufferedReader(InputStreamReader(process.inputStream))
                val output = StringBuilder()
                var line: String?

                while (reader.readLine().also { line = it } != null) {
                    output.append(line).append("\n")
                }
                reader.close()

                // Check if both devices are connected
                val devices = output.toString()
                if (devices.contains("device") && devices.split("device").size - 1 == 2) {
                    Log.i("ADBConnection", "Both devices connected via USB successfully.")
                    true
                } else {
                    Log.e("ADBConnection", "Failed to connect both devices via USB.")
                    false
                }
            } catch (e: Exception) {
                Log.e("ADBConnection", "Error connecting via USB", e)
                false
            }
        }
    }

    object AdbScanner {
        fun scanDevice(csvData: List<List<String>>): String {
            val ids = mutableSetOf<String>()
            val types = mutableMapOf<String, String>()

            for (line in csvData) {
                if (line.size > 2) {
                    ids.add(line[0].trim())
                    types[line[0].trim()] = line[2].trim()
                }
            }

            return try {
                val process = Runtime.getRuntime().exec("adb -s <target_device_serial> shell pm list packages")
                val reader = BufferedReader(InputStreamReader(process.inputStream))

                var line: String?
                val detectedApps = mutableListOf<Map<String, Any?>>()

                while (reader.readLine().also { line = it } != null) {
                    val appID = line?.substringAfter("package:")?.trim()
                    if (appID != null && ids.contains(appID)) {
                        val appName = appID // Simplified for example, you can get more details if needed
                        val appType = types[appID] ?: "Unknown"
                        val appInfo: Map<String, Any?> = mapOf(
                            "id" to appID,
                            "name" to appName,
                            "type" to appType
                        )
                        detectedApps.add(appInfo)
                    }
                }
                reader.close()
                if (detectedApps.isEmpty()) {
                    "No spyware apps detected on the target device."
                } else {
                    detectedApps.joinToString(separator = "\n") { "${it["name"]} (${it["id"]}) - ${it["type"]}" }
                }
            } catch (e: Exception) {
                Log.e("ADBError", "Error scanning device", e)
                "Error scanning device: ${e.message}"
            }
        }
    }
}
