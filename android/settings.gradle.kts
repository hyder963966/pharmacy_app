pluginManagement {
    // الحصول على مسار Flutter SDK الذي يمرره أمر "flutter build" تلقائياً
    val flutterSdkPath = System.getProperty("flutter.sdk") ?: error("flutter.sdk system property not set. Make sure you run via 'flutter build'.")

    // هذا السطر هو المفتاح: يخبر Gradle بمكان إضافة Flutter
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
}

include(":app")
