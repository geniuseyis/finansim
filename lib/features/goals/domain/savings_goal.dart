/// Bir birikim hedefi (ör. "Yeni Araba", "Ev Peşinatı").
///
/// Hive'da düz Map olarak saklanır; [iconKey] görsel ikon/rengi belirler
/// (eşleme sunum katmanında yapılır, böylece domain katmanı Flutter'a bağlı
/// kalmaz).
class SavingsGoal {
  final String id;
  final String title;
  final String iconKey;
  final double target;
  final double saved;
  final DateTime? targetDate;
  final bool priority;
  final DateTime createdAt;

  const SavingsGoal({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.target,
    required this.saved,
    required this.createdAt,
    this.targetDate,
    this.priority = false,
  });

  /// Kalan tutar (negatif olmaz).
  double get remaining => (target - saved).clamp(0, double.infinity);

  /// Tamamlanma yüzdesi (0-100).
  int get percent =>
      target <= 0 ? 0 : ((saved / target) * 100).clamp(0, 100).round();

  /// Hedefe ulaşıldı mı?
  bool get isCompleted => target > 0 && saved >= target;

  /// Henüz hiç birikim yapılmamış (planlanmış) hedef.
  bool get isNotStarted => saved <= 0 && !isCompleted;

  SavingsGoal copyWith({
    String? title,
    String? iconKey,
    double? target,
    double? saved,
    DateTime? targetDate,
    bool? priority,
  }) {
    return SavingsGoal(
      id: id,
      title: title ?? this.title,
      iconKey: iconKey ?? this.iconKey,
      target: target ?? this.target,
      saved: saved ?? this.saved,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'target': target,
        'saved': saved,
        'targetDate': targetDate?.millisecondsSinceEpoch,
        'priority': priority,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory SavingsGoal.fromMap(Map map) {
    final td = map['targetDate'] as int?;
    return SavingsGoal(
      id: map['id'] as String,
      title: map['title'] as String,
      iconKey: (map['iconKey'] as String?) ?? 'other',
      target: (map['target'] as num).toDouble(),
      saved: (map['saved'] as num).toDouble(),
      targetDate:
          td == null ? null : DateTime.fromMillisecondsSinceEpoch(td),
      priority: (map['priority'] as bool?) ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAt'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch),
    );
  }
}
