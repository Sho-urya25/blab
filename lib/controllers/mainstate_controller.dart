import 'dart:developer';

import 'package:blab/controllers/auth_controller.dart';
import 'package:blab/views/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/user_model.dart';
import '../views/authentication/login_screen.dart';

class MainStateController extends GetxController {
  late UserModel userModel;
  final _firebaseFirestore = FirebaseFirestore.instance;
  final _firebasAutinstance = FirebaseAuth.instance;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceId = "";
  late String token;
  late UserCredential userCredential;
  void setUserCredential(UserCredential userCredetials) {
    userCredential = userCredetials;
  }

  @override
  void onReady() {
    userModel = Get.put<UserModel>(UserModel());
    checkILoggedIn();
    super.onReady();
  }

  @override
  void onInit() {
    getDeviceId();
    super.onInit();
  }

  void checkILoggedIn() {
    print("uid ${GetStorage().read("uId")}");
    if (GetStorage().read("uId") != null) {
      handelafterLoginOrRestart();
    } else {
      Get.off(() => LoginScreen());
    }
  }

  Future<void> getDeviceId() async {
    if (GetPlatform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      print("deviceId $deviceId");
    }
    if (GetPlatform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor!;
    }
  }

  void updateUserModel(String uid) {
    _firebaseFirestore.collection("Users").doc(uid).get().then((userdata) {
      userModel.updateAllFields(userdata.data()!);
      Get.offAll(() => MainScreen());
    });
  }

  void logOut() {
    _firebasAutinstance.signOut().then((_) {
      GetStorage().remove("uId");
      Get.offAll(() => LoginScreen());
    });
  }

  void updateFireData(Map<String, dynamic> data) {
    _firebaseFirestore
        .collection("Users")
        .doc(userModel.uId.value)
        .update(data);
  }

  void forgatePassword(String text) {
    _firebasAutinstance.sendPasswordResetEmail(email: text).then((_) {
      Get.isSnackbarOpen ? null : Get.back();
      Get.snackbar("Success", "Password reset email sent");
    }).catchError((e) {
      Get.snackbar("Error", e.toString());
    });
  }

  void handelafterLoginOrRestart() {
    String? email = GetStorage().read("email");
    String? password = GetStorage().read("pass");
    log("email $email password $password");
    if (email != null && password != null) {
      Get.put<AuthController>(AuthController()).login(email, password);
    } else {
      Get.off(() => LoginScreen());
    }
  }
}
