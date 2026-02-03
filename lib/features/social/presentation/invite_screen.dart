import 'dart:ui';
import 'package:aura/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final glassTheme = Theme.of(context).extension<GlassmorphismTheme>()!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Invite Friends"),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Background
           Container(
             decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]
              ),
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: glassTheme.blur, sigmaY: glassTheme.blur),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(glassTheme.opacity),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: glassTheme.borderColor),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_2, size: 100, color: Colors.white),
                        const SizedBox(height: 20),
                        const Text(
                          "Aura Pass",
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Invite your best friend to unlock your lock screen.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                         const SizedBox(height: 30),
                         ElevatedButton.icon(
                           onPressed: () {
                             Share.share(
                               'Hey! Let\'s link our lock screens on Aura. Here is my invite code: AURA-1234 \n\nDownload: https://ourapp.com', 
                               subject: 'Best Friend Invite'
                              );
                           },
                           icon: const Icon(Icons.share, color: Colors.black), 
                           label: const Text("Share Invite Link", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.white,
                             minimumSize: const Size(double.infinity, 50),
                           )
                         )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
