/// Bir işlemin ait olduğu kategori.
///
/// Enum üyeleri kalıcı anahtar (`name`) olarak saklanır; [label] ise
/// kullanıcıya gösterilen Türkçe metindir. İkon ve renk gibi görsel eşleşmeler
/// presentation katmanında yapılır (domain saf kalır).
enum TransactionCategory {
  salary('Maaş'),
  investment('Yatırım'),
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
}
