import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.richzspotNewMobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") { // Menggunakan create untuk mendefinisikan konfigurasi baru
            if (keystoreProperties.getProperty("storeFile") != null &&
                rootProject.file(keystoreProperties.getProperty("storeFile")).exists()) {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            } else {
                println(">>> Keystore rilis tidak dikonfigurasi atau file tidak ditemukan di " + (keystoreProperties.getProperty("storeFile") ?: "path tidak diset") + ". Build rilis mungkin menggunakan kunci debug atau gagal.")
                // Opsi: Jika ingin build tetap jalan dengan debug key (JANGAN untuk Play Store):
                // getByName("debug"). Ganti dengan ini jika fallback ke debug diperlukan.
                // Tapi untuk rilis sesungguhnya, ini harus resolve atau build gagal.
            }
        }
    }

    defaultConfig {
        applicationId = "com.richzspotNewMobile"
        minSdk = flutter.minSdkVersion // Menggunakan variabel Flutter lebih baik
        targetSdk = flutter.targetSdkVersion // Menggunakan variabel Flutter lebih baik
        versionCode = 6
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") { // Menggunakan getByName untuk mengakses build type yang sudah ada
            isMinifyEnabled = true
            isShrinkResources = true // Direkomendasikan untuk rilis
            // Gunakan konfigurasi penandatanganan "release"
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
        // getByName("debug") {
        //     signingConfig = signingConfigs.getByName("debug") // Ini biasanya default
        // }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}