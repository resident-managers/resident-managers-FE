import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../graphql/queries.dart';
import '../models/resident.dart';

final residentsProvider = FutureProvider.autoDispose
    .family<List<Resident>, String?>((ref, keyword) async {
      final client = GraphQLConfig.client.value;

      final result = await client.query(
        QueryOptions(
          document: gql(getResidentsQuery),
          variables: {
            'fullName': keyword,
            'nationalId': keyword,
            'phone': keyword,
            'first': 20,
            'page': 1,
          },
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
