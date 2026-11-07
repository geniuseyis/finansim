# ML Kit metin tanıma yalnızca Latin modeliyle paketlenir; diğer dil
# modellerine yapılan referanslar R8'de eksik sınıf hatası vermesin.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
