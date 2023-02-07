
## Details

<!--
1.  Please tell us exactly how to reproduce the problem you are running into.

2.  Please attach a small application (ideally just one main.dart file) that
     reproduces the problem. You could use https://gist.github.com/ for this.

3.  Switch flutter to master channel and run this app on a physical device
     using profile mode with Skia tracing enabled, as follows:
       flutter channel master
       flutter run --profile --trace-skia

     The bleeding edge master channel is encouraged here because Flutter is
     constantly fixing bugs and improving its performance. Your problem in an
     older Flutter version may have already been solved in the master channel.

4.  Record a video of the performance issue using another phone so we
     can have an intuitive understanding of what happened. Don’t use
     "adb screenrecord", as that affects the performance of the profile run.

5.  Open Observatory and save a timeline trace of the performance issue
     so we know which functions might be causing it. See "How to Collect
     and Read Timeline Traces" on this blog post:
       https://medium.com/flutter/profiling-flutter-applications-using-the-timeline-a1a434964af3#a499
     Make sure the performance overlay is turned OFF when recording the
     trace as that may affect the performance of the profile run.
     (Pressing ‘P’ on the command line toggles the overlay.)
-->

# The problem
Using two drawAtlas with atlas and manipulated from it at the same time gets performance issue.
Drawing either the original image or manipulated not at the same time has no performance loss. 
But drawing both simultaneously impacts performance significantly.

- It doesn't make changes whether using `drawAtlas` or `drawRawAtlas`.


## How to reproduce
  1. Load an image and draw it by `drawAtlas()`. You cannot see the issue yet.
  2. Flip the loaded image horizontally or manipulate it and then draw it by `drawAtlas()`.
  3. You can see the jank. Switching the order from (1 => 2) to (2 => 1) also has a jank.

## Reproducible repo
- https://github.com/Hwan-seok/flutter_draw_atlas_performance_issue
- You can see the issue more dramatically after adjusting the slider to around 4000~6000(it depends on testing devices' performance).

## Video of the performance issue

https://user-images.githubusercontent.com/38072762/217324247-954659dc-fa26-4990-af8f-d833a706119a.mp4



<!--
     Please tell us which target platform(s) the problem occurs (Android / iOS / Web / macOS / Linux / Windows)
     Which target OS version, for Web, browser, is the test system running?
     Does the problem occur on emulator/simulator as well as on physical devices?
-->

**Target Platform:** Reproduced on both Android and iOS. I cannot confirm others.
**Target OS version/browser:** Tested on Android 11, 12, and 13. Also iOS 14, 15, and 16.
**Devices:** Simulator, emulator, Galaxy Z flip 3, Galaxy S 10, 20, Galaxy A30, iPhone 12 mini, and iPhone 14 pro.

## Logs

<details>
<summary>Logs</summary>

<!--
     Run `flutter analyze` and attach any output of that command below.
     If there are any analysis errors, try resolving them before filing this issue.
-->

```
No issues found! (ran in 1.1s)
```

<!-- Finally, paste the output of running `flutter doctor -v` here, with your device plugged in. -->

```
[✓] Flutter (Channel master, 3.8.0-6.0.pre.18, on macOS 12.6 21G115 darwin-arm64, locale ko-KR)
    • Flutter version 3.8.0-6.0.pre.18 on channel master at 
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision e8eac0d047 (2 hours ago), 2023-02-07 18:21:18 +0200
    • Engine revision b67690f696
    • Dart version 3.0.0 (build 3.0.0-204.0.dev)
    • DevTools version 2.21.1

[✓] Android toolchain - develop for Android devices (Android SDK version 32.1.0-rc1)
    • Android SDK at 
    • Platform android-33, build-tools 32.1.0-rc1
    • Java binary at: 
    • Java version OpenJDK Runtime Environment (build 11.0.13+0-b1751.21-8125866)
    • All Android licenses accepted.

[✓] Xcode - develop for iOS and macOS (Xcode 14.2)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Build 14C18
    • CocoaPods version 1.11.3

[✓] Chrome - develop for the web
    • Chrome at /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

[✓] Android Studio (version 2021.3)
    • Android Studio at
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 11.0.13+0-b1751.21-8125866)

[✓] Android Studio (version 2021.3)
    • Android Studio at 
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 11.0.13+0-b1751.21-8125866)

[✓] IntelliJ IDEA Ultimate Edition (version 2022.2.4)
    • IntelliJ at 
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart

[✓] IntelliJ IDEA Ultimate Edition (version 2022.2.4)
    • IntelliJ 
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart

[✓] IntelliJ IDEA Ultimate Edition (version 2022.2.3)
    • IntelliJ at 
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart

[✓] VS Code (version 1.75.0)
    • VS Code at /Applications/Visual Studio Code.app/Contents
    • Flutter extension version 3.58.0

[✓] Connected device (4 available)
    • SM F711N (mobile)           • R3CRC0329PF   • android-arm64  • Android 13 (API 33)
    • sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33) (emulator)
    • macOS (desktop)             • macos         • darwin-arm64   • macOS 12.6 21G115 darwin-arm64
    • Chrome (web)                • chrome        • web-javascript • Google Chrome 109.0.5414.119

[✓] HTTP Host Availability
    • All required HTTP hosts are available

• No issues found!
```

</details>
