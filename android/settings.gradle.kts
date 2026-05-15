pluginManagement {
    // 1. نجرب أولا system property اللي بيمرره أمر flutter build
    // 2. إذا مش موجود، نجرب متغير البيئة FLUTTER_ROOT اللي بتستعمله منصات زي FlutLab
    // 3. كملاذ أخير، نوقف البناء ونعطي رسالة خطأ واضحة
    val flutterSdkPath = System.getProperty("flutter.sdk")
        ?: System.getenv("FLUTTER_ROOT")
        ?: error("flutter.sdk not set. Make sure you run via 'flutter build' or set FLUTTER_ROOT environment variable.")

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
