import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_category.dart';
import '../controllers/transaction_controller.dart';
import '../extensions/category_ui.dart';

/// İşlem ekleme ve düzenleme ekranı (premium tasarım).
///
/// [existing] null ise yeni işlem, doluysa düzenleme. Gelir/Gider seçimine göre
/// kategori listesi değişir. Kaydetme Hive üzerinden gerçek olarak çalışır.
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final AppTransaction? existing;

  const AddEditTransactionScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  late TransactionType _type;
  late TransactionCategory _category;
  late DateTime _date;
  String _paymentMethod = 'Banka Hesabı';

  bool get _isEditing => widget.existing != null;

  List<TransactionCategory> get _categories => _type == TransactionType.income
      ? TransactionCategory.incomeCategories
      : TransactionCategory.expenseCategories;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? TransactionType.income;
    _date = e?.date ?? DateTime.now();
    _descController.text = e?.note ?? '';
    if (e != null) {
      _amountController.text = e.amount.toString();
      _category = e.category;
    } else {
      _category = _categories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _type = type;
      if (!_categories.contains(_category)) _category = _categories.first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickPaymentMethod() async {
    const options = ['Banka Hesabı', 'Nakit', 'Kredi Kartı', 'Diğer'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                title: Text(option),
                trailing: _paymentMethod == option
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _paymentMethod = selected);
  }

  Future<void> _save() async {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir tutar girin.')),
      );
      return;
    }
    final desc = _descController.text.trim();
    final transaction = AppTransaction(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: desc.isNotEmpty ? desc : _category.label,
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: desc.isEmpty ? null : desc,
    );

    final controller = ref.read(transactionControllerProvider.notifier);
    final success = _isEditing
        ? await controller.updateTransaction(transaction)
        : await controller.add(transaction);

    if (!mounted) return;
    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem kaydedilemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(transactionControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: _isEditing ? 'İşlemi Düzenle' : 'İşlem Ekle',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xs,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TypeToggle(type: _type, onChanged: _onTypeChanged),
                    const SizedBox(height: AppSpacing.xl),
                    _AmountCard(controller: _amountController),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel('Kategori'),
                    const SizedBox(height: AppSpacing.md),
                    _CategorySelector(
                      categories: _categories,
                      selected: _category,
                      onSelected: (c) => setState(() => _category = c),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel('Tarih'),
                    const SizedBox(height: AppSpacing.sm),
                    _FieldShell(
                      leading: Icons.calendar_today_outlined,
                      text: Formatters.longDate(_date),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel('Açıklama'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _descController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Açıklama giriniz (isteğe bağlı)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel('Ödeme Yöntemi'),
                    const SizedBox(height: AppSpacing.sm),
                    _FieldShell(
                      leading: Icons.credit_card,
                      text: _paymentMethod,
                      onTap: _pickPaymentMethod,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel(
                      'Makbuz Ekle',
                      hint: ' (İsteğe bağlı)',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ReceiptArea(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Makbuz yükleme yakında eklenecek.'),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SaveButton(
                      loading: isLoading,
                      onTap: isLoading ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Geri oku + ortalı başlık içeren üst bar.
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Gelir / Gider segmenti.
class _TypeToggle extends StatelessWidget {
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _segment(
            label: 'Gelir',
            icon: Icons.north_east,
            color: AppColors.success,
            active: type == TransactionType.income,
            onTap: () => onChanged(TransactionType.income),
          ),
          _segment(
            label: 'Gider',
            icon: Icons.south_east,
            color: AppColors.error,
            active: type == TransactionType.expense,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required IconData icon,
    required Color color,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: active
                ? LinearGradient(
                    colors: [color, Color.lerp(color, Colors.black, 0.12)!],
                  )
                : null,
            color: active ? null : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? Colors.white.withValues(alpha: 0.25)
                      : color.withValues(alpha: 0.12),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: active ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tutar kartı: "Tutar" etiketi + büyük tutar girişi + para birimi seçici.
class _AmountCard extends StatelessWidget {
  final TextEditingController controller;

  const _AmountCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tutar',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    prefixText: '₺',
                    hintText: '0,00',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CurrencyChip(),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TRY',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}

/// Bölüm başlığı (kalın) + opsiyonel açık gri ipucu.
class _SectionLabel extends StatelessWidget {
  final String text;
  final String? hint;

  const _SectionLabel(this.text, {this.hint});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        children: [
          if (hint != null)
            TextSpan(
              text: hint,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Yatay kategori seçici.
class _CategorySelector extends StatelessWidget {
  final List<TransactionCategory> categories;
  final TransactionCategory selected;
  final ValueChanged<TransactionCategory> onSelected;

  const _CategorySelector({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return GestureDetector(
            onTap: () => onSelected(category),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: isSelected
                          ? Border.all(color: category.color, width: 2)
                          : null,
                    ),
                    child: Icon(category.icon, color: category.color),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? category.color
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// İkon + metin + açılır ok içeren tıklanabilir alan (tarih, ödeme yöntemi).
class _FieldShell extends StatelessWidget {
  final IconData leading;
  final String text;
  final VoidCallback onTap;

  const _FieldShell({
    required this.leading,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(leading, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kesik çizgili makbuz yükleme alanı.
class _ReceiptArea extends StatelessWidget {
  final VoidCallback onTap;

  const _ReceiptArea({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(AppRadius.input),
          color: AppColors.border,
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
          padding: const EdgeInsets.all(AppSpacing.xl),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.note_add_outlined,
                size: 40,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Makbuz veya fatura ekleyin',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              const Text(
                'PNG, JPG veya PDF (Maks. 5MB)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mavi degrade kaydet butonu.
class _SaveButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _SaveButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Kaydet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
      ),
    );
  }
}
