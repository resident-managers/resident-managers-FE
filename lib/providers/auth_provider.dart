import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../core/secure_storage.dart';
import '../graphql/mutations.dart';

part 'auth_provider.g.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.error,
  });
}

@riverpod
class Auth extends _$Auth {
  final _storage = SecureStorage();

  @override
  AuthState build() {
    _checkToken();
    return AuthState();
  }

  Future<void> _checkToken() async {
    final token = await _storage.getToken();
    if (token != null) {
      state = AuthState(isAuthenticated: true, token: token);
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    final client = GraphQLConfig.client.value;

    final result = await client.mutate(
      MutationOptions(
        document: gql(loginMutation),
        variables: {'email': email, 'password': password},
      ),
    );

    if (result.hasException) {
      state = AuthState(error: result.exception.toString());
      return;
    }

    final token =
        (result.data?['login']?['access_token'] as String?) ??
        (result.data?['dangNhap']?['token'] as String?);
    if (token != null && token.isNotEmpty) {
      try {
        await _storage.saveToken(token);
        GraphQLConfig.updateClient();
        state = AuthState(isAuthenticated: true, token: token);
        return;
      } catch (e) {
        state = AuthState(error: 'Cannot save access token: $e');
        return;
      }
    }

    state = AuthState(error: 'Login failed: missing access token.');
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    GraphQLConfig.updateClient();
    state = AuthState(isAuthenticated: false);
  }
}
