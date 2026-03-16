import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/household.dart';
import '../../providers/household_provider.dart';

class HouseholdListScreen extends ConsumerStatefulWidget {
  const HouseholdListScreen({super.key});

  @override
  ConsumerState<HouseholdListScreen> createState() =>
      _HouseholdListScreenState();
}

class _HouseholdListScreenState extends ConsumerState<HouseholdListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';
  String _sortOrder = 'ASC';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = HouseholdsQueryParams(
      search: _keyword.isEmpty ? null : _keyword,
    );
    final householdsAsync = ref.watch(householdsProvider(params));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: householdsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _ErrorState(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(householdsProvider(params)),
                ),
                data: (households) {
                  if (households.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu hộ dân'));
                  }
                  final sorted = [...households];
                  sorted.sort((a, b) {
                    final codeA = (a.householdCode ?? '').toLowerCase();
                    final codeB = (b.householdCode ?? '').toLowerCase();
                    return _sortOrder == 'ASC'
                        ? codeA.compareTo(codeB)
                        : codeB.compareTo(codeA);
                  });

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _HouseholdCard(household: sorted[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/setup-household');
          if (!context.mounted) {
            return;
          }
          ref.invalidate(householdsProvider(params));
        },
        backgroundColor: const Color(0xFF137FEC),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Hộ dân',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _keyword = value),
            decoration: InputDecoration(
              hintText: 'Tìm theo mã hộ, địa chỉ, chủ hộ...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _sortOrder = _sortOrder == 'ASC' ? 'DESC' : 'ASC';
                  });
                },
                icon: Icon(
                  _sortOrder == 'ASC'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: const Color(0xFF94A3B8),
                ),
                tooltip: _sortOrder == 'ASC' ? 'Sắp xếp: A-Z' : 'Sắp xếp: Z-A',
              ),
              filled: true,
              fillColor: const Color(0xFFF6F7F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: 2,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFFE8F1FE),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
        NavigationDestination(icon: Icon(Icons.people_rounded), label: 'Cư dân'),
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Hộ dân'),
      ],
      onDestinationSelected: (i) {
        if (i == 0) context.go('/dashboard');
        if (i == 1) context.go('/directory');
      },
    );
  }

}

class _HouseholdCard extends StatelessWidget {
  final Household household;

  const _HouseholdCard({required this.household});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/household/${household.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      household.householdCode?.isNotEmpty == true
                          ? 'Mã hộ: ${household.householdCode}'
                          : 'Mã hộ: -',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF137FEC)),
                ],
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
