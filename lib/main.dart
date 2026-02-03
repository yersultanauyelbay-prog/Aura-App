import 'package:aura/core/router/app_router.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'firebase_options.dart'; // User needs to generate this via flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Commented out until user runs flutterfire configure
  
  runApp(const ProviderScope(child: AuraApp()));
}

class AuraApp extends ConsumerWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Aura',
      theme: AppTheme.darkTheme, // Default to dark/glassmorphism
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
