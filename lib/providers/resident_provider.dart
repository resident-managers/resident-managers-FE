import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../graphql/queries.dart';
import '../models/resident.dart';

class ResidentsQueryParams {
  final String? search;
  final String? gender;
  final String sortOrder; // ASC | DESC

  const ResidentsQueryParams({
    this.search,
    this.gender,
    this.sortOrder = 'ASC',
  });

  @override
  bool operator ==(Object other) {
    return other is ResidentsQueryParams &&
        other.search == search &&
        other.gender == gender &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(search, gender, sortOrder);
}

final residentsProvider = FutureProvider.autoDispose
    .family<List<Resident>, ResidentsQueryParams>((ref, params) async {
      final client = GraphQLConfig.client.value;
      final search = (params.search ?? '').trim();
      final gender = (params.gender ?? '').trim().toLowerCase();
      final sortOrder =
          params.sortOrder.toUpperCase() == 'DESC' ? 'DESC' : 'ASC';

      final where = switch (gender) {
        'male' || 'female' => {
            'column': 'GENDER',
            'operator': 'EQ',
            'value': gender,
          },
        _ => null,
      };

      final result = await client.query(
        QueryOptions(
          document: gql(getResidentsQuery),
          variables: {
            'search': search.isEmpty ? null : search,
            'where': where,
            'orderBy': [
              {'column': 'FULL_NAME', 'order': sortOrder},
            ],
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

      final List<dynamic> data = result.data?['residents']?['data'] ?? [];
      return data.map((json) => Resident.fromJson(json)).toList();
    });

final residentDetailProvider = FutureProvider.autoDispose
    .family<Resident, String>((ref, id) async {
      final client = GraphQLConfig.client.value;

      final result = await client.query(
        QueryOptions(
          document: gql(getResidentDetailQuery),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
          cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final residentData = result.data?['resident'];
      if (residentData == null) {
        throw Exception('Resident not found');
      }

      return Resident.fromJson(Map<String, dynamic>.from(residentData));
    });
