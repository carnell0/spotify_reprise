plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android") 
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.spotify_reprise"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // java {
    //     toolchain {
    //         languageVersion = JavaLanguageVersion.of(17) // S'assure que le JDK 17 est utilisé.
    //     }
    // }

    defaultConfig {
        applicationId = "com.example.spotify_reprise"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion 
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
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
    // Si vous avez des dépendances Android natives ici, ajoutez-les.
    // Par exemple:
    // implementation("androidx.work:work-runtime-ktx:2.7.0")
}
