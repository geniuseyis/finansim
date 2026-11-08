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
  });
}
