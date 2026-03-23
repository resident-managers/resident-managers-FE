import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/app_flavor.dart';
import '../core/graphql_client.dart';
import '../core/secure_storage.dart';
import '../graphql/mutations.dart';
import '../graphql/admin_mutations.dart';

part 'auth_provider.g.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? error;
  final String? successMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.error,
    this.successMessage,
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

    final isAdmin = AppConfig.isAdmin;
    final result = await client.mutate(
      MutationOptions(
        document: gql(isAdmin ? adminLoginMutation : loginMutation),
        variables: {'email': email, 'password': password},
      ),
    );

    if (result.hasException) {
      final gqlErrors = result.exception?.graphqlErrors;
      final message = (gqlErrors != null && gqlErrors.isNotEmpty)
          ? gqlErrors.first.message
          : (result.exception?.linkException?.toString() ?? 'Đã xảy ra lỗi.');
      state = AuthState(error: message);
      return;
    }

    final responseKey = isAdmin ? 'adminLogin' : 'login';
    final token =
        (result.data?[responseKey]?['access_token'] as String?) ??
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

  Future<void> forgotPassword(String email) async {
    state = AuthState(isLoading: true);
    final client = GraphQLConfig.client.value;

    final result = await client.mutate(
      MutationOptions(
        document: gql(forgotPasswordMutation),
        variables: {'email': email},
      ),
    );

    if (result.hasException) {
      state = AuthState(error: result.exception.toString());
      return;
    }

    final message =
        result.data?['forgotPassword']?['message'] as String? ??
        'Yêu cầu đã được gửi. Vui lòng kiểm tra email của bạn.';
    state = AuthState(successMessage: message);
  }

  Future<void> resetPassword(
    String token,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    state = AuthState(isLoading: true);
    final client = GraphQLConfig.client.value;

    final result = await client.mutate(
      MutationOptions(
        document: gql(resetPasswordMutation),
        variables: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      ),
    );

    if (result.hasException) {
      state = AuthState(error: result.exception.toString());
      return;
    }

    final message =
        result.data?['resetPassword']?['message'] as String? ??
        'Mật khẩu đã được đặt lại thành công.';
    state = AuthState(successMessage: message);
  }

  Future<void> logout() async {
    final client = GraphQLConfig.client.value;

    try {
      await client
          .mutate(
            MutationOptions(
              document: gql(logoutMutation),
              fetchPolicy: FetchPolicy.noCache,
            ),
          )
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      // Always continue local logout even if backend logout fails.
    }

    try {
      await _storage.deleteToken();
    } catch (_) {}
    state = AuthState(isAuthenticated: false);
    GraphQLConfig.updateClient();
  }
}
