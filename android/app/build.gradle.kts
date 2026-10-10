import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val appIdentityProperties = Properties().apply {
    val identityFile = file("AppIdentity.properties")

    check(identityFile.exists()) {
        "Missing ${identityFile.path}. Run: dart run tool/configure_app.dart --apply"
    }

    identityFile.reader(Charsets.UTF_8).use { reader ->
        load(reader)
    }
}

fun appIdentity(key: String): String =
    checkNotNull(appIdentityProperties.getProperty(key)) {
        "Missing app identity property: $key"
    }

android {
    namespace = appIdentity("androidNamespace")
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = appIdentity("androidApplicationId")

        manifestPlaceholders["appName"] =
            appIdentity("productionDisplayName")

        manifestPlaceholders["appScheme"] =
            appIdentity("productionAppScheme")

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("production") {
            dimension = "environment"
        }

        create("staging") {
            dimension = "environment"

            applicationId =
                appIdentity("stagingApplicationId")

            manifestPlaceholders["appName"] =
                appIdentity("stagingDisplayName")

            manifestPlaceholders["appScheme"] =
                appIdentity("stagingAppScheme")
        }
    }

    buildTypes {
        release {
            // TODO: Add the production signing configuration.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
