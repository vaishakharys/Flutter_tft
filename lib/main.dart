import 'dart:io'; // Added for exit(0)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system bars (Note: In Linux Kiosk/Cage, this is mostly handled by the OS, 
  // but it's good practice to keep it).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFT Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      // We wrap the home widget in CallbackShortcuts to catch keyboard events
      home: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          // Pressing 'Escape' will close the app and drop you to CLI
          const SingleActivator(LogicalKeyboardKey.escape): () => exit(0),
          // Pressing 'Ctrl + Q' as an alternative exit
          const SingleActivator(LogicalKeyboardKey.keyQ, control: true): () => exit(0),
        },
        child: const Focus(
          autofocus: true, // This ensures the app is listening for keys immediately
          child: MouseRegion(
            cursor: SystemMouseCursors.none, // Hides the mouse cursor for a clean TFT look
            child: Scaffold(
              body: SafeArea(
                child: HomePage(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
