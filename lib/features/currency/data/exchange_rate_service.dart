import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Tek bir döviz kurunu (TRY karşısında) temsil eder.
class CurrencyRate {
  final String code; // USD
  final String name; // ABD Doları
  final double buy; // Alış (1 birim başına)
  final double sell; // Satış (1 birim başına)
  final double changePercent; // önceki iş gününe göre
  final List<double> spark; // son günlerin satış serisi

  const CurrencyRate({
    required this.code,
    required this.name,
    required this.buy,
    required this.sell,
    required this.changePercent,
    required this.spark,
  });

  String get pair => '$code/TRY';
}

/// API'den gelen tüm kur verisi + güncelleme zamanı.
class ExchangeData {
  final List<CurrencyRate> rates;
  final DateTime updatedAt;

  const ExchangeData(this.rates, this.updatedAt);

  CurrencyRate? byCode(String code) =>
      rates.where((r) => r.code == code).firstOrNull;
}

class _Raw {
  final double buy;
  final double sell;
  final String name;
  const _Raw(this.buy, this.sell, this.name);
}

/// TCMB günlük kurlarını çeken servis. Hardcoded değer içermez; tüm veriler
/// canlı olarak TCMB'den (XML) alınır.
class ExchangeRateService {
  final http.Client _client;

  ExchangeRateService([http.Client? client])
      : _client = client ?? http.Client();

  static const String _base = 'https://www.tcmb.gov.tr/kurlar';

  /// Güncel kurları + değişim ve sparkline için kısa geçmişi getirir.
  Future<ExchangeData> fetch() async {
    final latest = await _fetchDoc('$_base/today.xml');
    if (latest == null) {
      throw Exception('Kur verisi alınamadı');
    }
    final latestMap = _parse(latest);

    // Son birkaç iş gününün geçmişi (sparkline + değişim için).
    final days = _businessDays(7).skip(1).toList();
    final docs = await Future.wait(days.map((d) => _fetchDoc(_datedUrl(d))));

    // Eskiden yeniye satış serileri.
    final history = <Map<String, double>>[];
    for (final doc in docs.reversed) {
      if (doc == null) continue;
      final m = _parse(doc);
      history.add({for (final e in m.entries) e.key: e.value.sell});
    }
    final latestSell = {
      for (final e in latestMap.entries) e.key: e.value.sell,
    };
    final allSeries = [...history, latestSell];

    final rates = <CurrencyRate>[];
    latestMap.forEach((code, raw) {
      final series = [
        for (final snapshot in allSeries)
          if (snapshot[code] != null) snapshot[code]!,
      ];
      var change = 0.0;
      if (series.length >= 2 && series[series.length - 2] != 0) {
        change = (series.last - series[series.length - 2]) /
            series[series.length - 2] *
            100;
      }
      rates.add(CurrencyRate(
        code: code,
        name: raw.name,
        buy: raw.buy,
        sell: raw.sell,
        changePercent: change,
        spark: series.length >= 2 ? series : [raw.sell, raw.sell],
      ));
    });

    return ExchangeData(rates, DateTime.now());
  }

  Future<XmlDocument?> _fetchDoc(String url) async {
    try {
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      return XmlDocument.parse(res.body);
    } catch (_) {
      return null;
    }
  }

  Map<String, _Raw> _parse(XmlDocument doc) {
    final map = <String, _Raw>{};
    for (final c in doc.findAllElements('Currency')) {
      final code = c.getAttribute('CurrencyCode') ?? c.getAttribute('Kod');
      if (code == null) continue;
      final unit =
          double.tryParse(c.getElement('Unit')?.innerText.trim() ?? '1') ?? 1;
      final buy = double.tryParse(
          (c.getElement('ForexBuying')?.innerText ?? '').trim());
      final sell = double.tryParse(
          (c.getElement('ForexSelling')?.innerText ?? '').trim());
      final name = c.getElement('Isim')?.innerText.trim() ?? code;
      if (buy == null || sell == null || unit == 0) continue;
      map[code] = _Raw(buy / unit, sell / unit, name);
    }
    return map;
  }

  String _datedUrl(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$_base/$yyyy$mm/$dd$mm$yyyy.xml';
  }

  List<DateTime> _businessDays(int n) {
    final out = <DateTime>[];
    var d = DateTime.now();
    while (out.length < n) {
      if (d.weekday <= DateTime.friday) {
        out.add(DateTime(d.year, d.month, d.day));
      }
      d = d.subtract(const Duration(days: 1));
    }
    return out;
  }
}
