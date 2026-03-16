import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HistoryPage(),
  ));
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Setting the background color to white
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("History", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ),
      
      // Leaving 'body' and 'appBar' out results in a completely empty screen
      body: SafeArea(
        child: ListView(
          children:[Text ("History")]),
      ),
    );
  }
}