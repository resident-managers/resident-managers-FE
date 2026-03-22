import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/statistics.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authProvider); // Keep provider alive to prevent race condition on logout
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF137FEC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Quản Lý Dân Cư',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF6B7280)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(statisticsProvider.future),
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _buildError(context, ref, err),
          data: (stats) => _buildBody(context, stats),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            const Text('Không tải được dữ liệu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(err.toString(), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(statisticsProvider.future),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ResidentStatistics stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Tổng quan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Thống kê dân số khu vực',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Tổng cư dân', value: stats.totalResidents, icon: Icons.people_rounded, color: const Color(0xFF137FEC), bgColor: const Color(0xFFE8F1FE))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Tổng hộ dân', value: stats.totalHouseholds, icon: Icons.home_rounded, color: const Color(0xFF10B981), bgColor: const Color(0xFFD1FAE5))),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Theo giới tính', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Nam', value: stats.maleCount, icon: Icons.male_rounded, color: const Color(0xFF3B82F6), bgColor: const Color(0xFFDBEAFE))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Nữ', value: stats.femaleCount, icon: Icons.female_rounded, color: const Color(0xFFEC4899), bgColor: const Color(0xFFFCE7F3))),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Theo tình trạng cư trú', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Thường trú', value: stats.permanentCount, icon: Icons.house_rounded, color: const Color(0xFF10B981), bgColor: const Color(0xFFC8F1DF))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Tạm trú', value: stats.temporaryCount, icon: Icons.location_on_rounded, color: const Color(0xFFF59E0B), bgColor: const Color(0xFFFEF3C7))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Tạm vắng', value: stats.absentCount, icon: Icons.person_off_rounded, color: const Color(0xFF6366F1), bgColor: const Color(0xFFE0E7FF))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Đã chuyển đi', value: stats.movedOutCount, icon: Icons.directions_run_rounded, color: const Color(0xFFEF4444), bgColor: const Color(0xFFFEE2E2))),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Đang hoạt động', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Đăng ký tạm trú', value: stats.activeTemporaryResidences, icon: Icons.assignment_ind_rounded, color: const Color(0xFF0EA5E9), bgColor: const Color(0xFFE0F2FE))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Đăng ký tạm vắng', value: stats.activeTemporaryAbsences, icon: Icons.flight_takeoff_rounded, color: const Color(0xFF8B5CF6), bgColor: const Color(0xFFEDE9FE))),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Truy cập nhanh', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.people_rounded,
                label: 'Danh sách cư dân',
                color: const Color(0xFF137FEC),
                onTap: () => context.go('/directory'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.home_rounded,
                label: 'Danh sách hộ dân',
                color: const Color(0xFF10B981),
                onTap: () => context.go('/households'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFFE8F1FE),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
        NavigationDestination(icon: Icon(Icons.people_rounded), label: 'Cư dân'),
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Hộ dân'),
      ],
      onDestinationSelected: (i) {
        if (i == 1) context.go('/directory');
        if (i == 2) context.go('/households');
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
