import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../graphql/queries.dart';
import '../models/temporary_residence.dart';
import '../models/temporary_absence.dart';

final temporaryResidencesProvider = FutureProvider.autoDispose
    .family<List<TemporaryResidence>, String>((ref, residentId) async {
  final client = GraphQLConfig.client.value;
  final result = await client.query(
    QueryOptions(
      document: gql(getTemporaryResidencesByResidentQuery),
      variables: {'residentId': residentId},
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    ),
  );
  if (result.hasException) throw result.exception!;
  final List data = result.data?['temporaryResidences']?['data'] ?? [];
  return data.map((j) => TemporaryResidence.fromJson(Map<String, dynamic>.from(j))).toList();
});

final temporaryAbsencesProvider = FutureProvider.autoDispose
    .family<List<TemporaryAbsence>, String>((ref, residentId) async {
  final client = GraphQLConfig.client.value;
  final result = await client.query(
    QueryOptions(
      document: gql(getTemporaryAbsencesByResidentQuery),
      variables: {'residentId': residentId},
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    ),
  );
  if (result.hasException) throw result.exception!;
  final List data = result.data?['temporaryAbsences']?['data'] ?? [];
  return data.map((j) => TemporaryAbsence.fromJson(Map<String, dynamic>.from(j))).toList();
});
