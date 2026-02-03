import 'dart:ui';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/camera/presentation/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the custom theme extension for glassmorphism
    final glassTheme = Theme.of(context).extension<GlassmorphismTheme>()!;
    
    // Mock Data for Friends
    final friends = [
      {'name': 'Alex', 'streak': 5, 'image': 'https://i.pravatar.cc/150?u=a'},
      {'name': 'Sarah', 'streak': 12, 'image': 'https://i.pravatar.cc/150?u=b'},
      {'name': 'Mike', 'streak': 0, 'image': 'https://i.pravatar.cc/150?u=c'},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Aura', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // 1. Dynamic Background (Gradient / Mesh)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), 
                  Color(0xFF203A43), 
                  Color(0xFF2C5364)
                ],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Your Circle', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white70)
                  ),
                ),
                
                // Horizontal Friend List
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: friends.length + 1, // +1 for "Add Friend"
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildAddFriendButton(glassTheme);
                      }
                      final friend = friends[index - 1];
                      return _buildFriendItem(friend, glassTheme);
                    },
                  ),
                ),

                const Spacer(),

                // Big "Send Moment" Button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CameraScreen()),
                      );
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.8),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Colors.white),
                                SizedBox(height: 10),
                                Text(
                                  'Send Moment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFriendButton(GlassmorphismTheme glassTheme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text('Add', style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> friend, GlassmorphismTheme glassTheme) {
    final hasStreak = (friend['streak'] as int) > 0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(2), // Border width
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasStreak 
                  ? const LinearGradient(colors: [Colors.orange, Colors.red]) 
                  : null,
                color: hasStreak ? null : Colors.transparent,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black, // Background for transparent images
                ),
                child: ClipOval(
                  child: Image.network(
                    friend['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // Streak Badge
            if (hasStreak)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, size: 12, color: Colors.yellow),
                    Text(
                      '${friend['streak']}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(friend['name'], style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
