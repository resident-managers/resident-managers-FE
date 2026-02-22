import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../graphql/queries.dart';
import '../models/household.dart';

final householdsProvider = FutureProvider.autoDispose<List<Household>>((
  ref,
) async {
  final client = GraphQLConfig.client.value;

  final result = await client.query(
    QueryOptions(
      document: gql(getHouseholdsQuery),
      variables: {'first': 50, 'page': 1},
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    ),
  );

  if (result.hasException) {
    throw result.exception!;
  }

  final List<dynamic> data = result.data?['houseHolds']?['data'] ?? [];
  return data
      .map((item) => Household.fromJson(Map<String, dynamic>.from(item)))
      .toList();
});
