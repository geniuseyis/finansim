import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../recurring/presentation/providers/recurring_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Gerçek verilerden türetilmiş bir bildirim.
class AppNotification {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime when;
  final bool important;

  const AppNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.when,
    this.important = false,
  });
}

/// Kullanıcının gerçek verilerinden (bütçe, tekrarlayan ödeme, hedef, işlem)
/// bildirim listesi üretir.
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final now = DateTime.now();
  final items = <AppNotification>[];

  // 1) Bütçe uyarıları (limitin %90+ kullanılan kategoriler).
  final budget = ref.watch(budgetOverviewProvider).value;
  if (budget != null) {
    for (final b in budget.items) {
      if (b.limit > 0 && b.usagePercent >= 90) {
        items.add(AppNotification(
          title: 'Bütçe Uyarısı',
          message:
              '${b.category.label} bütçenizin %${b.usagePercent}\'ını kullandınız.',
          icon: Icons.error_outline,
          color: b.usagePercent >= 100 ? AppColors.error : AppColors.warning,
          when: now,
          important: true,
        ));
      }
    }
  }

  // 2) Tekrarlayan ödemeler (yaklaşan / geciken).
  final recurring = ref.watch(recurringOverviewProvider).value;
  if (recurring != null) {
    for (final p in recurring.active) {
      if (p.daysLeft < 0) {
        items.add(AppNotification(
          title: 'Ödeme Gecikti',
          message:
              '${p.title} ödemesi ${p.daysLeft.abs()} gün gecikti (${Formatters.currency(p.amount)}).',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
          when: p.nextDate,
          important: true,
        ));
      } else if (p.daysLeft <= 7) {
        items.add(AppNotification(
          title: 'Fatura Hatırlatması',
          message: p.daysLeft == 0
              ? '${p.title} ödemesi bugün (${Formatters.currency(p.amount)}).'
              : '${p.title} ödemesine ${p.daysLeft} gün kaldı (${Formatters.currency(p.amount)}).',
          icon: Icons.access_time,
          color: AppColors.warning,
          when: now,
          important: p.daysLeft <= 2,
        ));
      }
    }
  }

  // 3) Hedefler (tamamlanan / yaklaşan).
  final goals = ref.watch(goalsOverviewProvider).value;
  if (goals != null) {
    for (final g in goals.completed) {
      items.add(AppNotification(
        title: 'Hedef Tamamlandı 🎉',
        message: '${g.title} hedefine ulaştın!',
        icon: Icons.emoji_events_outlined,
        color: AppColors.success,
        when: g.createdAt,
        important: true,
      ));
    }
    for (final g in goals.active) {
      if (g.percent >= 75) {
        items.add(AppNotification(
          title: 'Hedefe Yaklaştın',
          message: '${g.title} hedefinde %${g.percent}\'e ulaştın!',
          icon: Icons.trending_up,
          color: AppColors.primary,
          when: now,
        ));
      }
    }
  }

  // 4) Son işlemler (bilgilendirme).
  final txns = ref.watch(transactionsStreamProvider).value ?? [];
  for (final t in txns.take(5)) {
    final isIncome = t.type == TransactionType.income;
    items.add(AppNotification(
      title: isIncome ? 'Yeni Gelir Eklendi' : 'Yeni İşlem Eklendi',
      message:
          '${t.title} · ${t.category.label} (${Formatters.currency(t.amount)})',
      icon: isIncome
          ? Icons.arrow_circle_up_outlined
          : Icons.arrow_circle_down_outlined,
      color: isIncome ? AppColors.success : AppColors.primary,
      when: t.date,
    ));
  }

  // Önce önemli, sonra en yeni.
  items.sort((a, b) {
    if (a.important != b.important) return a.important ? -1 : 1;
    return b.when.compareTo(a.when);
  });
  return items;
});

/// Göreli zaman etiketi (ör. "5 dakika önce", "Dün", "3 gün önce").
String relativeTime(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) return 'Az önce';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
  if (diff.inHours < 24) return '${diff.inHours} saat önce';
  if (diff.inDays == 1) return 'Dün';
  if (diff.inDays < 7) return '${diff.inDays} gün önce';
  return Formatters.date(when);
}
