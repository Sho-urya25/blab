import 'package:blab/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});
  var index = 0.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
            onDestinationSelected: (index) {
              this.index.value = index;
            },
            selectedIndex: index.value,
            destinations: const [
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_2_outlined),
                selectedIcon: Icon(Icons.person_2),
                label: 'Notifications',
              ),
            ]),
      ),
      body: Obx(() => IndexedStack(
          index: index.value, children: [const HomeScreen(), ProfileScreen()])),
    );
  }
}
