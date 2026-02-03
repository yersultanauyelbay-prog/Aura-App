package com.example.aura

import android.app.WallpaperManager
import android.content.Context
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.util.concurrent.Executors

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.aura.app/wallpaper"
    private val WORK_CHANNEL = "com.aura.app/workmanager" // Placeholder for WorkManager interactions if needed

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWallpaper") {
                val filePath = call.argument<String>("filePath")
                val location = call.argument<int>("location") ?: 1 // 1: HOME, 2: LOCK, 3: BOTH
                
                if (filePath != null) {
                    setWallpaper(filePath, location, result)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setWallpaper(filePath: String, location: Int, result: MethodChannel.Result) {
        val executor = Executors.newSingleThreadExecutor()
        executor.execute {
            try {
                val file = File(filePath)
                if (!file.exists()) {
                    runOnUiThread { result.error("FILE_NOT_FOUND", "File does not exist", null) }
                    return@execute
                }

                val bitmap = BitmapFactory.decodeStream(FileInputStream(file))
                val wallpaperManager = WallpaperManager.getInstance(context)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    // WallpaperManager.FLAG_SYSTEM = 1
                    // WallpaperManager.FLAG_LOCK = 2
                    var flags = 0
                    if (location == 1 || location == 3) flags = flags or WallpaperManager.FLAG_SYSTEM
                    if (location == 2 || location == 3) flags = flags or WallpaperManager.FLAG_LOCK
                    
                    if (flags != 0) {
                        wallpaperManager.setBitmap(bitmap, null, true, flags)
                    } else {
                         // Default to system
                        wallpaperManager.setBitmap(bitmap)
                    }
                } else {
                    wallpaperManager.setBitmap(bitmap)
                }

                runOnUiThread { result.success(true) }
            } catch (e: Exception) {
                runOnUiThread { result.error("SET_WALLPAPER_FAILED", e.message, null) }
            }
        }
    }
}
