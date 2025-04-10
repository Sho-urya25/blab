import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:blab/universal/token_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:videosdk/videosdk.dart';

import 'mainstate_controller.dart';
import 'permissionshanderler.dart';

class MeetingController extends GetxController {
  late Room room;
  final _mainStateController = Get.find<MainStateController>();
  final ApiService _tokenService = ApiService();
  RxBool isLocalUserJoined = false.obs;
  RxBool isRemoteUserJoined = false.obs;
  List<VideoDeviceInfo>? cameras = [];
  List<AudioDeviceInfo>? microphones = [];
  RxBool isMicOn = true.obs;
  RxBool isCameraOn = true.obs;
  RxBool isLocalPreviewOn = false.obs;
  String? currentRoomID = "";
  Participant? localParticipant;
  Participant? remoteParticipant;
  Stream? localVideoStream;
  Stream? remoteStream;
  bool isRoomInitialized = false;
  RxInt selectedCameraIndex = 1.obs;
  CustomTrack? cameraTrack;
  CustomTrack? microphoneTrack;
  RTCVideoRenderer? localCameraRenderer;

  Future<void> getVSdkTokenRmid() async {
    var token = await _mainStateController.userCredential.user!.getIdToken();
    try {
      var response = await _tokenService.joinRandomRoom(token!);
      await createMeeting(response["token"], response["roomID"]);
      log("Attempting to join the room with ID: ${room.id}");

      try {
        await room.join();
        setupRoomEventListener();
        log("Successfully joined the room with ID: ${room.id}");
      } catch (e) {
        log("Error joining the room: $e");
        Get.snackbar("Error", "Failed to join the room: $e",
            backgroundColor: Colors.red);
      }
    } on Exception catch (e) {
      log(e.toString());
      if (e.toString().contains("You are already in another room")) {
        currentRoomID =
            RegExp(r'roomid: ([\w-]+)').firstMatch(e.toString())?.group(1);
        _tokenService.leaveRoom(token!, currentRoomID!).then((value) {
          log(value.toString());
          currentRoomID = null;
          log("Joining again");
          getVSdkTokenRmid();
        });
      } else {
        Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
      }
    }
  }

  Future<void> createMeeting(String token, String roomId) async {
    isRoomInitialized = true;
    room = VideoSDK.createRoom(
      roomId: roomId,
      displayName: _mainStateController.userModel.userName.value,
      participantId: _mainStateController.userModel.uId.value,
      defaultCameraIndex: 1,
      token: token,
      multiStream: false,
      micEnabled: true, // Enable mic by default
      camEnabled: true, // Enable camera by default
    );
  }

  void setupRoomEventListener() {
    room.on(Events.roomJoined, () async {
      localParticipant = room.localParticipant;

      // Wait for 1 second to allow streams to initialize
      await Future.delayed(const Duration(seconds: 1));

      if (localParticipant!.streams.isEmpty) {
        Get.snackbar(
            "Error", "Local participant streams are empty, enabling cam...");
        await room.enableCam();
      }

      room.localParticipant.streams.forEach((key, Stream stream) {
        log("Stream Kind: ${stream.kind}");
        if (stream.kind == 'video') {
          localVideoStream = stream;
          isLocalUserJoined(true);
        }
      });

      Get.snackbar("New Participant joined the meeting",
          "Room/Meeting joined Successfully");
    });

    // room.on(Events.participantJoined, (Participant participant) async {
    //   localParticipant = room.localParticipant;
    //   room.participants.forEach((key, Participant participant) {
    //     if (!participant.isLocal) {
    //       participant.streams.forEach((key, Stream stream) {
    //         if (stream.kind == "video") {
    //           remoteStream = stream;
    // isRemoteUserJoined(true);
    //         }
    //       });
    //     }
    //   });
    // });
  }

  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isFaceVisible = true;
  Timer? _timer;
  CustomTrack? _customTrack;

