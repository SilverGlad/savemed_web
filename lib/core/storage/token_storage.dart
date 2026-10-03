import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class TokenVault {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();
}

class _PlatformTokenVault implements TokenVault {
  static const _storage = FlutterSecureStorage();
  static const _key = 'auth_token';

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

class TokenStorage {
  static const _key = 'auth_token';
  static int _generation = 0;
  static int? _pendingClearGeneration;
  static Future<void> _operationQueue = Future<void>.value();
  static TokenVault? _vaultOverride;
  static final TokenVault _platformVault = _PlatformTokenVault();

  @visibleForTesting
  static void setVaultForTesting(TokenVault vault) {
    _vaultOverride = vault;
  }

  @visibleForTesting
  static void resetForTesting() {
    _generation++;
    _pendingClearGeneration = null;
    _operationQueue = Future<void>.value();
  }

  static TokenVault get _vault => _vaultOverride ?? _platformVault;

  static bool get _usesSecureVault => !kIsWeb || _vaultOverride != null;

  static Future<void> saveToken(String token) {
    final generation = ++_generation;
    _pendingClearGeneration = null;
    return _enqueue(() async {
      if (generation != _generation) return;

      if (_usesSecureVault) {
        await _vault.write(token);
        await _removeLegacyToken();
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, token);
      }
    });
  }

  static Future<String?> getToken() async {
    while (true) {
      if (_pendingClearGeneration == _generation) return null;
      final generation = _generation;
      final token = await _readToken(generation);
      if (generation == _generation) return token;
      if (_pendingClearGeneration == _generation) return null;
    }
  }

  static Future<String?> _readToken(int generation) async {
    final prefs = await SharedPreferences.getInstance();
    if (generation != _generation) return null;
    if (!_usesSecureVault) return prefs.getString(_key);

    final secureToken = await _vault.read();
    if (generation != _generation) return null;
    final legacyToken = prefs.getString(_key);
    if (secureToken != null) {
      if (legacyToken != null) await _removeLegacyToken();
      return secureToken;
    }
    if (legacyToken == null) return null;

    if (generation != _generation) return null;
    await _vault.write(legacyToken);
    if (generation != _generation) {
      await _operationQueue;
      return null;
    }
    await _removeLegacyToken();
    return legacyToken;
  }

  static Future<void> clear() {
    final generation = ++_generation;
    _pendingClearGeneration = generation;
    return _enqueue(() async {
      if (generation != _generation) return;
      if (_usesSecureVault) await _vault.delete();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      if (generation == _generation) _pendingClearGeneration = null;
    });
  }

  static Future<void> _removeLegacyToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<T> _enqueue<T>(Future<T> Function() operation) {
    if (_vaultOverride != null) return operation();

    final result = Completer<T>();
    _operationQueue = _operationQueue.catchError((Object _) {}).then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }
}
