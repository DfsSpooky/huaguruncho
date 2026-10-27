import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dioClient: dioClient, storage: storage);
});

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(AuthState()) {
    checkSavedSession();
  }

  Future<void> checkSavedSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.getSavedUser();
      state = state.copyWith(isLoading: false, user: user);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName, String? phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(clearUser: true);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
