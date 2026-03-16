import 'package:flutter/material.dart';
import 'homepage.dart'; // Importing the custom UI logic from a separate file to keep the code modular

// ==========================================
// MAIN ENTRY POINT
// ==========================================
void main() {
  // Execution starts here. We call runApp to attach the root widget to the screen.
  runApp(const MyApp());
}

// ==========================================
// ROOT WIDGET
// ==========================================
class MyApp extends StatelessWidget {
  /* Using 'const' constructor and 'super.key' is a performance best practice in Flutter. 
   It allows the framework to skip rebuilding this widget if nothing changes.
  */
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /* MaterialApp is the wrapper for the entire application. 
     It provides essential tools like the Navigator, Theme data, and Localization.
    */
    return const MaterialApp(
      // Removes the red "Debug" banner from the top-right corner for a cleaner look.
      debugShowCheckedModeBanner: false,
      
      // Setting 'Homepage' as the first screen the user sees when the app launches.
      home: Homepage(),
    );
  }
}