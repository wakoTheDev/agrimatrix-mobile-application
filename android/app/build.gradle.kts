import java.io.FileInputStream
import java.util.Properties
import java.io.File
import java.util.Base64

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Dynamic signing configuration with multiple fallback sources
val keystoreProperties = Properties()

// Try to load from multiple sources in order of preference
val possiblePropertyFiles = listOf(
    rootProject.file("key.properties"),           // Local development
    rootProject.file("android/key.properties"),   // Alternative local path
    rootProject.file("secrets/key.properties"),   // Secrets directory
    File(System.getProperty("user.home"), ".android/key.properties")  // User home directory
)

// Load properties from the first available file
val loadedFromFile = possiblePropertyFiles.firstOrNull { it.exists() }?.let { file ->
    try {
        keystoreProperties.load(FileInputStream(file))
        println("Loaded signing properties from: ${file.absolutePath}")
        true
    } catch (e: Exception) {
        println("Failed to load properties from ${file.absolutePath}: ${e.message}")
        false
    }
} ?: false

// Fallback to environment variables if no file is found
if (!loadedFromFile) {
    println("No key.properties file found, checking environment variables...")
    System.getenv("KEYSTORE_BASE64")?.let { keystoreProperties["storeFile"] = it }
    System.getenv("STORE_PASSWORD")?.let { keystoreProperties["storePassword"] = it }
    System.getenv("KEY_ALIAS")?.let { keystoreProperties["keyAlias"] = it }
    System.getenv("KEY_PASSWORD")?.let { keystoreProperties["keyPassword"] = it }
}

// Helper function to get property with fallback to GitHub secrets
fun getSigningProperty(key: String, envKey: String? = null): String? {
    return keystoreProperties.getProperty(key) 
        ?: envKey?.let { System.getenv(it) }
        ?: System.getProperty(key)
}

android {
    namespace = "com.example.agrimatrix"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Override Flutter's NDK version for Firebase compatibility

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.agrimatrix"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23 // Override Flutter's minSdk for Firebase Auth compatibility
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = getSigningProperty("storeFile", "KEYSTORE_BASE64")
            val storePass = getSigningProperty("storePassword", "STORE_PASSWORD") 
            val alias = getSigningProperty("keyAlias", "KEY_ALIAS")
            val keyPass = getSigningProperty("keyPassword", "KEY_PASSWORD")
            
            // Handle base64 encoded keystore for CI/CD
            val keystoreFile = if (System.getenv("KEYSTORE_BASE64") != null) {
                // Decode base64 keystore and save to temp file
                val decodedKeystore = Base64.getDecoder().decode(System.getenv("KEYSTORE_BASE64"))
                val tempKeystoreFile = File.createTempFile("keystore", ".jks")
                tempKeystoreFile.writeBytes(decodedKeystore)
                tempKeystoreFile
            } else {
                storeFilePath?.let { file(it) }
            }
            
            // Only configure if all required properties are available
            if (keystoreFile != null && storePass != null && alias != null && keyPass != null) {
                storeFile = keystoreFile
                storePassword = storePass
                keyAlias = alias
                keyPassword = keyPass
                println("Release signing configuration loaded successfully")
                println("Source: ${if (System.getenv("KEYSTORE_BASE64") != null) "GitHub Secrets/Environment Variables" else "Properties File"}")
            } else {
                println("Missing required signing properties. Release build will use debug keystore.")
                println("Available sources:")
                println("  - key.properties file (any of: root, android/, secrets/, ~/.android/)")
                println("  - Environment variables: KEYSTORE_BASE64, STORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD")
                println("  - System properties: -DstoreFile, -DstorePassword, -DkeyAlias, -DkeyPassword")
                println("")
                println("Missing properties:")
                if (keystoreFile == null) println("  - storeFile/KEYSTORE_BASE64")
                if (storePass == null) println("  - storePassword/STORE_PASSWORD") 
                if (alias == null) println("  - keyAlias/KEY_ALIAS")
                if (keyPass == null) println("  - keyPassword/KEY_PASSWORD")
                
                // Don't configure release signing - let it fall back to debug
                enableV1Signing = true
                enableV2Signing = true
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:32.2.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
}

flutter {
    source = "../.."
}