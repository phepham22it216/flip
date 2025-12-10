plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flip"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        // ❌ KHÔNG dùng VERSION_21 nữa
        // ✅ Dùng Java 17 (KHÔNG phải Java 8)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // Bật desugaring cho flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Kotlin cũng target 17
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.flip"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ⚠️ BẮT BUỘC phải có, nếu không thì AAR metadata sẽ báo lỗi như log
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Các dependency khác (firebase, google_sign_in, ... của em)
}
