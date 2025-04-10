import 'package:blab/controllers/mainstate_controller.dart';
import 'package:blab/views/nointernet_screen.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetActivitychecker extends GetxController {
  final mainStatController = Get.find<MainStateController>();
  @override
  void onReady() {
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          // The internet is now connected
          mainStatController.checkILoggedIn();

          break;
        case InternetStatus.disconnected:
          // The internet is now disconnected
          Get.offAll(() => const NoInterNetScreen());
          break;
      }
    });
    super.onReady();
  }
}
