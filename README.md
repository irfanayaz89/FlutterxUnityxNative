# Flutter_x_Unity_x_Native

# Setup the project

1) Download and Install Git LFS from https://git-lfs.github.com/
2) Clone the project

# Steps to build iOS

3) Go to directory 'cd FlutterxUnityxNative/ios'
4) Open the xcworkspace 'Runner.xcworkspace' and select the target Runner. Go tab 'Signing and Capabilities' and select an appropriate Team for the Apple Developer Account. 
5) Go back to the main directory (FlutterxUnityxNative) 'cd ..' and run the command 'flutter build ios'. Make sure the build runs successfully.
6) Attach an iOS device and run the project using XCode after selecting the attached device or run using flutter command 'flutter run'.

# Steps to build Android

7) Go to the main directory 'FlutterxUnityxNative' and run the command 'flutter build apk --debug'
8) Use Android Studio to run the project.
9) If you encounter this error 'could not setcwd() (errno 2: No such file or directory)', go to the android folder inside project repo and delete '.idea' and '.gradle' folders. Go to your gradle home directory and delete 'caches' folder. In the Android Studio, Go to File > Invalidate Caches / Restart and press the 'Invalidate and Restart' button.
10) Press the Gradle sync button and run the app.