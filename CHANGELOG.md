## 1.1.4

* Added Swift Package Manager support for iOS (CocoaPods is still supported).
* **Breaking:** now requires Flutter 3.44.0 or newer, because the iOS Swift package declares the
  `FlutterFramework` dependency introduced in that release. Stay on 1.1.3 for older Flutter versions.
* Merged the Objective-C plugin wrapper into `WhatsappStickersPlugin.swift`; the iOS plugin is now pure Swift.
* Removed the `VALID_ARCHS[sdk=iphonesimulator*] = x86_64` restriction so the plugin builds for arm64 simulators on Apple Silicon.
* Replaced the removed `jcenter()` repository with `mavenCentral()` in the Android `build.gradle`.
* Made the Android `kotlin-android` plugin application conditional on the Android Gradle Plugin
  version, so the plugin now also builds on Android Gradle Plugin 9+ (built-in Kotlin), while
  remaining compatible with older AGP versions.
* Fixed a Kotlin null-safety compile error in `WhatsappStickersPlugin.kt` (`onActivityResult`) that
  was exposed by newer Kotlin compiler versions.

## 1.1.3

* Update Android build files

## 1.1.2

* update ios build files
* update android build files

## 1.1.1

* Overwrite `toString()` for exceptions

## 1.1.0

* Added 2 extra exceptions `WhatsappStickersAlreadyAddedException` and `WhatsappStickersCancelledException`
* Fixed missing else statement handling on Android when cancel prompt

## 1.0.0

* Upgraded dependencies to make sure Android and iOS are up to date.
* Replaced `YYImage` with `SDWebImageWebPCoder` as `YYImage` no longer maintain to support ARM.

## 0.1.0-nullsafety.0

* Null safety has been added.

## 0.0.4

* Possible workaround for "operation couldn't be completed (com.third-party-stickers error 1000)" on iOS.

## 0.0.3

* Android compatibility has been added.

## 0.0.2

* iOS part has been rewritten and is not backward compatible

## 0.0.1

* Added initial support of iOS