  @override
  void onClose() async {
    isLocalPreviewOn.value = false;
    isLocalUserJoined.value = false;
    cameraTrack?.dispose();
    microphoneTrack?.dispose();
    localCameraRenderer?.dispose();
    // if (isRoomInitialized) {
    //   await leaveRoom();
    // }
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
    );
    _initializeCamera();
    // initCameraPreview();
    // await PermissionHandler.requestAllPermissions();
    // if (await PermissionHandler.checkAllPermissions()) {
    //   await getVSdkTokenRmid();
    //   cameras = await VideoSDK.getVideoDevices();
    // } else {
    //   Get.snackbar("Error", "Please grant all permissions to continue",
    //       backgroundColor: Colors.red);
    // }
    super.onInit();
  }

  void initCameraPreview() async {
    if (isCameraOn.value) {
      isLocalPreviewOn.value = false;
      cameras = await VideoSDK.getVideoDevices();
      microphones = await VideoSDK.getAudioDevices();
      for (var element in microphones!) {
        log("Microphone: ${element.label} ID: ${element.deviceId}");
      }
      CustomTrack? track = await VideoSDK.createCameraVideoTrack(
        cameraId: cameras![selectedCameraIndex.value].deviceId,
      );
      RTCVideoRenderer render = RTCVideoRenderer();
      await render.initialize();
      render.setSrcObject(
          stream: track?.mediaStream,
          trackId: track?.mediaStream.getVideoTracks().first.id);
      cameraTrack = track;
      localCameraRenderer = render;
      isLocalPreviewOn.value = true;
    }
    // room.changeCam(device,[])
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera =
        cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    // if (!mounted) return;
    // setState(() {});

    // Create CustomTrack from camera for VideoSDK
    _customTrack = await VideoSDK.createCameraVideoTrack(
      cameraId: frontCamera.name,
    );
    // widget.room.publishTrack(_customTrack!);

    _cameraController!.startImageStream((CameraImage image) {
      if (_timer?.isActive ?? false) return;
      _timer = Timer(Duration(seconds: 3), () async {
        final bytes = _concatenatePlanes(image.planes);
        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        final faces = await _faceDetector.processImage(inputImage);
        bool faceVisibleNow = faces.isNotEmpty;

        if (_isFaceVisible != faceVisibleNow) {
          // setState(() {
          //   _isFaceVisible = faceVisibleNow;
          // });

          if (!faceVisibleNow) {
            debugPrint("🚨 No face detected in local camera!");
            // widget.room.publish("no-face", {"userId": widget.localUserId});
          } else {
            // widget.room.publish("face-visible", {"userId": widget.localUserId});
          }
        }
      });
    });
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  void toggleCamera() async {
    for (var item in cameras!) {
      log("camera label: ${item.label} camera id: ${item.deviceId}");
    }
    if (selectedCameraIndex.value == 0) {
      selectedCameraIndex.value = 1;
      initCameraPreview();
      log("Chnaging to camera  with id : ${cameras![1].deviceId}");
      // await room.changeCam(cameras![1]);
    } else {
      log("Chnaging to camera with id : ${cameras![0].deviceId}");
      selectedCameraIndex.value = 0;
      initCameraPreview();
      // await room.changeCam(cameras![0]);
    }
  }

  Future<void> leaveRoom() async {
    if (isRoomInitialized) {
      var token = await _mainStateController.userCredential.user!.getIdToken();
      _tokenService.leaveRoom(token!, room.id).then((val) {
        room.leave();
        room.end();
        log(val.toString());
      });
    }
  }
}

//!#######################################################################

// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:videosdk/videosdk.dart';

// class JoinScreenController extends GetxController with WidgetsBindingObserver {
//   var token = "".obs;

//   // Control Status
//   var isMicOn = (!kIsWeb && (Platform.isMacOS || Platform.isWindows)).obs;
//   var isCameraOn = (!kIsWeb && (Platform.isMacOS || Platform.isWindows)).obs;

//   CustomTrack? cameraTrack;
//   CustomTrack? microphoneTrack;
//   RTCVideoRenderer? cameraRenderer;

//   var isJoinMeetingSelected = false.obs;
//   var isCreateMeetingSelected = false.obs;

//   var isCameraPermissionAllowed =
//       (!kIsWeb && (Platform.isMacOS || Platform.isWindows)).obs;
//   var isMicrophonePermissionAllowed =
//       (!kIsWeb && (Platform.isMacOS || Platform.isWindows)).obs;

//   VideoDeviceInfo? selectedVideoDevice;
//   AudioDeviceInfo? selectedAudioOutputDevice;
//   AudioDeviceInfo? selectedAudioInputDevice;
//   List<VideoDeviceInfo>? videoDevices;
//   List<AudioDeviceInfo>? audioDevices;
//   List<AudioDeviceInfo> audioInputDevices = [];
//   List<AudioDeviceInfo> audioOutputDevices = [];

//   late Function handler;

//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addObserver(this);

