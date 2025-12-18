plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    // 🔴 تأكد أن هذا هو اسم الحزمة الخاص بك
    namespace = "com.moamal.attarshop"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // 🔴 وتأكد من هنا أيضاً
        applicationId = "com.moamal.attarshop"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // ✅ الإعدادات الصحيحة للمفتاح الجديد
            keyAlias = "upload"
            // 👇 اكتب هنا كلمة المرور التي وضعتها عند إنشاء المفتاح (مثلاً 12345678)
            keyPassword = "Moamal12"
            storePassword = "Moamal12"
            storeFile = file("upload-keystore.jks")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}