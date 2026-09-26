import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bellabox/features/auth/domain/entities/user.dart';

/// Global auth session state.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthGuest extends AuthState {
  const AuthGuest();
}

class AuthSessionNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  /// Called from Splash. Restores session from secure storage + validates.
  Future<void> restore() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.restoreSession();
    result.fold(
      (_) => state = const AuthGuest(),
      (user) => state = user != null ? AuthAuthenticated(user) : const AuthGuest(),
    );
  }

  void setAuthenticated(User user) {
    state = AuthAuthenticated(user);
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthGuest();
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthState>(AuthSessionNotifier.new);

final currentUserProvider = Provider<User?>((ref) {
  final state = ref.watch(authSessionProvider);
  return state is AuthAuthenticated ? state.user : null;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authSessionProvider) is AuthAuthenticated;
});
