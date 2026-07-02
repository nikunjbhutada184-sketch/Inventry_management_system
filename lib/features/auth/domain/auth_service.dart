import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(const FlutterSecureStorage());
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

enum AuthState {
  initial,
  needsPinCreation,
  needsPinEntry,
  authenticated,
}

class AuthService {
  final FlutterSecureStorage _secureStorage;
  static const String _pinKey = 'user_pin_code';

  AuthService(this._secureStorage);

  Future<bool> hasPin() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> savePin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    return storedPin == pin;
  }

  Future<void> clearPin() async {
    await _secureStorage.delete(key: _pinKey);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial) {
    checkInitialState();
  }

  Future<void> checkInitialState() async {
    final hasPin = await _authService.hasPin();
    if (hasPin) {
      state = AuthState.needsPinEntry;
    } else {
      state = AuthState.needsPinCreation;
    }
  }

  Future<void> createPin(String pin) async {
    await _authService.savePin(pin);
    state = AuthState.authenticated;
  }

  Future<bool> authenticate(String pin) async {
    final isValid = await _authService.verifyPin(pin);
    if (isValid) {
      state = AuthState.authenticated;
      return true;
    }
    return false;
  }

  Future<void> resetPin() async {
    await _authService.clearPin();
    state = AuthState.needsPinCreation;
  }
}
