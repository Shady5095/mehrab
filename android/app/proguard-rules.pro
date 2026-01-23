# Mehrab ProGuard Rules
# Security Configuration for Code Obfuscation
# CWE-656 (Reliance on Security Through Obscurity)

# ========== Flutter Framework ==========
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ========== Firebase ==========
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Firestore
-keepclassmembers class com.google.firebase.firestore.** { *; }
-keep class com.google.type.** { *; }

# Firebase Auth
-keepattributes Signature
-keepattributes *Annotation*

# ========== WebRTC ==========
-keep class org.webrtc.** { *; }
-keep interface org.webrtc.** { *; }
-dontwarn org.webrtc.**

# ========== CallKit ==========
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-dontwarn com.hiennv.flutter_callkit_incoming.**

# ========== Secure Storage ==========
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ========== Dio (HTTP Client) ==========
-keep class io.flutter.plugins.** { *; }
-keep class ** implements io.flutter.plugin.common.MethodCallHandler { *; }

# ========== Gson (JSON Parsing) ==========
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# ========== Model Classes ==========
# Keep all data model classes (adjust package name as needed)
-keep class com.mehrab.mehrab_quran.**.models.** { *; }
-keep class com.mehrab.mehrab_quran.**.data.** { *; }

# ========== Kotlin ==========
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# ========== AndroidX ==========
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# ========== Debug Logging Removal ==========
# Remove all debug logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Remove debug print statements from Flutter
-assumenosideeffects class io.flutter.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ========== Security: Remove Sensitive Methods ==========
# These methods should not be called in production
-assumenosideeffects class ** {
    public static void printStackTrace(...);
}

# ========== Optimization ==========
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# ========== Attributes to Keep ==========
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ========== Native Methods ==========
-keepclasseswithmembernames class * {
    native <methods>;
}

# ========== Enums ==========
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ========== Parcelable ==========
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# ========== Serializable ==========
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ========== Custom Application Class ==========
-keep public class * extends android.app.Application

# ========== Crash Reporting ==========
# Keep crash reporting for production debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ========== Google Play Core ==========
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

