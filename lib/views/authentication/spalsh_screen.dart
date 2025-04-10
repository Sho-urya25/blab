import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpalshScreen extends StatelessWidget {
  const SpalshScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 100.h),
            Center(
              child: SvgPicture.asset(
                'assets/svgs/splash.svg',
                // height: 150.h,
                width: 150.w,
              ),
            ),
            SizedBox(height: 50.h),
            Text("BLAB",
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                )),
            const Spacer(),
            const CircularProgressIndicator(),
            SizedBox(
              height: 50.h,
            )
          ],
        ),
      ),
    );
  }
}