//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     fetchToken().then((value) => token.value = value);
//     checkandReqPermissions();
//     subscribe();
//   }

//   void updateselectedAudioOutputDevice(AudioDeviceInfo? device) {
//     if (device?.deviceId != selectedAudioOutputDevice?.deviceId) {
//       selectedAudioOutputDevice = device;
//       if (!kIsWeb) {
//         if (Platform.isAndroid || Platform.isIOS) {
//           disposeMicTrack();
//           initMic();
//         }
//       }
//     }
//   }

//   void updateselectedAudioInputDevice(AudioDeviceInfo? device) {
//     if (device?.deviceId != selectedAudioInputDevice?.deviceId) {
//       selectedAudioInputDevice = device;
//       disposeMicTrack();
//       initMic();
//     }
//   }

//   void updateSelectedVideoDevice(VideoDeviceInfo? device) {
//     if (device?.deviceId != selectedVideoDevice?.deviceId) {
//       disposeCameraPreview();
//       selectedVideoDevice = device;
//       initCameraPreview();
//     }
//   }

//   Future<void> checkBluetoothPermissions() async {
//     try {
//       bool bluetoothPerm = await VideoSDK.checkBluetoothPermission();
//       if (!bluetoothPerm) {
//         await VideoSDK.requestBluetoothPermission();
//       }
//     } catch (e) {}
//   }

//   void getDevices() async {
//     if (isCameraPermissionAllowed.value) {
//       videoDevices = await VideoSDK.getVideoDevices();
//       selectedVideoDevice = videoDevices?.first;
//       initCameraPreview();
//     }
//     if (isMicrophonePermissionAllowed.value) {
//       audioDevices = await VideoSDK.getAudioDevices();
//       if (!kIsWeb && !Platform.isMacOS && !Platform.isWindows) {
//         //Condition for android and ios devices
//         selectedAudioOutputDevice = audioDevices?.first;
//       } else {
//         audioInputDevices = [];
//         audioOutputDevices = [];
//         for (AudioDeviceInfo device in audioDevices!) {
//           if (device.kind == 'audioinput') {
//             audioInputDevices.add(device);
//           } else {
//             audioOutputDevices.add(device);
//           }
//         }
//         selectedAudioOutputDevice = audioOutputDevices.first;
//         selectedAudioInputDevice = audioInputDevices.first;
//         initMic();
//       }
//     }
//   }

//   void checkandReqPermissions([Permissions? perm]) async {
//     perm ??= Permissions.audio_video;
//     try {
//       if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
//         Map<String, bool> permissions = await VideoSDK.checkPermissions();

//         if (perm == Permissions.audio || perm == Permissions.audio_video) {
//           if (permissions['audio'] != true) {
//             Map<String, bool> reqPermissions =
//                 await VideoSDK.requestPermissions(Permissions.audio);
//             isMicrophonePermissionAllowed.value = reqPermissions['audio']!;
//             isMicOn.value = reqPermissions['audio']!;
//           } else {
//             isMicrophonePermissionAllowed.value = true;
//             isMicOn.value = true;
//           }
//         }

//         if (perm == Permissions.video || perm == Permissions.audio_video) {
//           if (permissions['video'] != true) {
//             Map<String, bool> reqPermissions =
//                 await VideoSDK.requestPermissions(Permissions.video);
//             isCameraPermissionAllowed.value = reqPermissions['video']!;
//           } else {
//             isCameraPermissionAllowed.value = true;
//           }
//         }
//         if (!kIsWeb) {
//           if (Platform.isAndroid) {
//             await checkBluetoothPermissions();
//           }
//         }
//       }
//       getDevices();
//     } catch (e) {}
//   }

//   void checkPermissions() async {
//     if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
//       Map<String, bool> permissions = await VideoSDK.checkPermissions();
//       isMicrophonePermissionAllowed.value = permissions['audio']!;
//       isCameraPermissionAllowed.value = permissions['video']!;
//       isMicOn.value = permissions['audio']!;
//       isCameraOn.value = permissions['video']!;
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         checkPermissions();
//         break;
//     }
//   }

//   @override
//   void onClose() {
//     unsubscribe();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     super.onClose();
//   }

