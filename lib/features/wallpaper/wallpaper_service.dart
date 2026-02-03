import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class WallpaperService {
  
  /// Saves the image at [imagePath] to the 'Aura' album in the gallery.
  /// On iOS, [ImageGallerySaver] saves to the 'Camera Roll' by default, 
  /// but we can try to organize it or just ensure it's saved.
  /// Note: 'image_gallery_saver' does not strictly support custom album names on all versions,
  /// but native code in AppDelegate (Phase 4) was supposed to handle 'Aura Moments'.
  /// This implementation uses the package as requested by the user.
  static Future<bool> saveToSharedAlbum(String imagePath) async {
    // 1. Request Permissions
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      status = await Permission.photosAddOnly.request(); // iOS 14+
      if (!status.isGranted) {
        print("Permission denied");
        return false;
      }
    }

    try {
      final File file = File(imagePath);
      if (!file.existsSync()) {
        print("File not found: $imagePath");
        return false;
      }

      final Uint8List bytes = await file.readAsBytes();
      
      // Save directly. The 'name' param is usually the prefix.
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: "Aura_${DateTime.now().millisecondsSinceEpoch}",
      );
      
      print("Saved to gallery: $result");
      return result['isSuccess'] == true;
    } catch (e) {
      print("Error saving to album: $e");
      return false;
    }
  }
}
