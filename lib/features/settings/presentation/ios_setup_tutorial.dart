import 'package:aura/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class IosSetupTutorialScreen extends StatelessWidget {
  const IosSetupTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final glassTheme = Theme.of(context).extension<GlassmorphismTheme>()!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Setup Aura on iOS"),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Background
           Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF434343)], 
                begin: Alignment.bottomCenter, 
                end: Alignment.topCenter
              ),
            ),
          ),
          
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStepCard(
                  context,
                  glassTheme,
                  step: "1",
                  title: "Enable Aura Moments",
                  description: "Aura has created a folder called 'Aura Moments' in your Photos. All moments will be saved there.",
                  icon: Icons.folder_special,
                ),
                const SizedBox(height: 20),
                _buildStepCard(
                  context,
                  glassTheme,
                  step: "2",
                  title: "Lock Screen Settings",
                  description: "Long press your Lock Screen and tap 'Customize' or '+'. Select 'Photo Shuffle'.",
                  icon: Icons.wallpaper,
                ),
                const SizedBox(height: 20),
                _buildStepCard(
                  context,
                  glassTheme,
                  step: "3",
                  title: "Select Album",
                  description: "Choose 'Album' and select 'Aura Moments'. Set frequency to 'On Wake'.",
                  icon: Icons.photo_library,
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text("I'm Ready!", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, GlassmorphismTheme glassTheme, {
    required String step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(glassTheme.opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(step, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: Colors.white70, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
