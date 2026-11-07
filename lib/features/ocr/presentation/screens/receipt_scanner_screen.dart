import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:uuid/uuid.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/presentation/widgets/app_bottom_nav.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/entities/transaction_category.dart';
import '../../data/receipt_ocr_service.dart';

/// Okunmuş bir makbuz (dummy veri).
class _Receipt {
  final String merchant;
  final String category;
  final double amount;
  final String date;
  final String logoText;
  final Color color;

  const _Receipt(this.merchant, this.category, this.amount, this.date,
      this.logoText, this.color);
}

const _receipts = <_Receipt>[
  _Receipt('A101 Market', 'Market Alışverişi', 197.75, '07 Mayıs 2025, 14:32',
      'A101', Color(0xFF0E9594)),
  _Receipt('Migros', 'Market Alışverişi', 542.30, '06 Mayıs 2025, 18:45', 'M',
      Color(0xFFF26A21)),
  _Receipt("McDonald's", 'Yeme & İçme', 285.00, '06 Mayıs 2025, 13:20', 'M',
      Color(0xFF111827)),
  _Receipt('Shell', 'Ulaşım', 750.00, '05 Mayıs 2025, 19:10', 'S',
      Color(0xFFF59E0B)),
];

/// Ekran 21 — Makbuz Okuyucu (OCR).
class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  bool _showTips = true;
  bool _busy = false;
  final _service = ReceiptOcrService();

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu bölüm yakında eklenecek.')),
      );

  Future<void> _scan(ImageSource source) async {
    if (_busy) return;
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Makbuz okuma yalnızca mobil cihazlarda çalışır.')));
      return;
    }
    setState(() => _busy = true);
    ReceiptScan? result;
    try {
      result = await _service.scan(source);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Okuma başarısız oldu: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (result == null || !mounted) return;
    _showResult(result);
  }

  void _showResult(ReceiptScan scan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ResultSheet(
        scan: scan,
        onConvert: () {
          Navigator.pop(context);
          final draft = AppTransaction(
            id: const Uuid().v4(),
            title: scan.merchant,
            amount: scan.amount ?? 0,
            type: TransactionType.expense,
            category: TransactionCategory.shopping,
            date: scan.date ?? DateTime.now(),
            note: 'Makbuzdan okundu',
          );
          context.push(AppRoutes.addTransaction, extra: TransactionDraft(draft));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
          children: [
            _Header(onBell: () => context.push(AppRoutes.notifications)),
            const SizedBox(height: AppSpacing.lg),
            _ScanCard(
                onCamera: () => _scan(ImageSource.camera),
                onGallery: () => _scan(ImageSource.gallery)),
            const SizedBox(height: AppSpacing.lg),
            const _FeatureCard(),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle('Son Okunan Makbuzlar', onAction: _soon),
            const SizedBox(height: AppSpacing.sm),
            _RecentReceiptsCard(onTap: (_) => _soon()),
            const SizedBox(height: AppSpacing.lg),
            const Text('Bu Ayın Özeti',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            const _SummaryCard(),
            if (_showTips) ...[
              const SizedBox(height: AppSpacing.lg),
              _TipsCard(onClose: () => setState(() => _showTips = false)),
            ],
          ],
            ),
            if (_busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t, {required VoidCallback onAction}) => Row(
        children: [
          Expanded(
            child: Text(t,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          GestureDetector(
            onTap: onAction,
            child: const Row(
              children: [
                Text('Tümünü Gör',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ],
      );
}

class _ResultSheet extends StatelessWidget {
  final ReceiptScan scan;
  final VoidCallback onConvert;

  const _ResultSheet({required this.scan, required this.onConvert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: AppSpacing.xs),
                  Text('Makbuz Okundu',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _row('Satıcı', scan.merchant),
            _row(
                'Tutar',
                scan.amount != null
                    ? Formatters.currency(scan.amount!)
                    : 'Bulunamadı'),
            _row('Tarih',
                scan.date != null ? Formatters.date(scan.date!) : 'Bulunamadı'),
            const SizedBox(height: AppSpacing.md),
            if (scan.rawText.trim().isNotEmpty) ...[
              const Text('Okunan Metin',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(scan.rawText,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onConvert,
                icon: const Icon(Icons.add),
                label: const Text('İşleme Dönüştür'),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ],
        ),
      );
}

class _Header extends StatelessWidget {
  final VoidCallback onBell;

  const _Header({required this.onBell});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppBackButton(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Makbuz Okuyucu (OCR)',
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Makbuzlarınızı tarayın ve harcamalarınızı otomatik kaydedin',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        InkWell(
          onTap: onBell,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 28),
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanCard extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ScanCard({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Makbuzunuzu Tarayın',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text('Makbuzunuzu kameraya okutun veya galerinizden seçin',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3)),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onCamera,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Kamera ile Tara'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onGallery,
                    icon: const Icon(Icons.image_outlined,
                        size: 18, color: AppColors.primary),
                    label: const Text('Galeriden Seç',
                        style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const _PhoneMockup(),
        ],
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 180,
      child: Stack(
        children: [
          // Telefon gövdesi.
          Center(
            child: Container(
              width: 92,
              height: 176,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text('A101',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                    const SizedBox(height: 6),
                    for (var i = 0; i < 5; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                                width: 28, height: 3, color: AppColors.border),
                            const Spacer(),
                            Container(
                                width: 14, height: 3, color: AppColors.border),
                          ],
                        ),
                      ),
                    const Divider(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('TOPLAM',
                            style: TextStyle(
                                fontSize: 8, fontWeight: FontWeight.w700)),
                        Text('197,75',
                            style: TextStyle(
                                fontSize: 8, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(height: 10, color: const Color(0xFF1F2937)),
                  ],
                ),
              ),
            ),
          ),
          // Köşe tarama parantezleri.
          _bracket(Alignment.topLeft, true, true),
          _bracket(Alignment.topRight, true, false),
          _bracket(Alignment.bottomLeft, false, true),
          _bracket(Alignment.bottomRight, false, false),
        ],
      ),
    );
  }

  Widget _bracket(Alignment a, bool top, bool left) {
    return Align(
      alignment: a,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: AppColors.primary, width: 2.5)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: AppColors.primary, width: 2.5)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: AppColors.primary, width: 2.5)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: AppColors.primary, width: 2.5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard();

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.document_scanner_outlined, AppColors.primary,
          'OCR ile Otomatik Okuma'),
      (Icons.check_circle_outline, AppColors.success,
          'Otomatik Kategori Atama'),
      (Icons.receipt_long_outlined, AppColors.accent, 'Harcama Kaydı Oluştur'),
      (Icons.show_chart, AppColors.warning, 'Raporlarda Görüntüle'),
    ];
    return AppCard(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      child: Row(
        children: [
          for (final f in features)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: f.$2.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(f.$1, color: f.$2, size: 22),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(f.$3,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w500, height: 1.2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentReceiptsCard extends StatelessWidget {
  final ValueChanged<_Receipt> onTap;

  const _RecentReceiptsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < _receipts.length; i++) ...[
            _row(_receipts[i]),
            if (i != _receipts.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _row(_Receipt r) {
    return InkWell(
      onTap: () => onTap(r),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: r.color,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(r.logoText,
                  style: TextStyle(
                      color: r.color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      fontSize: r.logoText.length > 1 ? 10 : 16,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.merchant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(r.category,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.currency(r.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(r.date,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text('Kaydedildi',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _col(Icons.document_scanner_outlined, AppColors.primary,
                'Toplam Makbuz', '12', 'Adet'),
            _divider(),
            _col(Icons.check_circle_outline, AppColors.success, 'Toplam Tutar',
                Formatters.currency(3245.80), ''),
            _divider(),
            _col(Icons.local_mall_outlined, AppColors.warning, 'Ortalama Tutar',
                Formatters.currency(270.48), ''),
            _divider(),
            _col(Icons.category_outlined, AppColors.accent, 'Kategoriler', '6',
                'Farklı'),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const VerticalDivider(width: AppSpacing.md);

  Widget _col(IconData icon, Color color, String title, String value,
      String sub) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800)),
          ),
          if (sub.isNotEmpty)
            Text(sub,
                style: TextStyle(
                    fontSize: 9, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final VoidCallback onClose;

  const _TipsCard({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.document_scanner_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daha İyi Sonuçlar İçin İpuçları',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                SizedBox(height: AppSpacing.xs),
                _Tip('Makbuzu düz bir zemine yerleştirin'),
                _Tip('Işık yeterli olsun ve gölgeleri azaltın'),
                _Tip('Makbuzun tamamı çerçeve içinde olsun'),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close,
                size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;

  const _Tip(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12, height: 1.3)),
          ),
        ],
      ),
    );
  }
}
