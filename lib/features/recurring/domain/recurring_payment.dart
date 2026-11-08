/// Tekrarlayan ödeme sıklığı.
enum PaymentFrequency {
  weekly('Her hafta'),
  monthly('Her ay'),
  quarterly('Her 3 ayda'),
  yearly('Her yıl');

  final String label;
  const PaymentFrequency(this.label);

  /// Verilen tarihten bir sonraki ödeme tarihini hesaplar.
  DateTime advance(DateTime d) {
    switch (this) {
      case PaymentFrequency.weekly:
        return d.add(const Duration(days: 7));
      case PaymentFrequency.monthly:
        return _addMonths(d, 1);
      case PaymentFrequency.quarterly:
        return _addMonths(d, 3);
      case PaymentFrequency.yearly:
        return _addMonths(d, 12);
    }
  }

  /// Ay ekler; hedef ayda o gün yoksa ayın son gününe çeker (31 Ocak → 28 Şubat).
  static DateTime _addMonths(DateTime d, int months) {
    final lastDay = DateTime(d.year, d.month + months + 1, 0).day;
    return DateTime(
        d.year, d.month + months, d.day > lastDay ? lastDay : d.day);
  }

  /// Tutarın aylık karşılığını hesaplamak için çarpan.
  double get monthlyFactor {
    switch (this) {
      case PaymentFrequency.weekly:
        return 52 / 12;
      case PaymentFrequency.monthly:
        return 1;
      case PaymentFrequency.quarterly:
        return 1 / 3;
      case PaymentFrequency.yearly:
        return 1 / 12;
    }
  }
}

/// Tekrarlayan ödemenin durumu.
enum PaymentStatus {
  active('Aktif'),
  paused('Durduruldu'),
  completed('Tamamlandı');

  final String label;
  const PaymentStatus(this.label);
}

/// Bir tekrarlayan ödeme (abonelik / düzenli fatura).
class RecurringPayment {
  final String id;
  final String title;
  final String category;
  final double amount;
  final PaymentFrequency frequency;
  final DateTime nextDate;
  final PaymentStatus status;

  const RecurringPayment({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.frequency,
    required this.nextDate,
    this.status = PaymentStatus.active,
  });

  double get monthlyAmount => amount * frequency.monthlyFactor;

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextDate.year, nextDate.month, nextDate.day);
    return due.difference(today).inDays;
  }

  RecurringPayment copyWith({
    DateTime? nextDate,
    PaymentStatus? status,
  }) {
    return RecurringPayment(
      id: id,
      title: title,
      category: category,
      amount: amount,
      frequency: frequency,
      nextDate: nextDate ?? this.nextDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'amount': amount,
        'frequency': frequency.name,
        'nextDate': nextDate.millisecondsSinceEpoch,
        'status': status.name,
      };

  factory RecurringPayment.fromMap(Map<dynamic, dynamic> map) {
    return RecurringPayment(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      frequency: PaymentFrequency.values.byName(map['frequency'] as String),
      nextDate:
          DateTime.fromMillisecondsSinceEpoch(map['nextDate'] as int),
      status: PaymentStatus.values.byName(
          map['status'] as String? ?? PaymentStatus.active.name),
    );
  }
}
