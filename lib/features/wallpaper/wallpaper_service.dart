import 'package:gal/gal.dart';
import 'dart:io';

class WallpaperService {
  Future<void> saveWallpaper(String imagePath) async {
    try {
      // Используем современную библиотеку Gal для сохранения
      await Gal.putImage(imagePath);
      print('Обои успешно сохранены в галерею');
    } catch (e) {
      print('Ошибка при сохранении: $e');
      rethrow;
    }
  }
}
