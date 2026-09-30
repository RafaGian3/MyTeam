import com.android.build.api.dsl.ApplicationExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// AGP 9.x: gunakan configure<ApplicationExtension> bukan android {}
configure<ApplicationExtension> {
    namespace = "com.example.myteam_project"
    compileSdk = 35
    buildToolsVersion = "34.0.0"
    // ndkVersion dihapus - app Flutter murni tidak membutuhkan NDK/CMake

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.myteam_project"
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

// KGP 2.x: atur jvmTarget per task — lebih stabil dari kotlin { compilerOptions {} }
tasks.withType<KotlinJvmCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
