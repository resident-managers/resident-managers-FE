import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/household.dart';
import '../../providers/household_provider.dart';

class HouseholdListScreen extends ConsumerWidget {
  const HouseholdListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdsAsync = ref.watch(householdsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Danh sách hộ dân'),
      ),
      body: householdsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(householdsProvider),
        ),
        data: (households) {
          if (households.isEmpty) {
            return const Center(child: Text('Không có dữ liệu hộ dân'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: households.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _HouseholdCard(household: households[index]),
          );
        },
      ),
    );
  }
}

class _HouseholdCard extends StatelessWidget {
  final Household household;

  const _HouseholdCard({required this.household});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              household.householdCode?.isNotEmpty == true
                  ? 'Mã hộ: ${household.householdCode}'
                  : 'Mã hộ: -',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Địa chỉ: ${household.address.isEmpty ? '-' : household.address}',
            ),
            const SizedBox(height: 4),
            Text('Chủ hộ: ${household.head?.fullName ?? '-'}'),
            const SizedBox(height: 4),
            Text('Thành viên: ${household.members?.length ?? 0}'),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Không tải được danh sách hộ dân',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
