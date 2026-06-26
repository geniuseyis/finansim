/// Bir işlemin ait olduğu kategori.
///
/// Enum üyeleri kalıcı anahtar (`name`) olarak saklanır; [label] ise
/// kullanıcıya gösterilen Türkçe metindir. İkon ve renk gibi görsel eşleşmeler
/// presentation katmanında yapılır (domain saf kalır).
enum TransactionCategory {
  general('Genel'),
  salary('Maaş'),
  investment('Yatırım'),
  freelance('Freelance'),
  sales('Satış'),
  food('Yemek'),
  transport('Ulaşım'),
  bills('Faturalar'),
  shopping('Alışveriş'),
  health('Sağlık'),
  entertainment('Eğlence'),
  education('Eğitim'),
  other('Diğer');

  final String label;

  const TransactionCategory(this.label);

  /// Gelir işlemlerinde gösterilen kategoriler (tasarım sırasıyla).
  static const List<TransactionCategory> incomeCategories = [
    general,
    salary,
    investment,
    freelance,
    sales,
    other,
  ];

  /// Gider işlemlerinde gösterilen kategoriler.
  static const List<TransactionCategory> expenseCategories = [
    food,
    transport,
    shopping,
    bills,
    entertainment,
    other,
  ];
}
