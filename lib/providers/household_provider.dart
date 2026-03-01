import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../graphql/queries.dart';
import '../models/household.dart';

class HouseholdsQueryParams {
  final String? search;

  const HouseholdsQueryParams({this.search});

  @override
  bool operator ==(Object other) {
    return other is HouseholdsQueryParams && other.search == search;
  }

  @override
  int get hashCode => Object.hashAll([search]);
}

final householdsProvider = FutureProvider.autoDispose
    .family<List<Household>, HouseholdsQueryParams>((ref, params) async {
      final client = GraphQLConfig.client.value;
      final search = (params.search ?? '').trim();

      final result = await client.query(
        QueryOptions(
          document: gql(getHouseholdsQuery),
          variables: {
            'search': search.isEmpty ? null : search,
            'first': 20,
            'page': 1,
          },
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
