import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_boxes.dart';

/// Kullanıcının finans verilerini cihazda şifreli ve hesaba özel saklar.
///
/// - Her kutu AES-256 ile şifrelenir; anahtar Keychain / Android Keystore
///   destekli güvenli depoda durur, Hive dosyasının yanında değil.
/// - Kutular oturum açan kullanıcıya göre adlandırılır. Aynı cihazda başka
///   bir hesapla giriş yapılırsa önceki kişinin işlemleri görünmez.
/// - Ayarlar (tema, para birimi, uygulama kilidi) hassas olmadığı için
///   cihaz genelinde tek, şifresiz bir kutuda kalır.
/// - Web'de güvenli anahtar deposu olmadığından (anahtar aynı tarayıcı
///   deposunda dururdu) şifreleme yalnızca mobil/masaüstünde uygulanır.
class SecureLocalStore {
  SecureLocalStore._();

  static const _keyName = 'hive_aes_key_v1';
  static const _storage = FlutterSecureStorage();

  /// Kullanıcıya bağlı kutuların temel adları.
  static const userBoxes = [
    HiveBoxes.transactions,
    HiveBoxes.budgets,
    HiveBoxes.recurring,
    HiveBoxes.goals,
  ];

  static String? _suffix;

  /// Hive'ı başlatır ve ayarlar kutusunu açar. `runApp`'ten önce çağrılır.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(HiveBoxes.settings);
  }

  /// [uid] için şifreli kutuları açar; başka bir kullanıcının kutuları
  /// açıksa önce onları kapatır.
  static Future<void> openForUser(String uid) async {
    final suffix = sha256.convert(utf8.encode(uid)).toString().substring(0, 16);
    if (suffix == _suffix) return;

    await _closeUserBoxes();
    final cipher = kIsWeb ? null : HiveAesCipher(await _readOrCreateKey());
    for (final base in userBoxes) {
      final box = await Hive.openBox(
        '${base}_$suffix',
        encryptionCipher: cipher,
      );
      await _migrateLegacy(base, box);
    }
    _suffix = suffix;
  }

  /// Oturumdaki kullanıcının kutusunu döndürür.
  static Box box(String base) {
    final suffix = _suffix;
    if (suffix == null) {
      throw StateError('Kullanıcı kutuları henüz açılmadı ($base).');
    }
    return Hive.box('${base}_$suffix');
  }

  static Future<void> _closeUserBoxes() async {
    final suffix = _suffix;
    if (suffix == null) return;
    for (final base in userBoxes) {
      final name = '${base}_$suffix';
      if (Hive.isBoxOpen(name)) await Hive.box(name).close();
    }
    _suffix = null;
  }

  static Future<List<int>> _readOrCreateKey() async {
    final stored = await _storage.read(key: _keyName);
    if (stored != null) return base64Decode(stored);
    final key = Hive.generateSecureKey();
    await _storage.write(key: _keyName, value: base64Encode(key));
    return key;
  }

  /// Eski sürümler verileri şifresiz ve hesaptan bağımsız kutularda tutuyordu.
  /// Bu veriyi ilk giriş yapan hesaba taşıyıp şifresiz dosyayı sileriz.
  static Future<void> _migrateLegacy(String base, Box target) async {
    if (!await Hive.boxExists(base)) return;
    final legacy = await Hive.openBox(base);
    if (target.isEmpty && legacy.isNotEmpty) {
      await target.putAll(Map.of(legacy.toMap()));
    }
    await legacy.deleteFromDisk();
  }
}
