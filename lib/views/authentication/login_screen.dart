import 'package:blab/views/authentication/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final AuthController authController =
      Get.put<AuthController>(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                SvgPicture.asset('assets/svgs/login.svg', height: 100.h),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Login',
                    style:
                        TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: authController.loginEmailController,
                  decoration: InputDecoration(
                    // suffixIcon: TextButton(
                    //     onPressed: () {
                    //       // authController.sendEmailVerification();
                    //     },
                    //     child: const Text("Verify")),
                    labelText: 'Email',
                    contentPadding: EdgeInsets.only(left: 16.w, right: 16.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    errorText: authController.errorLogin.value.isNotEmpty
                        ? authController.errorLogin.value
                        : null,
                  ),
                  onChanged: (value) => authController.validateLoginEmail(),
                ),
                SizedBox(height: 16.h),
                Obx(() => TextField(
                      controller: authController.loginPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding:
                            EdgeInsets.only(left: 16.w, right: 16.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        errorText:
                            authController.loginPasswordError.value.isNotEmpty
                                ? authController.loginPasswordError.value
                                : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            authController.isLoginPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              authController.toggleLoginPasswordVisibility,
                        ),
                      ),
                      obscureText: !authController.isLoginPasswordVisible.value,
                      onChanged: (value) =>
                          authController.validateLoginPassword(),
                    )),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Get.bottomSheet(ForgatePassword()),
                      child: Text('Forgot Password?',
                          style: TextStyle(fontSize: 16.sp)),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Obx(
                  () {
                    return authController.isLoadingLogin.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => authController.login(null, null),
                            child: Text('Login',
                                style: TextStyle(fontSize: 18.sp)),
                          );
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    const Spacer(),
                    Text('Don\'t have an account?',
                        style: TextStyle(fontSize: 16.sp)),
                    TextButton(
                      onPressed: () => Get.to(SignUpScreen(),
                          transition: Transition.size,
                          duration: const Duration(milliseconds: 900)),
                      child: Text('Sign Up', style: TextStyle(fontSize: 16.sp)),
                    ),
                    const Spacer()
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
