import 'package:financeapp/features/ocr/data/receipt_ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseReceiptText', () {
    test('satıcı ilk dolu satırdır', () {
      expect(parseReceiptText('\n  MİGROS  \nTOPLAM 10,00').merchant, 'MİGROS');
    });

    test('boş metinde tutar ve tarih yok', () {
      final r = parseReceiptText('');
      expect(r.merchant, 'Fiş');
      expect(r.amount, isNull);
      expect(r.date, isNull);
    });

    test('toplam satırı tercih edilir', () {
      expect(parseReceiptText('A\nÜRÜN 999,00\nTOPLAM 118,50').amount, 118.5);
    });

    test('birden çok toplamda en büyüğü alınır', () {
      expect(parseReceiptText('ARA TOPLAM 100,00\nGENEL TOPLAM 118,00').amount, 118);
    });
    test('TOTAL anahtar kelimesi tanınır', () {
      expect(parseReceiptText('SHOP\nItem 5.00\nTotal 12.50').amount, 12.5);
    });

    test('anahtar kelime yoksa en büyük tutar alınır', () {
      expect(parseReceiptText('A\n12,00\n45,90\n3,50').amount, 45.9);
    });

    test('Türkçe binlik ayırıcı okunur', () {
      expect(parseReceiptText('TOPLAM 1.250,75').amount, 1250.75);
    });
    test('virgüllü binlik ayırıcı okunur', () {
      expect(parseReceiptText('TOTAL 1,250.75').amount, 1250.75);
    });

    test('tutarsız metinde sonuç yok', () {
      expect(parseReceiptText('TEŞEKKÜRLER').amount, isNull);
    });

    test('noktalı tarih okunur', () {
      expect(parseReceiptText('08.11.2026').date, DateTime(2026, 11, 8));
    });
    test('bölü ve tireli tarih okunur', () {
      expect(parseReceiptText('08/11/2026').date, DateTime(2026, 11, 8));
      expect(parseReceiptText('08-11-2026').date, DateTime(2026, 11, 8));
    });

    test('olmayan tarih reddedilir', () {
      expect(parseReceiptText('31.02.2026').date, isNull);
      expect(parseReceiptText('12.13.2026').date, isNull);
      expect(parseReceiptText('00.05.2026').date, isNull);
    });
  });
}
