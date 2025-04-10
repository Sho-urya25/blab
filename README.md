# Blab - Video Chat Application

## Overview
Blab is a Flutter-powered video chat application that specializes in connecting users through face-to-face video conversations. The app uses **VideoSDK** for real-time communication and integrates **Google ML Kit** for face detection to enhance user safety and experience.

---

## Key Features
- **Random Video Connections**: Match with new users for spontaneous video chats.
- **Face Detection Technology**: Smart monitoring helps maintain a safe environment.
- **Camera Controls**: Easy switching between front/rear cameras.
- **Audio Management**: Simple mute/unmute functionality.
- **Exit Confirmation**: Prevents accidental call disconnection.

---

## Technical Details

### Core Technologies
- **Frontend Framework**: Flutter with GetX state management.
- **Video Communication**: VideoSDK.io for real-time video.
- **ML Integration**: Google ML Kit for face detection.
- **Responsive Design**: Flutter ScreenUtil for cross-device compatibility.

### Required Permissions
- Camera access.
- Microphone access.
- Internet connectivity.
- Storage (for media sharing).
- Battery optimization exemption (for reliable background operation).

### Supported Platforms
- Android (API level 23+).
- iOS (Coming soon).
- Web version (In development).

---

## Development Information

### Project Structure
- MVC architecture with GetX controllers.
- Responsive UI using Flutter ScreenUtil.
- Firebase backend integration.

### Building the Project
1. Clone the repository.
2. Configure Firebase as per the setup guide.
3. Add VideoSDK API keys to your environment.
4. Run with `flutter run`.

---

## Privacy & Safety
Blab prioritizes user safety with:
- Face detection to ensure appropriate content.
- User reporting mechanisms.
- Secure video connections.

---

## License
This project is proprietary. All rights reserved.