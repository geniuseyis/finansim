package com.seyis.financeapp

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth biyometrik istemcisinin (BiometricPrompt) çalışması için
// FlutterActivity yerine FlutterFragmentActivity kullanılır.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Son uygulamalar ekranında bakiyeler görünmesin. Kullanıcının kendi
        // ekran görüntüsü almasını engellemez (FLAG_SECURE'dan farkı bu).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            setRecentsScreenshotEnabled(false)
        }
    }
}
