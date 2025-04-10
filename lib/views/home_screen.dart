import 'package:blab/views/meetings/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Center(
            child: TextButton(
                onPressed: () => Get.to(() => ChatScreen()),
                child: const Text("Random Connect")),
          )
        ],
      )),
    );
  }
}
