import 'package:financeapp/features/ocr/data/receipt_ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseReceiptText', () {
    test('satıcı ilk dolu satırdır', () {
      expect(parseReceiptText('\n  MİGROS  \nTOPLAM 10,00').merchant, 'MİGROS');
    });
  });
}
