import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../graphql/admin_queries.dart';
import '../graphql/admin_mutations.dart';
import '../models/user_model.dart';

part 'user_provider.g.dart';

class UserManagementState {
  final bool isLoading;
  final List<UserModel> users;
  final String? error;

  UserManagementState({
    this.isLoading = false,
    this.users = const [],
    this.error,
  });
}

@riverpod
class UserManagement extends _$UserManagement {
  @override
  UserManagementState build() {
    fetchUsers();
    return UserManagementState(isLoading: true);
  }

  Future<void> fetchUsers() async {
    state = UserManagementState(isLoading: true);
    final client = GraphQLConfig.client.value;

    final result = await client.query(
      QueryOptions(
        document: gql(usersQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      state = UserManagementState(error: result.exception.toString());
      return;
    }

    final data = result.data?['users']?['data'] as List<dynamic>? ?? [];
    final users = data
        .cast<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
    state = UserManagementState(users: users);
  }

  Future<String?> createUser({
    required String name,
    required String email,
    String? role,
  }) async {
    final client = GraphQLConfig.client.value;

    final input = <String, dynamic>{
      'name': name,
      'email': email,
      'role': ?role,
    };

    final result = await client.mutate(
      MutationOptions(
        document: gql(createUserMutation),
        variables: {'input': input},
      ),
    );

    if (result.hasException) {
      final gqlErrors = result.exception?.graphqlErrors;
      return (gqlErrors != null && gqlErrors.isNotEmpty)
          ? gqlErrors.first.message
          : result.exception.toString();
    }

    final json = result.data?['userCreate'] as Map<String, dynamic>?;
    if (json != null) {
      final newUser = UserModel.fromJson(json);
      state = UserManagementState(
        users: [newUser, ...state.users],
      );
    }
    return null;
  }

  Future<String?> updateUser({
    required String id,
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
    String? role,
  }) async {
    final client = GraphQLConfig.client.value;

    final input = <String, dynamic>{
      'id': id,
      'name': ?name,
      'email': ?email,
      'password': ?password,
      'password_confirmation': ?passwordConfirmation,
      'role': ?role,
    };

    final result = await client.mutate(
      MutationOptions(
        document: gql(updateUserMutation),
        variables: {'input': input},
      ),
    );

    if (result.hasException) {
      final gqlErrors = result.exception?.graphqlErrors;
      return (gqlErrors != null && gqlErrors.isNotEmpty)
          ? gqlErrors.first.message
          : result.exception.toString();
    }

    final json = result.data?['userUpdate'] as Map<String, dynamic>?;
    if (json != null) {
      final updated = UserModel.fromJson(json);
      state = UserManagementState(
        users: state.users
            .map((u) => u.id == id ? updated : u)
            .toList(),
      );
    }
    return null;
  }

  Future<String?> deleteUser(String id) async {
    final client = GraphQLConfig.client.value;

    final result = await client.mutate(
      MutationOptions(
        document: gql(deleteUserMutation),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      final gqlErrors = result.exception?.graphqlErrors;
      return (gqlErrors != null && gqlErrors.isNotEmpty)
          ? gqlErrors.first.message
          : result.exception.toString();
    }

    state = UserManagementState(
      users: state.users.where((u) => u.id != id).toList(),
    );
    return null;
  }
}
