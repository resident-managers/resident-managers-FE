import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resident_provider.dart';
import '../../models/resident.dart';

class ResidentDirectoryScreen extends ConsumerStatefulWidget {
  const ResidentDirectoryScreen({super.key});

  @override
  ConsumerState<ResidentDirectoryScreen> createState() =>
      _ResidentDirectoryScreenState();
}

class _ResidentDirectoryScreenState
    extends ConsumerState<ResidentDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';
  String _keyword = '';
  String _sortOrder = 'ASC';

  @override
  Widget build(BuildContext context) {
    final params = _queryParams();
    final residentsAsync = ref.watch(residentsProvider(params));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: residentsAsync.when(
                data: (residents) => _buildResidentList(residents),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildErrorState(err),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () async {
            final created = await context.push<bool>('/add-resident');
            if (!mounted) {
              return;
            }
            if (created == true) {
              ref.invalidate(residentsProvider(_queryParams()));
            }
          },
          backgroundColor: const Color(0xFF137fec),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Không tải được danh sách cư dân từ máy chủ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(
                residentsProvider(_queryParams()),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              const Text(
                'Danh sách cư dân',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: .bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF64748B),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _keyword = value),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên hoặc mã...',
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
                tooltip: _sortOrder == 'ASC'
                    ? 'Sắp xếp: A-Z'
                    : 'Sắp xếp: Z-A',
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
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton('Tất cả'),
                _buildFilterButton('Nam'),
                _buildFilterButton('Nữ'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF137fec)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF137fec).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  ResidentsQueryParams _queryParams() {
    final gender = switch (_selectedFilter) {
      'Nam' => 'male',
      'Nữ' => 'female',
      _ => null,
    };

    return ResidentsQueryParams(
      search: _keyword.isEmpty ? null : _keyword,
      gender: gender,
      sortOrder: _sortOrder,
    );
  }

  Widget _buildResidentList(List<Resident> residents) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: residents.length,
      itemBuilder: (context, index) {
        final resident = residents[index];
        return ResidentCard(
          name: resident.fullName,
          id: resident.id,
          gender: resident.gender.toVnString(),
          onTap: () => context.push('/resident-detail/${resident.id}'),
        );
      },
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
        mainAxisAlignment: .spaceAround,
        children: [
          _buildNavItem(Icons.group, 'Cư dân', true),
          _buildNavItem(
            Icons.house,
            'Hộ dân',
            false,
            onTap: () => context.go('/households'),
          ),
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

    await ref.read(authProvider.notifier).logout();
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
        mainAxisSize: .min,
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

class ResidentCard extends StatelessWidget {
  final String name;
  final String id;
  final String gender;
  final String? imageUrl;
  final String? initials;
  final VoidCallback onTap;

  const ResidentCard({
    super.key,
    required this.name,
    required this.id,
    required this.gender,
    this.imageUrl,
    this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: .bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Mã: $id • $gender',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF137fec),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (imageUrl != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imageUrl!), // Simpler for demo
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF137fec).withValues(alpha: 0.1),
      child: Text(
        _safeAvatarText(),
        style: const TextStyle(
          color: Color(0xFF137fec),
          fontWeight: .bold,
          fontSize: 18,
        ),
      ),
    );
  }

  String _safeAvatarText() {
    final preferred = initials?.trim();
    if (preferred != null && preferred.isNotEmpty) {
      return preferred;
    }

    final normalized = name.trim();
    if (normalized.isEmpty) {
      return '?';
    }

    return normalized.characters.first.toUpperCase();
  }
}
