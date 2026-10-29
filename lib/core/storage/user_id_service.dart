import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Keys used in secure/local storage.
abstract class StorageKeys {
  static const userId = 'saabi_user_id';
  static const onboardingComplete = 'saabi_onboarding_complete';
}

/// Manages the stable, anonymous device user_id used to personalise
/// Saabi AI responses across sessions.
///
/// On mobile: stored in OS-level encrypted storage (Keychain/Keystore).
/// On web:    stored in SharedPreferences (requires HTTPS in production).
class UserIdService {
  UserIdService._();
  static final UserIdService instance = UserIdService._();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Returns the stored user_id, generating and persisting a new UUID if
  /// this is the first launch.
  Future<String> getUserId() async {
    final existing = await _read(StorageKeys.userId);
    if (existing != null && existing.isNotEmpty) return existing;

    final newId = const Uuid().v4();
    await _write(StorageKeys.userId, newId);
    return newId;
  }

  /// Returns true if the user has completed onboarding.
  Future<bool> isOnboardingComplete() async {
    final val = await _read(StorageKeys.onboardingComplete);
    return val == 'true';
  }

  /// Mark onboarding as done.
  Future<void> completeOnboarding() async {
    await _write(StorageKeys.onboardingComplete, 'true');
  }

  /// Clears all stored data (e.g. on a fresh start / reset).
  Future<void> clearAll() async {
    if (_useSecureStorage) {
      await _secureStorage.deleteAll();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  bool get _useSecureStorage {
    // flutter_secure_storage works on iOS, Android, macOS, Linux, Windows.
    // On web it requires HTTPS — fall back to SharedPreferences for safety.
    return !kIsWeb;
  }

  Future<String?> _read(String key) async {
    if (_useSecureStorage) {
      return _secureStorage.read(key: key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  Future<void> _write(String key, String value) async {
    if (_useSecureStorage) {
      await _secureStorage.write(key: key, value: value);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }
}
