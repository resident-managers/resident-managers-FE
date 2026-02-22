import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'secure_storage.dart';

class GraphQLConfig {
  static const String _baseUrlFromDefine = String.fromEnvironment(
    'GRAPHQL_ENDPOINT',
  );

  static String get _baseUrl {
    final fromDefine = _baseUrlFromDefine.trim();
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    String fromEnv = '';
    try {
      fromEnv = (dotenv.env['GRAPHQL_ENDPOINT'] ?? '').trim();
    } catch (_) {
      fromEnv = '';
    }
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    throw StateError(
      'GRAPHQL_ENDPOINT is missing. Set it via --dart-define or .env file.',
    );
  }

  static HttpLink httpLink = HttpLink(_baseUrl);

  static AuthLink authLink = AuthLink(
    getToken: () async {
      final token = await SecureStorage().getToken();
      return token == null ? null : 'Bearer $token';
    },
  );

  static Link link = authLink.concat(httpLink);

  static ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(link: link, cache: _buildCache()),
  );

  static void updateClient() {
    client.value = GraphQLClient(link: link, cache: _buildCache());
  }

  static GraphQLCache _buildCache() {
    try {
      return GraphQLCache(store: HiveStore());
    } catch (_) {
      return GraphQLCache(store: InMemoryStore());
    }
  }
}
