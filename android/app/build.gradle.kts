import java.security.KeyStore
import java.security.MessageDigest
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val releaseTaskRequested = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }
val expectedReleaseSigningSha1 = "A9:70:60:36:51:26:B2:9A:F5:21:B6:30:89:00:A6:E0:8E:F3:2A:97"

if (releaseTaskRequested) {
    require(keystorePropertiesFile.exists()) { "Release signing requires android/key.properties and the church keystore." }

    val storeFilePath = requireNotNull(keystoreProperties.getProperty("storeFile")) {
        "Release signing requires storeFile in android/key.properties."
    }
    val storePassword = requireNotNull(keystoreProperties.getProperty("storePassword")) {
        "Release signing requires storePassword in android/key.properties."
    }
    val keyAlias = requireNotNull(keystoreProperties.getProperty("keyAlias")) {
        "Release signing requires keyAlias in android/key.properties."
    }
    val releaseStoreFile = file(storeFilePath)
    require(releaseStoreFile.isFile) { "The configured release keystore does not exist." }

    val keyStore = KeyStore.getInstance(KeyStore.getDefaultType())
    releaseStoreFile.inputStream().use { stream ->
        keyStore.load(stream, storePassword.toCharArray())
    }
    val certificate = requireNotNull(keyStore.getCertificate(keyAlias)) {
        "The configured release key alias does not exist in the keystore."
    }
    val actualReleaseSigningSha1 = MessageDigest.getInstance("SHA-1")
        .digest(certificate.encoded)
        .joinToString(":") { byte -> "%02X".format(byte) }
    require(actualReleaseSigningSha1 == expectedReleaseSigningSha1) {
        "Wrong Android release signing certificate. Expected $expectedReleaseSigningSha1 but found $actualReleaseSigningSha1."
    }
}

android {
    namespace = "com.rtci.app.rtc_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rtci.app.rtc_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Release artifacts must never silently use the debug identity.
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.14.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("androidx.credentials:credentials:1.3.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.3.0")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.1.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
