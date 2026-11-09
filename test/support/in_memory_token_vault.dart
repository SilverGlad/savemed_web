import 'package:savemed/core/storage/token_storage.dart';

class InMemoryTokenVault implements TokenVault {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> delete() async => _token = null;
}
