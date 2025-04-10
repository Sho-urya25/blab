import 'package:blab/controllers/mainstate_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final mainstateController = Get.find<MainStateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
              onPressed: () => mainstateController.logOut(),
              icon: const Icon(Icons.logout)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.question_mark_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Card(
                shape: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CircleAvatar(
                    backgroundImage: const CachedNetworkImageProvider(
                        "https://cdn.pixabay.com/photo/2024/02/04/18/27/woman-8552807_640.jpg"),
                    radius: Get.width * 0.155,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton.outlined(
                              onPressed: () {},
                              icon: const Icon(Icons.add_a_photo_outlined)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              mainstateController.userModel.userName.value,
              style: GoogleFonts.josefinSans(fontSize: Get.width * 0.07),
            ),
            Card(
              child: SizedBox(
                width: Get.width * 0.9,
                child: Padding(
                  padding: EdgeInsets.only(left: Get.width * 0.05),
                  child: Row(
                    children: [
                      const Text("Minutes Left: "),
                      const Text("10"),
                      const Spacer(),
                      TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.timelapse),
                          label: const Text("Add Minutes"))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
