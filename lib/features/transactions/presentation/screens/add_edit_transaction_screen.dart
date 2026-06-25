import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_category.dart';
import '../controllers/transaction_controller.dart';
import '../extensions/category_ui.dart';

/// İşlem ekleme ve düzenleme ekranı.
///
/// [existing] null ise yeni işlem eklenir; doluysa o işlem düzenlenir.
/// Tek ekranı iki amaç için kullanmak kod tekrarını önler (DRY).
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final AppTransaction? existing;

  const AddEditTransactionScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  late TransactionCategory _category;
  late DateTime _date;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(
      text: e != null ? e.amount.toString() : '',
    );
    _noteController = TextEditingController(text: e?.note ?? '');
    _type = e?.type ?? TransactionType.expense;
    _category = e?.category ?? TransactionCategory.food;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Türkçe girişte virgül kullanılabilir; noktaya çevirip parse ederiz.
    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    final note = _noteController.text.trim();

    final transaction = AppTransaction(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: note.isEmpty ? null : note,
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
      appBar: AppBar(
        title: Text(_isEditing ? 'İşlemi Düzenle' : 'Yeni İşlem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gelir / Gider seçimi
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Gider'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Gelir'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) =>
                    setState(() => _type = selection.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Başlık gerekli.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tutar',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final text = value?.trim().replaceAll(',', '.') ?? '';
                  final parsed = double.tryParse(text);
                  if (parsed == null) return 'Geçerli bir tutar girin.';
                  if (parsed <= 0) return 'Tutar sıfırdan büyük olmalı.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: TransactionCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 20),
                            const SizedBox(width: 12),
                            Text(c.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Tarih'),
                subtitle: Text(Formatters.date(_date)),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Değiştir'),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Not (isteğe bağlı)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isLoading ? null : _save,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Güncelle' : 'Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
