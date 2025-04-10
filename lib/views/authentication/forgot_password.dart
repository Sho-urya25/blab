import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/mainstate_controller.dart';

class ForgatePassword extends StatelessWidget {
  ForgatePassword({super.key});
  final _mainStateController = Get.find<MainStateController>();
  final _controller = TextEditingController();
  final RxBool _isEmailReset = false.obs;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ),
              SizedBox(
                height: 20.h,
              ),
              SvgPicture.asset("assets/svgs/forgot-password.svg",
                  height: context.height * 0.15),
              SizedBox(
                height: 20.h,
              ),
              Center(
                  child: Text(
                "Forgot Password",
                style: TextStyle(fontSize: 25.sp),
              )),
              SizedBox(
                height: 20.h,
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter your email....',
                  contentPadding: EdgeInsets.only(left: 16.w, right: 16.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Obx(
                () {
                  if (_isEmailReset.value) {
                    return const CircularProgressIndicator();
                  } else {
                    return FilledButton(
                        onPressed: () {
                          if (_controller.text.isNotEmpty &&
                              EmailValidator.validate(_controller.text)) {
                            _isEmailReset.value = true;
                            _mainStateController
                                .forgatePassword(_controller.text);
                            _isEmailReset.value = false;
                          } else {
                            Get.snackbar("Error", "Please enter email");
                          }
                        },
                        child: const Text("Send"));
                  }
                },
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
