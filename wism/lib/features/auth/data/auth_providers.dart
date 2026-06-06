import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_repository.dart';
import 'auth_repository_impl.dart';
import 'mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.read(tokenStorageProvider);
  if (Env.useMockAuth) {
    return MockAuthRepository(storage);
  }
  return AuthRepositoryImpl(ref.read(dioProvider), storage);
});
