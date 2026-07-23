import 'transaction.dart';
import 'transaction_category.dart';

/// Tarih ön ayarları (gelişmiş filtre).
enum DatePreset {
  all('Tümü'),
  today('Bugün'),
  yesterday('Dün'),
  thisWeek('Bu Hafta'),
  thisMonth('Bu Ay'),
  lastMonth('Geçen Ay'),
  last3Months('Son 3 Ay');

  final String label;
  const DatePreset(this.label);
}

/// İşlem listesine uygulanan gelişmiş filtre kriterleri.
class TransactionFilter {
  final String query;
  final TransactionType? type;
  final Set<TransactionCategory> categories;
  final DatePreset date;
  final double? min;
  final double? max;

  const TransactionFilter({
    this.query = '',
    this.type,
    this.categories = const {},
    this.date = DatePreset.all,
    this.min,
    this.max,
  });

  static const empty = TransactionFilter();

  bool get isActive =>
      query.isNotEmpty ||
      type != null ||
      categories.isNotEmpty ||
      date != DatePreset.all ||
      min != null ||
      max != null;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _inDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (date) {
      case DatePreset.all:
        return true;
      case DatePreset.today:
        return _sameDay(d, today);
      case DatePreset.yesterday:
        return _sameDay(d, today.subtract(const Duration(days: 1)));
      case DatePreset.thisWeek:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return !d.isBefore(weekStart);
      case DatePreset.thisMonth:
        return d.year == now.year && d.month == now.month;
      case DatePreset.lastMonth:
        final lm = DateTime(now.year, now.month - 1);
        return d.year == lm.year && d.month == lm.month;
      case DatePreset.last3Months:
        final start = DateTime(now.year, now.month - 2, 1);
        return !d.isBefore(start);
    }
  }

  bool matches(AppTransaction t) {
    if (type != null && t.type != type) return false;
    if (categories.isNotEmpty && !categories.contains(t.category)) return false;
    if (!_inDate(t.date)) return false;
    if (min != null && t.amount < min!) return false;
    if (max != null && t.amount > max!) return false;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      if (!t.title.toLowerCase().contains(q) &&
          !t.category.label.toLowerCase().contains(q)) {
        return false;
      }
    }
    return true;
  }

  TransactionFilter copyWith({
    String? query,
    TransactionType? type,
    Set<TransactionCategory>? categories,
    DatePreset? date,
    double? min,
    double? max,
  }) {
    return TransactionFilter(
      query: query ?? this.query,
      type: type ?? this.type,
      categories: categories ?? this.categories,
      date: date ?? this.date,
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }
}
