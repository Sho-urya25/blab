import 'package:blab/controllers/meeting_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:videosdk/videosdk.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});
  final RxDouble _height = 0.0.obs;
  final meetingCtroll = Get.put<MeetingController>(MeetingController());
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final confirmResult = await Get.defaultDialog<bool>(
              title: "Exit Chatting",
              middleText: "Are you sure you want to exit this Chat?",
              backgroundColor: Colors.white,
              textConfirm: "Yes",
              textCancel: "No",
              titleStyle: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              middleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
              ),
              confirmTextColor: Colors.white,
              onCancel: () {},
              onConfirm: () {
                Get.back(result: true);
              },
            );

            if (confirmResult == true) {
              Navigator.of(context).pop(); // Pop the current route
            }
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Obx(
              () {
                if (meetingCtroll.isLocalPreviewOn.value) {
                  return RTCVideoView(
                    meetingCtroll.localCameraRenderer!,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // if (meetingCtroll.isLocalUserJoined.value) {
                //   return RTCVideoView(
                //     meetingCtroll.localVideoStream?.renderer
                //         as RTCVideoRenderer,
                //     objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                //   );
                // } else {
                //   return const Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
              },
            ),
            Positioned(
              top: AppBar().preferredSize.height + 5,
              right: 8,
              child: SafeArea(
                child: SizedBox(
                  height: Get.height * 0.35,
                  width: Get.width * 0.45,
                  child: Card(
                    child: Stack(
                      children: [
                        Image(
                          image: const NetworkImage(
                              "https://cdn.pixabay.com/photo/2021/11/10/11/13/mulled-wine-6783665_640.jpg"),
                          fit: BoxFit.cover,
                          height: Get.height * 0.35,
                          width: Get.width * 0.45,
                        ),
                        Positioned(
                            bottom: 5,
                            left: 5,
                            child: IconButton.filled(
                                onPressed: () {},
                                icon: const Icon(Icons.change_circle_outlined)))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_height.value == 50.h) {
                  _height.value = 0;
                } else {
                  _height.value = 50.h;
                }
              },
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: Theme.of(context)
                        .appBarTheme
                        .backgroundColor
                        ?.withAlpha(100),
                    elevation: 0,
                    title: const Text("Blab Chat"),
                    leading: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                  )),
            ),
            Obx(
              () {
                return AnimatedPositioned(
                  bottom: 0,
                  duration: const Duration(seconds: 1),
                  child: AnimatedContainer(
                    decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                      ),
                    ),
                    height: _height.value,
                    width: Get.width,
                    duration: const Duration(milliseconds: 380),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //! Mic on off...
                            IconButton.filled(
                                onPressed: () {
                                  print("mic");
                                },
                                icon: const Icon(
                                  Icons.mic,
                                  size: 40,
                                )),
                            //! Call cut.........
                            IconButton.filled(
                              onPressed: () {
                                print("call cut");
                              },
                              icon:
                                  const Icon(Icons.call_end_rounded, size: 40),
                            ),
                            //!  Switch camera.......
                            IconButton.filled(
                              onPressed: () {
                                meetingCtroll.toggleCamera();
                              },
                              icon: const Icon(Icons.cameraswitch_outlined,
                                  size: 40),
                            )
                          ]),
                    ),
                  ),
                );
              },
            ),
          ],
        ));
  }
}
