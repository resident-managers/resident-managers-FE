import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../graphql/queries.dart';
import '../models/statistics.dart';

final statisticsProvider = FutureProvider.autoDispose<ResidentStatistics>((ref) async {
  final client = GraphQLConfig.client.value;

  final result = await client.query(
    QueryOptions(
      document: gql(getStatisticsQuery),
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    ),
  );

  if (result.hasException) {
    throw result.exception!;
  }

  final data = result.data?['statistics'];
  if (data == null) return ResidentStatistics();
  return ResidentStatistics.fromJson(Map<String, dynamic>.from(data));
});
