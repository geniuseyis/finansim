import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';

/// --- Bağımlılık Enjeksiyonu (Dependency Injection) zinciri ---
///
/// Riverpod provider'ları, Clean Architecture katmanlarını birbirine bağlar:
/// FirebaseAuth → DataSource → Repository → UseCase → UI
/// Her provider bir öncekini `ref.watch` ile okur. Bu, manuel `new` çağrıları
/// yerine merkezi ve test edilebilir bir DI sağlar.

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(firebaseAuthProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

// --- Use case provider'ları ---

final signInWithEmailProvider = Provider(
  (ref) => SignInWithEmail(ref.watch(authRepositoryProvider)),
);

final signUpWithEmailProvider = Provider(
  (ref) => SignUpWithEmail(ref.watch(authRepositoryProvider)),
);

final signInWithGoogleProvider = Provider(
  (ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)),
);

final signOutProvider = Provider(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);

final sendPasswordResetEmailProvider = Provider(
  (ref) => SendPasswordResetEmail(ref.watch(authRepositoryProvider)),
);

/// Oturum durumunu dinleyen provider.
///
/// Router bu provider'ı izleyerek kullanıcı giriş/çıkış yaptığında otomatik
/// yönlendirme yapar. UI de "giriş yapılı mı?" bilgisini buradan okur.
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
