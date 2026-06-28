# Flutter engine + embedding
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# flutter_local_notifications (uses Gson + reflection internally)
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# image_picker / geolocator / url_launcher ship their own consumer rules,
# but keep their entry points to be safe.
-keep class io.flutter.plugins.imagepicker.** { *; }

# The app parses JSON manually (fromJson), so no model keep-rules are required.
