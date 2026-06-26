import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/transaction.dart';
import '../controllers/transaction_controller.dart';
import '../extensions/category_ui.dart';

/// İşlem detayını gösteren ekran.
///
/// Gerçek alanlar (başlık, tutar, tür, tarih, kategori, açıklama) modelden
/// gelir; etiket/konum/ödeme/dekont gibi henüz tutulmayan alanlar tasarıma
/// sadık biçimde örnek (placeholder) gösterilir. "İşlemi Sil" gerçekten siler.
class TransactionDetailScreen extends ConsumerWidget {
  final AppTransaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  String get _trxNo =>
      'TRX-${transaction.date.year}-'
      '${(transaction.id.hashCode % 10000).abs().toString().padLeft(4, '0')}';

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlemi sil'),
        content: const Text('Bu işlemi silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(transactionControllerProvider.notifier)
        .delete(transaction.id);
    if (context.mounted) context.pop();
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özellik yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => context.pop(), onMenu: () => _soon(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderCard(transaction: transaction),
                    const SizedBox(height: AppSpacing.lg),
                    const _Label('Açıklama'),
                    const SizedBox(height: AppSpacing.sm),
                    _DescriptionCard(
                      text: transaction.note ?? 'Açıklama eklenmemiş',
                      onEdit: () => context.push(
                        AppRoutes.addTransaction,
                        extra: transaction,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _Label('Etiketler'),
                    const SizedBox(height: AppSpacing.sm),
                    _TagsRow(onAdd: () => _soon(context)),
                    const SizedBox(height: AppSpacing.lg),
                    const _Label('Kategori'),
                    const SizedBox(height: AppSpacing.sm),
                    _CategoryCard(
                      transaction: transaction,
                      onTap: () => context.push(
                        AppRoutes.addTransaction,
                        extra: transaction,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _Label('Konum'),
                    const SizedBox(height: AppSpacing.sm),
                    const _LocationCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _Label('Ödeme Yöntemi'),
                    const SizedBox(height: AppSpacing.sm),
                    _PaymentCard(onTap: () => _soon(context)),
                    const SizedBox(height: AppSpacing.lg),
                    const _Label('Dekont / Fiş'),
                    const SizedBox(height: AppSpacing.sm),
                    _ReceiptsRow(onAdd: () => _soon(context)),
                    const SizedBox(height: AppSpacing.lg),
                    _SummaryCard(transaction: transaction, trxNo: _trxNo),
                  ],
                ),
              ),
            ),
            _BottomActions(
              onShare: () => _soon(context),
              onDelete: () => _delete(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMenu;

  const _TopBar({required this.onBack, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'İşlem Detayı',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(onPressed: onMenu, icon: const Icon(Icons.more_horiz)),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final AppTransaction transaction;

  const _HeaderCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.success : AppColors.error;
    final categoryColor = transaction.category.color;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(transaction.category.icon, color: categoryColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        transaction.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _TypeBadge(isIncome: isIncome),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${Formatters.longDate(transaction.date)} • '
                  '${Formatters.time(transaction.date)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${Formatters.currency(transaction.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tamamlandı',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.check, size: 13, color: AppColors.success),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isIncome;

  const _TypeBadge({required this.isIncome});

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isIncome ? 'Gelir' : 'Gider',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            isIncome ? Icons.north_east : Icons.south_east,
            size: 13,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String text;
  final VoidCallback onEdit;

  const _DescriptionCard({required this.text, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15)),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  final VoidCallback onAdd;

  const _TagsRow({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _tag('Alışveriş', Icons.shopping_bag_outlined, AppColors.success, true),
        _tag('Market', Icons.shopping_basket_outlined, AppColors.primary, true),
        GestureDetector(
          onTap: onAdd,
          child: _tag('Etiket Ekle', Icons.add, AppColors.accent, false),
        ),
      ],
    );
  }

  Widget _tag(String label, IconData icon, Color color, bool removable) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          if (removable) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.close, size: 14, color: color),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AppTransaction transaction;
  final VoidCallback onTap;

  const _CategoryCard({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = transaction.category.color;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(transaction.category.icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              transaction.category.label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Migros - 212 AVM Şubesi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Mahmutbey, Taşocağı Yolu Cd. No:5, 34218 Bağcılar/İstanbul',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PaymentCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.credit_card, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Text(
              'Kredi Kartı',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const _MastercardLogo(),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            '•••• 4589',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _MastercardLogo extends StatelessWidget {
  const _MastercardLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 20,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            child: CircleAvatar(radius: 10, backgroundColor: Color(0xFFEB001B)),
          ),
          Positioned(
            left: 12,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: const Color(0xFFF79E1B).withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptsRow extends StatelessWidget {
  final VoidCallback onAdd;

  const _ReceiptsRow({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _receiptPlaceholder()),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _receiptPlaceholder()),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _uploadBox(onAdd)),
      ],
    );
  }

  Widget _receiptPlaceholder() {
    return AspectRatio(
      aspectRatio: 0.78,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(
          Icons.receipt_long_outlined,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _uploadBox(VoidCallback onAdd) {
    return AspectRatio(
      aspectRatio: 0.78,
      child: GestureDetector(
        onTap: onAdd,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(AppRadius.md),
            color: AppColors.border,
            strokeWidth: 1.5,
            dashPattern: const [5, 4],
            padding: const EdgeInsets.all(AppSpacing.xs),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add_outlined, color: AppColors.success),
                SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Dekont veya fiş ekle',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'PNG, JPG, PDF',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AppTransaction transaction;
  final String trxNo;

  const _SummaryCard({required this.transaction, required this.trxNo});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İşlem Özeti',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stat(Icons.account_balance_wallet_outlined, AppColors.success,
                  'İşlem Tutarı', Formatters.currency(transaction.amount)),
              _stat(Icons.calendar_today_outlined, AppColors.accent,
                  'İşlem Tarihi', Formatters.longDate(transaction.date),
                  sub: Formatters.time(transaction.date)),
              _stat(Icons.tag, AppColors.warning, 'İşlem No', trxNo),
              _stat(Icons.swap_horiz, AppColors.primary, 'Durum',
                  'Tamamlandı', valueColor: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(
    IconData icon,
    Color color,
    String label,
    String value, {
    String? sub,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          if (sub != null)
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _BottomActions({required this.onShare, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onShare,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ios_share, color: AppColors.primary, size: 20),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Paylaş',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  gradient: const LinearGradient(
                    colors: [AppColors.error, Color(0xFFDC2626)],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white, size: 20),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'İşlemi Sil',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
