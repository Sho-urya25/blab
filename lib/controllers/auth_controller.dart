import 'dart:developer';

import 'package:blab/views/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'mainstate_controller.dart';

class AuthController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _mainstate = Get.find<MainStateController>();
  final _auth = FirebaseAuth.instance;
  late String roomId;
  late UserCredential userCredential;

  // Observables for UI state
  final RxBool isMailVerified = false.obs;
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginEmailError = ''.obs;
  final loginPasswordError = ''.obs;
  final isLoadingLogin = false.obs;
  final errorLogin = ''.obs;
  final isLoginPasswordVisible = false.obs;

  final signUpEmailController = TextEditingController();
  final signUpUsernameController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpEmailError = ''.obs;
  final signUpUsernameError = ''.obs;
  final signUpPasswordError = ''.obs;
  final isLoadingSignUp = false.obs;
  final errorSignUp = ''.obs;
  final isSignUpPasswordVisible = false.obs;

  void toggleLoginPasswordVisibility() => isLoginPasswordVisible.toggle();
  void toggleSignUpPasswordVisibility() => isSignUpPasswordVisible.toggle();

  /// Login Method
  void login(String? email, String? password) async {
    if ((validateLoginEmail() && validateLoginPassword()) ||
        (email != null && password != null)) {
      isLoadingLogin(true);
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email ?? loginEmailController.text.trim(),
          password: password ?? loginPasswordController.text.trim(),
        );
        log("user logged in");

        // Reload user to get the latest info
        await userCredential.user!.reload();
        final currentUser = _auth.currentUser;
        log("new user loded");
        if (currentUser != null) {
          if (currentUser.emailVerified) {
            log("email verified");
            // Save user ID to local storage
            _mainstate.setUserCredential(userCredential);
            await GetStorage().write("uId", currentUser.uid);
            await GetStorage().write("email", email ?? currentUser.email);
            await GetStorage()
                .write("pass", password ?? loginPasswordController.text.trim());

            // Update user model in the main state controller
            _mainstate.updateUserModel(currentUser.uid);
            log("sddsvsdvsvscvsdcv");
            // Navigate to the home screen
            Get.offAll(() => const HomeScreen());
          } else {
            // Show a message to verify email
            Get.snackbar("Error", "Please verify your email before logging in.",
                borderColor: Colors.redAccent);
          }
        } else {
          Get.snackbar("Error", "Login failed, user not found.");
        }
      } on FirebaseAuthException catch (error) {
        errorLogin.value = _handleFirebaseAuthException(error);
        Get.snackbar("Error", errorLogin.value);
      } finally {
        isLoadingLogin(false);
      }
    }
  }

  /// Handle Firebase Auth Exceptions
  String _handleFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'The user account has been disabled by an administrator.';
      default:
        return 'An unexpected error occurred: ${error.message}';
    }
  }

  /// Sign-Up Method
  void signUp() async {
    getRoomId();

    if (validateSignUpEmail() &&
        validateSignUpUsername() &&
        validateSignUpPassword()) {
      isLoadingSignUp(true);

      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: signUpEmailController.text.trim(),
          password: signUpPasswordController.text.trim(),
        );

        // Send email verification
        // await sendEmailVerification(userCredential);
        if (!userCredential.user!.emailVerified) {
          await userCredential.user!.sendEmailVerification();
        }

        // Create user data in Firestore
        await createUserData(userCredential.user!.uid);

        // Show success message

        // Clear sign-up fields and navigate back to login
        clearSignUpFields();
        Get.back();
      } catch (error) {
        Get.snackbar("Error while creating account", error.toString());
      } finally {
        isLoadingSignUp(false);
      }
    }
  }

  /// Validate Login Email
  bool validateLoginEmail() {
    final email = loginEmailController.text.trim();
    if (email.isEmpty) {
      loginEmailError('Email is required');
      return false;
    } else if (!EmailValidator.validate(email)) {
      loginEmailError('Invalid email format');
      return false;
    } else {
      loginEmailError('');
      return true;
    }
  }

  /// Validate Login Password
  bool validateLoginPassword() {
    final password = loginPasswordController.text.trim();
    if (password.isEmpty) {
      loginPasswordError('Password is required');
      return false;
    } else {
      loginPasswordError('');
      return true;
    }
  }

  /// Validate Sign-Up Email
  bool validateSignUpEmail() {
    final email = signUpEmailController.text.trim();
    if (email.isEmpty) {
      signUpEmailError('Email is required');
      return false;
    } else if (!EmailValidator.validate(email)) {
      signUpEmailError('Invalid email format');
      return false;
    } else {
      signUpEmailError('');
      return true;
    }
  }

  /// Validate Sign-Up Username
  bool validateSignUpUsername() {
    final username = signUpUsernameController.text.trim();
    if (username.isEmpty) {
      signUpUsernameError('Username is required');
      return false;
    } else if (username.length < 3) {
      signUpUsernameError('Username must be at least 3 characters long');
      return false;
    } else {
      signUpUsernameError('');
      return true;
    }
  }

  /// Validate Sign-Up Password
  bool validateSignUpPassword() {
    final password = signUpPasswordController.text.trim();
    if (password.isEmpty) {
      signUpPasswordError('Password is required');
      return false;
    } else if (password.length < 8 || password.length > 15) {
      signUpPasswordError('Password must be between 8 and 15 characters long');
      return false;
    } else if (!RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      signUpPasswordError(
          'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character');
      return false;
    } else {
      signUpPasswordError('');
      return true;
    }
  }

  /// Generate Room ID
  void getRoomId() {
    roomId = const Uuid().v4().substring(0, 6);
  }

  /// Send Email Verification
  // Future<void> sendEmailVerification(UserCredential userCredential) async {
  //   try {
  //     then((_) {
  //       Get.snackbar("Verification email sent", "Please verify your  email.",
  //           borderColor: Colors.green);
  //     });
  //   } catch (error) {
  //     Get.snackbar("Error while sending email", error.toString());
  //   }
  // }

  /// Create User Data in Firestore
  Future<void> createUserData(String uid) async {
    try {
      _mainstate.userModel.updateAllFields({
        "uId": uid,
        "roomId": roomId,
        "userName": signUpUsernameController.text.trim(),
        "gmail": signUpEmailController.text.trim(),
        "dOb": "",
        "gender": "Please select your gender",
        "rtcUid": DateTime.now().millisecondsSinceEpoch,
        "profileImage": "https://avatar.iran.liara.run/public",
        "isMailVerified": false, // Initially set to false
      });

      await _firestore
          .collection("Users")
          .doc(uid)
          .set(_mainstate.userModel.toJson());
    } catch (error) {
      Get.snackbar("Error while creating account", error.toString());
    }
  }

  /// Clear Sign-Up Fields
  void clearSignUpFields() {
    signUpEmailController.clear();
    signUpUsernameController.clear();
    signUpPasswordController.clear();
  }

  /// Handle App Lifecycle State Changes

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
// import 'package:blab/views/home_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:email_validator/email_validator.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:uuid/uuid.dart';
// import 'mainstate_controller.dart';

