import 'dart:io';
import 'package:aura/features/wallpaper/wallpaper_service.dart';
import 'package:flutter/material.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(widget.imagePath), fit: BoxFit.cover),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Save Button
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveToWallpaper,
              icon: _isSaving 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.ios_share),
              label: Text(_isSaving ? "Saving..." : "Сохранить для обоев"), // "Save for Wallpaper"
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToWallpaper() async {
    setState(() {
      _isSaving = true;
    });

    final success = await WallpaperService.saveToSharedAlbum(widget.imagePath);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Saved to Aura Album!' : 'Failed to save.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
