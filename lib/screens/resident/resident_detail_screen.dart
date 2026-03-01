import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/enum_mapper.dart';
import '../../models/resident.dart';
import '../../providers/resident_provider.dart';

class ResidentDetailScreen extends ConsumerWidget {
  final String residentId;

  const ResidentDetailScreen({super.key, required this.residentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentAsync = ref.watch(residentDetailProvider(residentId));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 92,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Row(
            children: [
              Icon(Icons.arrow_back_ios_new, color: Color(0xFF137FEC), size: 17),
              SizedBox(width: 2),
              Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF137FEC),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        title: const Text('Resident Details'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chưa hỗ trợ chỉnh sửa cư dân')),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFF137FEC),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: residentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Cannot load resident: $err'),
          ),
        ),
        data: (resident) => _ResidentDetailsBody(resident: resident),
      ),
    );
  }
}

class _ResidentDetailsBody extends StatelessWidget {
  final Resident resident;

  const _ResidentDetailsBody({required this.resident});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 10),
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 12),
              _buildHouseholdCard(context),
              const SizedBox(height: 12),
              _buildPersonalInfoCard(context),
            ],
          ),
        ),
        _buildBottomActionBar(context),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: const Color(0xFFEDEEEF),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF93C5FD), width: 2.5),
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFDCEBFD),
                  child: Text(
                    _avatarText(),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 1,
                bottom: 7,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF24C38A),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            resident.fullName,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'NIK: ${_displayValue(resident.identityCard)}',
            style: const TextStyle(
              color: Color(0xFF8293A8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFC8F1DF),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'ACTIVE RESIDENT',
                  style: TextStyle(
                    color: Color(0xFF0F8F5B),
                    letterSpacing: 0.7,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdCard(BuildContext context) {
    final relation = _relationshipWithHead();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDFE3E8)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Color(0xFF137FEC),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Household Info',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Head: ${_displayValue(resident.household?.headName)}',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (relation != null && relation.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F0FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        relation,
                        style: const TextStyle(
                          color: Color(0xFF137FEC),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            InkWell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              onTap: () {
                final householdId = resident.household?.id;
                if (householdId == null || householdId.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cư dân chưa thuộc hộ gia đình nào')),
                  );
                  return;
                }
                context.push('/household/$householdId');
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(14, 11, 14, 11),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'View Full Household',
                        style: TextStyle(
                          color: Color(0xFF137FEC),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Color(0xFF137FEC), size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDFE3E8)),
        ),
        child: Column(
          children: [
            _DetailRow(
              icon: Icons.person,
              iconColor: const Color(0xFF98A2B3),
              iconBackground: const Color(0xFFF2F4F7),
              label: 'GENDER',
              value: resident.gender.toVnString(),
            ),
            _DetailRow(
              icon: Icons.call,
              iconColor: const Color(0xFF16A34A),
              iconBackground: const Color(0xFFDCFCE7),
              label: 'PHONE NUMBER',
              value: _formatPhone(resident.phone),
              onTap: () => _callPhone(context, resident.phone),
            ),
            _DetailRow(
              icon: Icons.work,
              iconColor: const Color(0xFF98A2B3),
              iconBackground: const Color(0xFFF2F4F7),
              label: 'OCCUPATION',
              value: _displayValue(resident.occupation),
            ),
            _DetailRow(
              icon: Icons.location_on,
              iconColor: const Color(0xFF98A2B3),
              iconBackground: const Color(0xFFF2F4F7),
              label: 'ADDRESS',
              value: _displayValue(resident.address),
              hasBottomBorder: false,
              child: _buildMapPreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => _openMap(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          height: 84,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFFE6EDF6), Color(0xFFD4E1F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _MapPatternPainter())),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View Map',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            SizedBox(
              width: 76,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng chat chưa khả dụng')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD6DCE5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat, size: 17, color: Color(0xFF6B7280)),
                    SizedBox(height: 2),
                    Text(
                      'CHAT',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _callPhone(context, resident.phone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF137FEC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.call, size: 20),
                  label: const Text(
                    'Call Resident',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _relationshipWithHead() {
    final raw = _rawRelationshipWithHead();
    return EnumMapper.relationshipToVietnamese(raw, resident.gender);
  }

  String? _rawRelationshipWithHead() {
    if (resident.relationship != null && resident.relationship!.trim().isNotEmpty) {
      return resident.relationship;
    }

    final household = resident.household;
    if (household == null) {
      return null;
    }

    try {
      final value = (household as dynamic).relationshipOf(resident.id);
      return value?.toString();
    } catch (_) {
      return null;
    }
  }

  String _avatarText() {
    final parts = resident.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.characters.take(1).toString().toUpperCase();
    }
    final first = parts.first.characters.take(1).toString().toUpperCase();
    final last = parts.last.characters.take(1).toString().toUpperCase();
    return '$first$last';
  }

  String _displayValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '-';
    }
    return trimmed;
  }

  String _formatPhone(String? phone) {
    final raw = phone?.trim() ?? '';
    if (raw.isEmpty) {
      return '-';
    }

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '+${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    }
    return raw;
  }

  Future<void> _callPhone(BuildContext context, String? phone) async {
    final raw = phone?.trim() ?? '';
    if (raw.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không có số điện thoại')));
      return;
    }

    final normalized = raw.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: normalized);

    if (!await canLaunchUrl(uri)) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở ứng dụng gọi')));
      return;
    }

    await launchUrl(uri);
  }

  Future<void> _openMap(BuildContext context) async {
    final address = resident.address?.trim() ?? '';
    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không có địa chỉ để mở bản đồ')));
      return;
    }

    final encodedAddress = Uri.encodeComponent(address);
    final geoUri = Uri.parse('geo:0,0?q=$encodedAddress');
    final mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );

    var launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    if (!launched) {
      launched = await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }

    if (!launched) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở Google Maps')));
      return;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String? value;
  final Widget? child;
  final bool hasBottomBorder;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    this.child,
    this.hasBottomBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = (value == null || value!.trim().isEmpty) ? '-' : value!.trim();
    final optionalChild = child == null ? null : <Widget>[child!];

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: hasBottomBorder
              ? const Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF93A0B2),
                      letterSpacing: 0.6,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayValue,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  ...?optionalChild,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0xFFAFBFD3).withValues(alpha: 0.45)
      ..strokeWidth = 2;
    final dot = Paint()..color = const Color(0xFF8DA5BF).withValues(alpha: 0.55);

    canvas.drawLine(Offset(8, size.height * 0.25), Offset(size.width - 12, size.height * 0.2), line);
    canvas.drawLine(Offset(15, size.height * 0.55), Offset(size.width - 14, size.height * 0.5), line);
    canvas.drawLine(Offset(22, size.height * 0.82), Offset(size.width - 20, size.height * 0.76), line);
    canvas.drawLine(Offset(size.width * 0.2, 8), Offset(size.width * 0.24, size.height - 10), line);
    canvas.drawLine(Offset(size.width * 0.58, 10), Offset(size.width * 0.62, size.height - 8), line);

    const points = [
      Offset(26, 18),
      Offset(68, 24),
      Offset(112, 14),
      Offset(158, 30),
      Offset(202, 22),
      Offset(44, 54),
      Offset(96, 46),
      Offset(142, 58),
      Offset(186, 48),
      Offset(224, 62),
    ];
    for (final p in points) {
      canvas.drawCircle(p, 2.7, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
