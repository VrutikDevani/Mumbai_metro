# ===== Razorpay SDK Rules =====
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# ===== Kotlin / AndroidX / Flutter =====
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-keep class androidx.** { *; }
-dontwarn androidx.**
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
