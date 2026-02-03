import 'dart:io';
import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _androidChannel = MethodChannel('com.aura.app/wallpaper');
  static const MethodChannel _iosChannel = MethodChannel('com.aura.app/photos');

  // Locations: 1=HOME, 2=LOCK, 3=BOTH
  static Future<void> setWallpaper(String filePath, {int location = 3}) async {
    if (Platform.isAndroid) {
      try {
        await _androidChannel.invokeMethod('setWallpaper', {
          'filePath': filePath,
          'location': location,
        });
      } on PlatformException catch (e) {
        print("Failed to set wallpaper: '${e.message}'.");
        rethrow;
      }
    } else {
      print("setWallpaper called on non-Android platform");
    }
  }

  static Future<void> saveToAuraAlbum(String filePath) async {
    if (Platform.isIOS) {
      try {
        await _iosChannel.invokeMethod('saveToAuraAlbum', {
          'filePath': filePath,
        });
      } on PlatformException catch (e) {
        print("Failed to save to album: '${e.message}'.");
        // rethrow; // Soft fail for now
      }
    }
  }

  static Future<void> startLiveActivity() async {
    if (Platform.isIOS) {
      try {
        await _iosChannel.invokeMethod('startLiveActivity');
      } catch (e) {
        print("Failed to start Live Activity: $e");
      }
    }
  }
}

