import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage for JWT tokens
/// On web, uses SharedPreferences (localStorage) for persistence
/// On mobile, uses FlutterSecureStorage for encryption
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _organizationIdKey = 'organization_id';
  static const _entityIdKey = 'entity_id';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Write to storage - uses SharedPreferences on web, SecureStorage on mobile
  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      } catch (e) {
        print('TokenStorage: Error writing $key to SharedPreferences: $e');
      }
    } else {
      try {
        await _secureStorage.write(key: key, value: value);
      } catch (e) {
        print('TokenStorage: Error writing $key to SecureStorage: $e');
      }
    }
  }

  /// Read from storage - uses SharedPreferences on web, SecureStorage on mobile
  Future<String?> _read(String key) async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      } catch (e) {
        print('TokenStorage: Error reading $key from SharedPreferences: $e');
        return null;
      }
    } else {
      try {
        return await _secureStorage.read(key: key);
      } catch (e) {
        print('TokenStorage: Error reading $key from SecureStorage: $e');
        return null;
      }
    }
  }

  /// Delete from storage
  Future<void> _delete(String key) async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } catch (e) {
        print('TokenStorage: Error deleting $key from SharedPreferences: $e');
      }
    } else {
      try {
        await _secureStorage.delete(key: key);
      } catch (e) {
        print('TokenStorage: Error deleting $key from SecureStorage: $e');
      }
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _write(_accessTokenKey, accessToken),
      _write(_refreshTokenKey, refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    return _read(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _read(_refreshTokenKey);
  }

  Future<void> saveTenantContext({
    required String organizationId,
    required String entityId,
  }) async {
    await Future.wait([
      _write(_organizationIdKey, organizationId),
      _write(_entityIdKey, entityId),
    ]);
  }

  Future<String?> getOrganizationId() async {
    return _read(_organizationIdKey);
  }

  Future<String?> getEntityId() async {
    return _read(_entityIdKey);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _delete(_accessTokenKey),
      _delete(_refreshTokenKey),
    ]);
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_accessTokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_organizationIdKey);
        await prefs.remove(_entityIdKey);
      } catch (e) {
        print('TokenStorage: Error clearing all from SharedPreferences: $e');
      }
    } else {
      try {
        await _secureStorage.deleteAll();
      } catch (e) {
        print('TokenStorage: Error clearing all from SecureStorage: $e');
      }
    }
  }

  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
