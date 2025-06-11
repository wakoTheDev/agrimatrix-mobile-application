import java.io.FileInputStream
import java.util.Properties
import java.io.File
import java.util.Base64
import java.security.KeyStore

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

// Check if we have all required signing properties
fun hasValidSigningConfig(): Boolean {
    val storeFilePath = getSigningProperty("storeFile", "KEYSTORE_BASE64")
    val storePass = getSigningProperty("storePassword", "STORE_PASSWORD") 
    val alias = getSigningProperty("keyAlias", "KEY_ALIAS")
    val keyPass = getSigningProperty("keyPassword", "KEY_PASSWORD")
    
    return storeFilePath != null && storePass != null && alias != null && keyPass != null
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
        // Only create release signing config if we have valid properties
        if (hasValidSigningConfig()) {
            create("release") {
                val storeFilePath = getSigningProperty("storeFile", "KEYSTORE_BASE64")
                val storePass = getSigningProperty("storePassword", "STORE_PASSWORD") 
                val alias = getSigningProperty("keyAlias", "KEY_ALIAS")
                val keyPass = getSigningProperty("keyPassword", "KEY_PASSWORD")
                
                // Handle base64 encoded keystore for CI/CD
                val keystoreFile = if (System.getenv("KEYSTORE_BASE64") != null) {
                    try {
                        // Clean the base64 string (remove any whitespace/newlines)
                        val cleanBase64 = System.getenv("KEYSTORE_BASE64").replace("\\s".toRegex(), "")
                        println("Base64 keystore length: ${cleanBase64.length}")
                        
                        // Decode base64 keystore and save to temp file
                        val decodedKeystore = Base64.getDecoder().decode(cleanBase64)
                        val tempKeystoreFile = File.createTempFile("keystore", ".jks")
                        tempKeystoreFile.writeBytes(decodedKeystore)
                        println("Successfully created temporary keystore file: ${tempKeystoreFile.absolutePath}")
                        println("Keystore file size: ${tempKeystoreFile.length()} bytes")
                        
                        // Validate keystore can be loaded
                        try {
                            val keyStore = KeyStore.getInstance("JKS")
                            FileInputStream(tempKeystoreFile).use { fis ->
                                keyStore.load(fis, storePass?.toCharArray())
                            }
                            println("Keystore validation successful")
                        } catch (e: Exception) {
                            println("Keystore validation failed: ${e.message}")
                            throw e
                        }
                        
                        tempKeystoreFile
                    } catch (e: Exception) {
                        println("Failed to decode base64 keystore: ${e.message}")
                        null
                    }
                } else {
                    storeFilePath?.let { file(it) }
                }
                
                if (keystoreFile != null) {
                    storeFile = keystoreFile
                    storePassword = storePass!!
                    keyAlias = alias!!
                    keyPassword = keyPass!!
                    println("Release signing configuration loaded successfully")
                    println("Source: ${if (System.getenv("KEYSTORE_BASE64") != null) "GitHub Secrets/Environment Variables" else "Properties File"}")
                } else {
                    throw RuntimeException("Failed to load keystore file")
                }
            }
        } else {
            println("Missing required signing properties. Release build will use debug keystore.")
            println("Available sources:")
            println("  - key.properties file (any of: root, android/, secrets/, ~/.android/)")
            println("  - Environment variables: KEYSTORE_BASE64, STORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD")
            println("  - System properties: -DstoreFile, -DstorePassword, -DkeyAlias, -DkeyPassword")
            println("")
            println("Missing properties:")
            if (getSigningProperty("storeFile", "KEYSTORE_BASE64") == null) println("  - storeFile/KEYSTORE_BASE64")
            if (getSigningProperty("storePassword", "STORE_PASSWORD") == null) println("  - storePassword/STORE_PASSWORD") 
            if (getSigningProperty("keyAlias", "KEY_ALIAS") == null) println("  - keyAlias/KEY_ALIAS")
            if (getSigningProperty("keyPassword", "KEY_PASSWORD") == null) println("  - keyPassword/KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            // Only use release signing config if it exists, otherwise fall back to debug
            signingConfig = if (hasValidSigningConfig()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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