// class AuthController extends GetxController with WidgetsBindingObserver {
//   final _firestore = FirebaseFirestore.instance;
//   final _mainstate = Get.find<MainStateController>();
//   final _auth = FirebaseAuth.instance;
//   late String roomId;

//   final RxBool isMailVarified = false.obs;

//   final loginEmailController = TextEditingController();
//   final loginPasswordController = TextEditingController();

//   final loginEmailError = ''.obs;
//   final loginPasswordError = ''.obs;
//   final isLoadingLogin = false.obs;
//   final errorLogin = ''.obs;
//   final isLoginPasswordVisible = false.obs;

//   final signUpEmailController = TextEditingController();
//   final signUpUsernameController = TextEditingController();
//   final signUpPasswordController = TextEditingController();

//   final signUpEmailError = ''.obs;
//   final signUpUsernameError = ''.obs;
//   final signUpPasswordError = ''.obs;
//   final isLoadingSignUp = false.obs;
//   final errorSignUp = ''.obs;
//   final isSignUpPasswordVisible = false.obs;
//   bool isUserSignedUp = false;

//   void toggleLoginPasswordVisibility() => isLoginPasswordVisible.toggle();

//   void toggleSignUpPasswordVisibility() => isSignUpPasswordVisible.toggle();

//   void login() async {
//     if (validateLoginEmail() && validateLoginPassword()) {
//       isLoadingLogin(true);
//       try {
//         final uid = await _auth.signInWithEmailAndPassword(
//           email: loginEmailController.text,
//           password: loginPasswordController.text,
//         );

//         // Check if the user is not null
//         await uid.user!.reload();
//         if (uid.user != null) {
//           // Reload the user to get the latest info
//           if (uid.user!.emailVerified) {
//             await GetStorage().write("uId", uid.user!.uid);
//             _mainstate.updateUserModel(uid.user!.uid);
//             Get.offAll(() => const HomeScreen());
//           } else {
//             Get.snackbar("Error", "Please verify your email",
//                 borderColor: Colors.redAccent);
//           }
//         } else {
//           Get.snackbar("Error", "Login failed, user not found.");
//         }
//       } on FirebaseAuthException catch (error) {
//         errorLogin.value = _handleFirebaseAuthException(error);
//         Get.snackbar("Error", errorLogin.value);
//       } finally {
//         isLoadingLogin(false);
//       }
//     }
//   }

//   String _handleFirebaseAuthException(FirebaseAuthException error) {
//     switch (error.code) {
//       case 'user-not-found':
//         return 'No user found for that email.';
//       case 'wrong-password':
//         return 'Wrong password provided for that user.';
//       case 'invalid-email':
//         return 'The email address is badly formatted.';
//       case 'user-disabled':
//         return 'The user account has been disabled by an administrator.';
//       default:
//         return 'An unexpected error occurred: ${error.message}';
//     }
//   }

