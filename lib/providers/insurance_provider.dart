import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/graphql_client.dart';
import '../graphql/queries.dart';
import '../models/health_insurance.dart';
import '../models/social_insurance.dart';

final healthInsurancesProvider = FutureProvider.autoDispose
    .family<List<HealthInsurance>, String>((ref, residentId) async {
  final client = GraphQLConfig.client.value;
  final result = await client.query(
    QueryOptions(
      document: gql(getHealthInsurancesByResidentQuery),
      variables: {'residentId': residentId},
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    ),
  );
  if (result.hasException) throw result.exception!;
  final List data = result.data?['healthInsurances']?['data'] ?? [];
  return data.map((j) => HealthInsurance.fromJson(Map<String, dynamic>.from(j))).toList();
});

final socialInsurancesProvider = FutureProvider.autoDispose
    .family<List<SocialInsurance>, String>((ref, residentId) async {
  final client = GraphQLConfig.client.value;
  final result = await client.query(
    QueryOptions(
      document: gql(getSocialInsurancesByResidentQuery),
      variables: {'residentId': residentId},
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    ),
  );
  if (result.hasException) throw result.exception!;
  final List data = result.data?['socialInsurances']?['data'] ?? [];
  return data.map((j) => SocialInsurance.fromJson(Map<String, dynamic>.from(j))).toList();
});
