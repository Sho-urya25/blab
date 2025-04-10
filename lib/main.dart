import 'package:blab/views/authentication/spalsh_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/mainstate_controller.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  Get.put<MainStateController>(MainStateController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Login & Signup UI',
          theme: FlexThemeData.light(
            scheme: FlexScheme.damask,
            subThemesData: const FlexSubThemesData(
              interactionEffects: true,
              tintedDisabledControls: true,
              useM2StyleDividerInM3: true,
              inputDecoratorIsFilled: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              alignedDropdown: true,
              navigationRailUseIndicator: true,
              navigationRailLabelType: NavigationRailLabelType.all,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            cupertinoOverrideTheme:
                const CupertinoThemeData(applyThemeToAll: true),
          ),
          darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.damask,
            subThemesData: const FlexSubThemesData(
              interactionEffects: true,
              tintedDisabledControls: true,
              blendOnColors: true,
              useM2StyleDividerInM3: true,
              inputDecoratorIsFilled: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              alignedDropdown: true,
              navigationRailUseIndicator: true,
              navigationRailLabelType: NavigationRailLabelType.all,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            cupertinoOverrideTheme:
                const CupertinoThemeData(applyThemeToAll: true),
          ),
          home: const SpalshScreen(),
        );
      },
    );
  }
}
