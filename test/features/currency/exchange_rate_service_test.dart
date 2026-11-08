import 'package:financeapp/features/currency/data/exchange_rate_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String doc(String body) => '<Tarih_Date>$body</Tarih_Date>';

String usd(String sell, {String unit = '1', String buy = '30.00'}) =>
    '<Currency Kod="USD" CurrencyCode="USD"><Unit>$unit</Unit><Isim>ABD DOLARI</Isim>'
    '<ForexBuying>$buy</ForexBuying><ForexSelling>$sell</ForexSelling></Currency>';

ExchangeRateService service(String today, {String? history}) =>
    ExchangeRateService(MockClient((req) async {
      if (req.url.path.endsWith('today.xml')) return http.Response(today, 200);
      return history == null ? http.Response('', 404) : http.Response(history, 200);
    }));

void main() {
  group('ExchangeRateService', () {
    test('alış ve satış okunur', () async {
      final data = await service(doc(usd('31.00'))).fetch();
      final r = data.byCode('USD')!;
      expect(r.buy, 30);
      expect(r.sell, 31);
      expect(r.name, 'ABD DOLARI');
    });

    test('kur birim başına çevrilir', () async {
      final data = await service(doc(usd('200.00', unit: '100', buy: '100.00'))).fetch();
      expect(data.byCode('USD')!.sell, 2);
      expect(data.byCode('USD')!.buy, 1);
    });

    test('fiyatı eksik kur atlanır', () async {
      final data = await service(doc(usd('')), history: null).fetch();
      expect(data.rates, isEmpty);
    });

    test('güncel kur alınamazsa hata verir', () async {
      final s = ExchangeRateService(MockClient((_) async => http.Response('', 500)));
      expect(s.fetch(), throwsException);
    });
    test('bozuk XML hata verir', () async {
      expect(service('<bozuk').fetch(), throwsException);
    });
  });
}
