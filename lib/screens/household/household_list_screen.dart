import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/household.dart';
import '../../providers/auth_provider.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.blueGrey.shade50)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.group,
            'Cư dân',
            false,
            onTap: () => context.go('/directory'),
          ),
          _buildNavItem(Icons.house, 'Hộ dân', true),
          _buildNavItem(
            Icons.account_circle,
            'Tài khoản',
            false,
            onTap: _onProfileTap,
          ),
        ],
      ),
    );
  }

  Future<void> _onProfileTap() async {
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  leading: Icon(Icons.account_circle_outlined),
                  title: Text('Tài khoản'),
                  subtitle: Text('Thao tác tài khoản'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Hủy'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await ref.read(authProvider.notifier).logout();
    } catch (_) {}
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF137fec).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF137fec)
                  : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? const Color(0xFF137fec)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
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