//   void initCameraPreview() async {
//     if (isCameraPermissionAllowed.value) {
//       CustomTrack? track = await VideoSDK.createCameraVideoTrack(
//           cameraId: selectedVideoDevice?.deviceId);
//       RTCVideoRenderer render = RTCVideoRenderer();
//       await render.initialize();
//       render.setSrcObject(
//           stream: track?.mediaStream,
//           trackId: track?.mediaStream.getVideoTracks().first.id);
//       cameraTrack = track;
//       cameraRenderer = render;
//       isCameraOn.value = true;
//     }
//   }

//   void initMic() async {
//     if (isMicrophonePermissionAllowed.value) {
//       CustomTrack? track = await VideoSDK.createMicrophoneAudioTrack(
//           microphoneId: kIsWeb || Platform.isMacOS || Platform.isWindows
//               ? selectedAudioInputDevice?.deviceId
//               : selectedAudioOutputDevice?.deviceId);
//       microphoneTrack = track;
//     }
//   }

//   void disposeCameraPreview() {
//     cameraTrack?.dispose();
//     cameraRenderer = null;
//     cameraTrack = null;
//   }

//   void disposeMicTrack() {
//     microphoneTrack?.dispose();
//     microphoneTrack = null;
//   }

//   void onClickMeetingJoin(meetingId, callType, displayName) async {
//     if (displayName.toString().isEmpty) {
//       displayName = "Guest";
//     }
//     if (isCreateMeetingSelected.value) {
//       createAndJoinMeeting(callType, displayName);
//     } else {
//       joinMeeting(callType, displayName, meetingId);
//     }
//   }

//   Future<void> createAndJoinMeeting(callType, displayName) async {
//     try {
//       var _meetingID = await createMeeting(token.value);
//       cameraRenderer = null;
//       unsubscribe();

//       if (callType == "GROUP") {
//         Get.to(() => ConferenceMeetingScreen(
//               token: token.value,
//               meetingId: _meetingID,
//               displayName: displayName,
//               micEnabled: isMicOn.value,
//               camEnabled: isCameraOn.value,
//               selectedAudioOutputDevice: selectedAudioOutputDevice,
//               selectedAudioInputDevice: selectedAudioInputDevice,
//               cameraTrack: cameraTrack,
//               micTrack: microphoneTrack,
//             ));
//       } else {
//         Get.to(() => OneToOneMeetingScreen(
//             token: token.value,
//             meetingId: _meetingID,
//             displayName: displayName,
//             micEnabled: isMicOn.value,
//             camEnabled: isCameraOn.value,
//             selectedAudioOutputDevice: selectedAudioOutputDevice,
//             selectedAudioInputDevice: selectedAudioInputDevice,
//             cameraTrack: cameraTrack,
//             micTrack: microphoneTrack));
//       }
//     } catch (error) {
//       showSnackBarMessage(message: error.toString(), context: Get.context!);
//     }
//   }

//   Future<void> joinMeeting(callType, displayName, meetingId) async {
//     if (meetingId.isEmpty) {
//       showSnackBarMessage(
//           message: "Please enter Valid Meeting ID", context: Get.context!);
//       return;
//     }
//     var validMeeting = await validateMeeting(token.value, meetingId);
//     if (validMeeting) {
//       cameraRenderer = null;
//       unsubscribe();

//       if (callType == "GROUP") {
//         Get.to(() => ConferenceMeetingScreen(
//             token: token.value,
//             meetingId: meetingId,
//             displayName: displayName,
//             micEnabled: isMicOn.value,
//             camEnabled: isCameraOn.value,
//             selectedAudioOutputDevice: selectedAudioOutputDevice,
//             selectedAudioInputDevice: selectedAudioInputDevice,
//             cameraTrack: cameraTrack,
//             micTrack: microphoneTrack));
//       } else {
//         Get.to(() => OneToOneMeetingScreen(
//             token: token.value,
//             meetingId: meetingId,
//             displayName: displayName,
//             micEnabled: isMicOn.value,
//             camEnabled: isCameraOn.value,
//             selectedAudioOutputDevice: selectedAudioOutputDevice,
//             selectedAudioInputDevice: selectedAudioInputDevice,
//             cameraTrack: cameraTrack,
//             micTrack: microphoneTrack));
//       }
//     } else {
//       showSnackBarMessage(message: "Invalid Meeting ID", context: Get.context!);
//     }
//   }

//   void subscribe() {
//     handler = (devices) {
//       getDevices();
//     };
//     VideoSDK.on(Events.deviceChanged, handler);
//   }

//   void unsubscribe() {
//     VideoSDK.off(Events.deviceChanged, handler);
//   }
// }
