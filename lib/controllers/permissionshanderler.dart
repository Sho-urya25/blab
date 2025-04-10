import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  // Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    log("Requesting camera permission");
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Check and request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    log("Requesting microphone permission");
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Internet permission doesn't need runtime permission in Android/iOS
  // It's declared in the manifest but not requested at runtime.;

  // Check and request storage permission (if needed)
  // static Future<bool> requestStoragePermission() async {
  //   log("Requesting storage permission");
  //   final status = await Permission.storage.request();
  //   return status.isGranted;
  // }

  // Check and request notification permission (if needed)
  // static Future<bool> requestNotificationPermission() async {
  //   log("Requesting notification permission");
  //   final status = await Permission.notification.request();
  //   return status.isGranted;
  // }

  // Battery optimization ignoring for background functionality
  // static Future<bool> requestBatteryOptimizationPermission() async {
  //   log("Requesting battery optimization permission");
  //   final status = await Permission.ignoreBatteryOptimizations.request();
  //   return status.isGranted;
  // }

  // Check and request all necessary permissions for video calling
  static Future<bool> requestAllPermissions() async {
    final cameraStatus = await requestCameraPermission();
    final microphoneStatus = await requestMicrophonePermission();
    // final storageStatus = await requestStoragePermission();
    // final notificationStatus = await requestNotificationPermission();
    // final batteryStatus = await requestBatteryOptimizationPermission();

    return cameraStatus && microphoneStatus;
    // storageStatus &&
    // notificationStatus &&
    // batteryStatus;
  }

  // Check if all necessary permissions are granted
  static Future<bool> checkAllPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    // final storageStatus = await Permission.storage.status;
    // final notificationStatus = await Permission.notification.status;
    // final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    return cameraStatus.isGranted && microphoneStatus.isGranted;
    // storageStatus.isGranted &&
    // notificationStatus.isGranted &&
    // batteryStatus.isGranted;
  }
}
