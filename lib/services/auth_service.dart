import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'local_store.dart';

class LocalUser {
  const LocalUser({required this.name, required this.email});
  final String name;
  final String email;
}

class AuthService {
  final _store = LocalStore();
  static const _nameKey = 'account_name_v1';
  static const _emailKey = 'account_email_v1';
  static const _saltKey = 'account_salt_v1';
  static const _hashKey = 'account_password_hash_v1';
  static const _sessionKey = 'account_session_v1';

  String _hash(String password, String salt) => sha256.convert(utf8.encode('$salt:$password')).toString();

  Future<bool> get hasAccount async => _store.containsKey(_hashKey);
  Future<bool> get isLoggedIn async => await _store.getBool(_sessionKey) ?? false;

  Future<LocalUser?> get currentUser async {
    final name = await _store.getString(_nameKey);
    final email = await _store.getString(_emailKey);
    return name == null || email == null ? null : LocalUser(name: name, email: email);
  }

  Future<void> register({required String name, required String email, required String password}) async {
    final salt = base64UrlEncode(utf8.encode('${const Uuid().v4()}:${DateTime.now().microsecondsSinceEpoch}'));
    await _store.setString(_nameKey, name.trim());
    await _store.setString(_emailKey, email.trim().toLowerCase());
    await _store.setString(_saltKey, salt);
    await _store.setString(_hashKey, _hash(password, salt));
    await _store.setBool(_sessionKey, true);
  }

  Future<bool> login({required String email, required String password}) async {
    final savedEmail = await _store.getString(_emailKey);
    final salt = await _store.getString(_saltKey);
    final savedHash = await _store.getString(_hashKey);
    final valid = savedEmail == email.trim().toLowerCase() && salt != null && savedHash == _hash(password, salt);
    if (valid) await _store.setBool(_sessionKey, true);
    return valid;
  }

  Future<void> logout() async => _store.setBool(_sessionKey, false);
}
