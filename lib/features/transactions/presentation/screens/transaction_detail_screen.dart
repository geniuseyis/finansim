import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../domain/entities/transaction.dart';
import '../controllers/transaction_controller.dart';
import '../extensions/category_ui.dart';
import '../providers/transaction_providers.dart';

/// İşlem detayını gösteren ekran.
///
/// Tüm alanlar kayıtlı işlemden gelir. Ekran işlem akışını izler; düzenleme
/// sonrası güncel hâli gösterir, işlem silinirse kendiliğinden kapanır.
class TransactionDetailScreen extends ConsumerWidget {
  final AppTransaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AppTransaction transaction,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'İşlemi sil',
      message: 'Bu işlem kalıcı olarak silinecek. Bu eylem geri alınamaz.',
      confirmLabel: 'Sil',
      destructive: true,
    );
    if (!confirmed) return;
    await ref
        .read(transactionControllerProvider.notifier)
        .delete(transaction.id);
    if (context.mounted) context.pop();
  }

  void _share(BuildContext context, AppTransaction t) {
    final sign = t.type == TransactionType.income ? '+' : '-';
    final lines = [
      t.title,
      '$sign${Formatters.currency(t.amount)} · ${t.category.label}',
      Formatters.longDate(t.date),
      if (t.note != null && t.note!.trim().isNotEmpty) t.note!.trim(),
    ];
    final box = context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: lines.join('\n'),
        subject: t.title,
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(transactionsStreamProvider).value;
    final current = all == null
        ? this.transaction
        : all.where((t) => t.id == this.transaction.id).firstOrNull;
    if (current == null) {
      // İşlem başka bir yerden silindi.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.canPop()) context.pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final transaction = current;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onEdit: () => context.push(
                AppRoutes.addTransaction,
                extra: transaction,
              ),
            ),
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
                    const _Label('Kategori'),
                    const SizedBox(height: AppSpacing.sm),
                    _CategoryCard(
                      transaction: transaction,
                      onTap: () => context.push(
                        AppRoutes.addTransaction,
                        extra: transaction,
                      ),
                    ),
                    if (transaction.paymentMethod != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const _Label('Ödeme Yöntemi'),
                      const SizedBox(height: AppSpacing.sm),
                      _PaymentMethodCard(method: transaction.paymentMethod!),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _SummaryCard(transaction: transaction),
                  ],
                ),
              ),
            ),
            _BottomActions(
              onShare: () => _share(context, transaction),
              onDelete: () => _delete(context, ref, transaction),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onEdit;

  const _TopBar({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const AppBackButton(),
          const Expanded(
            child: Center(
              child: Text(
                'İşlem Detayı',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Düzenle',
            icon: const Icon(Icons.edit_outlined),
          ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${Formatters.currency(transaction.amount)}',
            style: TextStyle(
              color: amountColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
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
            child: Icon(
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
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String method;

  const _PaymentMethodCard({required this.method});

  IconData get _icon => switch (method) {
        'Nakit' => Icons.payments_outlined,
        'Kredi Kartı' => Icons.credit_card,
        'Banka Hesabı' => Icons.account_balance_outlined,
        _ => Icons.wallet_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
            child: Icon(_icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            method,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AppTransaction transaction;

  const _SummaryCard({required this.transaction});

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
              _stat(
                Icons.swap_vert,
                AppColors.primary,
                'İşlem Türü',
                transaction.type == TransactionType.income ? 'Gelir' : 'Gider',
                valueColor: transaction.type == TransactionType.income
                    ? AppColors.success
                    : AppColors.error,
              ),
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
            style: TextStyle(
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
