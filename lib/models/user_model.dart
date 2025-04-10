import 'package:get/get.dart';

class UserModel extends GetxController {
  // Make properties reactive using Rx variables
  RxString uId = ''.obs;
  RxString roomId = ''.obs;
  RxString userName = ''.obs;
  RxString gmail = ''.obs;
  RxInt rtcUid = 0.obs;
  RxString profileImage = "".obs;
  RxString countryCode = "".obs;
  RxString gender = ''.obs;
  Rx<String> dOb = "".obs;
  RxBool isMailVarified = false.obs;

  void updateIsMailVarified(bool newIsMailVarified) {
    isMailVarified.value = newIsMailVarified;
  }

  void updateUid(String newUid) {
    uId.value = newUid;
  }

  void updateCountryCode(String newCode) {
    countryCode.value = newCode;
  }

  void updateProfileImage(String newProfileImage) {
    profileImage.value = newProfileImage;
  }

  void updateGender(String newGender) {
    gender.value = newGender;
  }

  // Method to update the roomId
  void updateRoomId(String newRoomId) {
    roomId.value = newRoomId;
  }

  // Method to update the username
  void updateUsername(String newUsername) {
    userName.value = newUsername;
  }

  // Method to update the gmail
  void updateGmail(String newGmail) {
    gmail.value = newGmail;
  }

  // Method to update the dob
  void updateDob(String newDob) {
    dOb.value = newDob;
  }

  void updateRtcUid(int newRtcUid) {
    rtcUid.value = newRtcUid;
  }

  void updateAllFields(Map<String, dynamic> newValues) {
    uId.value = newValues['uId'] ?? uId.value;
    roomId.value = newValues['roomId'] ?? roomId.value;
    userName.value = newValues['userName'] ?? userName.value;
    gmail.value = newValues['gmail'] ?? gmail.value;
    profileImage.value = newValues['profileImage'] ?? profileImage;
    gender.value = newValues['gender'] ?? gender.value;
    dOb.value = newValues['dOb'] ?? dOb.value;
    rtcUid.value = newValues['rtcUid'] ?? rtcUid.value;
    countryCode.value = newValues['countryCode'] ?? countryCode.value;
    isMailVarified.value = newValues['isMailVarified'] ?? isMailVarified.value;
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId.value,
      'roomId': roomId.value,
      'userName': userName.value,
      'gmail': gmail.value,
      'dOb': dOb.value,
      'rtcUid': rtcUid.value,
      'profileImage': profileImage.value,
      'gender': gender.value,
      'countryCode': countryCode.value,
      'isMailVarified': isMailVarified.value
    };
  }

  @override
  String toString() {
    return 'UserModel(uId: ${uId.value}, roomId: ${roomId.value}, userName: ${userName.value}, gmail: ${gmail.value}, rtcUid: ${rtcUid.value}, profileImage: ${profileImage.value}, countryCode: ${countryCode.value}, gender: ${gender.value}, dOb: ${dOb.value}), isMailVarified: ${isMailVarified.value}';
  }
}
