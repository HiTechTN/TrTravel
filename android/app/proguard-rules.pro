# Google ML Kit Text Recognition
-keep class com.google.mlkit.** { *; }
-keepclassmembers class com.google.mlkit.** { *; }
-keepclasseswithmembers class com.google.mlkit.** { *; }

# Keep the TextRecognizer classes that are causing issues
-keep class com.google.mlkit.vision.text.** { *; }
-keepclassmembers class com.google.mlkit.vision.text.** { *; }
-keepclasseswithmembers class com.google.mlkit.vision.text.** { *; }

# Keep specific classes that R8 is complaining about
-keep class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions { *; }
-keep class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder { *; }
-keep class com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions { *; }
-keep class com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder { *; }
-keep class com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions { *; }
-keep class com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder { *; }
-keep class com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions { *; }
-keep class com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder { *; }