//   void signUp() async {
//     getRoomId();
//     if (validateSignUpEmail() &&
//         validateSignUpUsername() &&
//         validateSignUpPassword()) {
//       isLoadingSignUp(true);
//       _auth
//           .createUserWithEmailAndPassword(
//               email: signUpEmailController.text,
//               password: signUpPasswordController.text)
//           .then((userCred) {
//         sendEmailVerification(userCred);
//         createUserData(userCred.user!.uid);
//       }).catchError((error) {
//         isLoadingSignUp(false);
//         Get.snackbar("Error while creating account", error.toString());
//       }).whenComplete(() {
//         isLoadingSignUp(false);
//       });
//     }
//   }

//   bool validateLoginEmail() {
//     final email = loginEmailController.text;
//     if (email.isEmpty) {
//       loginEmailError('Email is required');
//       return false;
//     } else if (!EmailValidator.validate(email)) {
//       loginEmailError('Invalid email format');
//       return false;
//     } else {
//       loginEmailError('');
//       return true;
//     }
//   }

//   bool validateLoginPassword() {
//     final password = loginPasswordController.text;
//     if (password.isEmpty) {
//       loginPasswordError('Password is required');
//       return false;
//     } 
//     loginPasswordError('');
//       return true;
//   }

//   bool validateSignUpEmail() {
//     final email = signUpEmailController.text;
//     if (email.isEmpty) {
//       Get.snackbar("Error", "Email is required");
//       signUpEmailError('Email is required');
//       return false;
//     } else if (!EmailValidator.validate(email)) {
//       signUpEmailError('Invalid email format');
//       return false;
//     } else {
//       signUpEmailError('');
//       return true;
//     }
//   }

//   bool validateSignUpUsername() {
//     final username = signUpUsernameController.text;
//     if (username.isEmpty) {
//       signUpUsernameError('Username is required');
//       return false;
//     } else if (username.length < 3) {
//       signUpUsernameError('Username must be at least 3 characters long');
//       return false;
//     } else {
//       signUpUsernameError('');
//       return true;
//     }
//   }

//   bool validateSignUpPassword() {
//     final password = signUpPasswordController.text;
//     if (password.isEmpty) {
//       signUpPasswordError('Password is required');
//       return false;
//     } else if (password.length < 8 || password.length > 15) {
//       signUpPasswordError('Password must be between 8 and 15 characters long');
//       return false;
//     } else if (!RegExp(r'[A-Z]').hasMatch(password) ||
//         !RegExp(r'[a-z]').hasMatch(password) ||
//         !RegExp(r'[0-9]').hasMatch(password) ||
//         !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
//       signUpPasswordError(
//           'Password must contain at least one uppercase letter, one lowercase letter, one digit and one special character');
//       return false;
//     } else {
//       signUpPasswordError('');
//       return true;
//     }
//   }

//   void getRoomId() {
//     roomId = const Uuid().v4().substring(0, 6);
//   }

//   void sendEmailVerification(UserCredential userCredetials) async {
//     userCredetials.user!.sendEmailVerification().then((_) {
//       Get.back();
//       Future.delayed(const Duration(milliseconds: 100), () {
//         Get.snackbar("Verification email sent",
//             "Please check your email and verify your account before login");
//       });
//     }).catchError((error) {
//       Get.snackbar("Error while sending email", error.toString());
//     });
//   }

//   void createUserData(String uid) {
//     _mainstate.userModel.updateAllFields({
//       "uId": uid,
//       "roomId": roomId,
//       "userName": signUpUsernameController.text,
//       "gmail": signUpEmailController.text,
//       "dOb": "",
//       "gender": "Please select your gender",
//       "rtcUid": DateTime.now().millisecondsSinceEpoch,
//       "profileImage": "https://avatar.iran.liara.run/public",
//       "isMailVarified": isMailVarified.value,
//     });

//     _firestore
//         .collection("Users")
//         .doc(uid)
//         .set(_mainstate.userModel.toJson())
//         .then((_) {
//       isLoadingSignUp(false);
//       loginEmailController.text = signUpEmailController.text;
//       Get.back();
//     }).catchError((error) {
//       Get.snackbar("Error while creating account", error.toString());
//     }).whenComplete(() {
//       isLoadingSignUp(false);
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     _auth.currentUser?.reload();
//     if (state == AppLifecycleState.resumed && _auth.currentUser != null) {
//       if (_auth.currentUser!.emailVerified) {
//         _mainstate.updateUserModel(_auth.currentUser!.uid);
//         Get.offAll(() => const HomeScreen());
//       } else {
//         _auth.currentUser!.sendEmailVerification();
//       }
//     }
//   }

//   @override
//   void onInit() {
//     // TODO: implement onInit
//     WidgetsBinding.instance.addObserver(this);
//     super.onInit();
//   }

//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     // TODO: implement onClose
//     super.onClose();
//   }
// }


