import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiCropServiceProvider = Provider<AiCropService>((ref) {
  return AiCropService();
});

class AiCropService {
  AiCropService();

  /// Analyzes the image by calling the 'getSmartCropCoordinates' Cloud Function.
  /// Returns a recommended Crop Rect (normalized 0.0-1.0).
  Future<Rect?> getSmartCropRect(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final imageBytes = await file.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final result = await FirebaseFunctions.instance
          .httpsCallable('getSmartCropCoordinates')
          .call({
        'imageBase64': base64Image,
      });

      final data = result.data as Map<dynamic, dynamic>;
      if (data.containsKey('cropRect')) {
        final rectData = data['cropRect'] as Map<dynamic, dynamic>;
        return Rect.fromLTRB(
          (rectData['xmin'] as num).toDouble(),
          (rectData['ymin'] as num).toDouble(),
          (rectData['xmax'] as num).toDouble(),
          (rectData['ymax'] as num).toDouble(),
        );
      }
      return null;

    } catch (e) {
      print('Cloud Function Smart Crop Error: $e');
      return null;
    }
  }
}
