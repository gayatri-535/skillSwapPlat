-keep public class com.skillswap.platform.** { public *; }

# Google AndroidBrowserHelper
-keep public class com.google.androidbrowserhelper.** { public *; }

# AndroidX
-keep class androidx.** { *; }
-keepclassmembers class androidx.** { *; }

# Keep Native Methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep constructors
-keepclasseswithmembers class * {
    public <init>(...);
}

# General
-dontwarn android.**
-dontwarn androidx.**
-dontwarn com.google.**
