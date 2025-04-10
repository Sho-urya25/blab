import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';


class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                SvgPicture.asset('assets/svgs/signup.svg', height: 100.h),
                Text(
                  'Sign Up',
                  style:
                      TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: authController.signUpEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    contentPadding: EdgeInsets.only(left: 16.w, right: 16.w),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w)),
                    errorText: authController.signUpEmailError.value.isNotEmpty
                        ? authController.signUpEmailError.value
                        : null,
                  ),
                  onChanged: (value) => authController.validateSignUpEmail(),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: authController.signUpUsernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    contentPadding: EdgeInsets.only(left: 16.w, right: 16.w),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w)),
                    errorText:
                        authController.signUpUsernameError.value.isNotEmpty
                            ? authController.signUpUsernameError.value
                            : null,
                  ),
                  onChanged: (value) => authController.validateSignUpUsername(),
                ),
                SizedBox(height: 16.h),
                Obx(() => TextField(
                      controller: authController.signUpPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding:
                            EdgeInsets.only(left: 16.w, right: 16.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        errorText:
                            authController.signUpPasswordError.value.isNotEmpty
                                ? authController.signUpPasswordError.value
                                : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            authController.isSignUpPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              authController.toggleSignUpPasswordVisibility,
                        ),
                      ),
                      obscureText:
                          !authController.isSignUpPasswordVisible.value,
                      onChanged: (value) =>
                          authController.validateSignUpPassword(),
                    )),
                SizedBox(height: 24.h),
                Obx(
                  () {
                    return authController.isLoadingSignUp.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: authController.signUp,
                            child: Text('Sign Up',
                                style: TextStyle(fontSize: 18.sp)),
                          );
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    const Spacer(),
                    Text('Already have an account?',
                        style: TextStyle(fontSize: 16.sp)),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Login', style: TextStyle(fontSize: 16.sp)),
                    ),
                    const Spacer()
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
