import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Bir fişten okunan yapılandırılmış sonuç.
class ReceiptScan {
  final String merchant;
  final double? amount;
  final DateTime? date;
  final String rawText;

  const ReceiptScan({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.rawText,
  });
}

/// Makbuz/fiş görüntüsünü ML Kit ile okuyup tutar, tarih ve satıcıyı ayıklar.
class ReceiptOcrService {
  final ImagePicker _picker = ImagePicker();

  /// Kamera veya galeriden görüntü seçip metin tanır. Kullanıcı iptal ederse
  /// null döner.
  Future<ReceiptScan?> scan(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2000,
    );
    if (file == null) return null;

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(file.path);
      final result = await recognizer.processImage(input);
      return _parse(result.text);
    } finally {
      await recognizer.close();
    }
  }

  ReceiptScan _parse(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return ReceiptScan(
      merchant: lines.isNotEmpty ? lines.first : 'Fiş',
      amount: _findTotal(lines),
      date: _findDate(text),
      rawText: text,
    );
  }

  /// "TOPLAM/TUTAR/TOTAL" içeren satırı önceler; yoksa en büyük tutarı alır.
  double? _findTotal(List<String> lines) {
    double? best;
    for (final line in lines) {
      final upper = line.toUpperCase();
      if (upper.contains('TOPLAM') ||
          upper.contains('TUTAR') ||
          upper.contains('TOTAL')) {
        final value = _amountsIn(line).fold<double?>(
            null, (m, v) => m == null || v > m ? v : m);
        if (value != null) best = best == null || value > best ? value : best;
      }
    }
    if (best != null) return best;

    // Anahtar kelime yoksa: tüm satırlardaki en büyük para değeri.
    for (final line in lines) {
      for (final v in _amountsIn(line)) {
        if (best == null || v > best) best = v;
      }
    }
    return best;
  }

  /// Bir satırdaki tüm para değerlerini (Türkçe biçim) döndürür.
  List<double> _amountsIn(String line) {
    final regex = RegExp(r'\d{1,3}(?:\.\d{3})*,\d{2}|\d+[.,]\d{2}');
    return regex.allMatches(line).map((m) {
      var raw = m.group(0)!;
      // Türkçe biçim: binlik nokta, ondalık virgül.
      if (raw.contains(',')) {
        raw = raw.replaceAll('.', '').replaceAll(',', '.');
      }
      return double.tryParse(raw) ?? 0;
    }).where((v) => v > 0).toList();
  }

  DateTime? _findDate(String text) {
    final regex = RegExp(r'(\d{2})[./-](\d{2})[./-](\d{4})');
    final m = regex.firstMatch(text);
    if (m == null) return null;
    final day = int.tryParse(m.group(1)!);
    final month = int.tryParse(m.group(2)!);
    final year = int.tryParse(m.group(3)!);
    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }
}
