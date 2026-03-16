import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/enum_mapper.dart';
import '../../models/resident.dart';
import '../../models/health_insurance.dart';
import '../../models/social_insurance.dart';
import '../../models/temporary_residence.dart';
import '../../models/temporary_absence.dart';
import '../../providers/resident_provider.dart';
import '../../providers/insurance_provider.dart';
import '../../providers/temporary_provider.dart';

class ResidentDetailScreen extends ConsumerStatefulWidget {
  final String residentId;

  const ResidentDetailScreen({super.key, required this.residentId});

  @override
  ConsumerState<ResidentDetailScreen> createState() => _ResidentDetailScreenState();
}

class _ResidentDetailScreenState extends ConsumerState<ResidentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final residentAsync = ref.watch(residentDetailProvider(widget.residentId));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) { context.pop(); return; }
            context.go('/directory');
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF137FEC), size: 18),
        ),
        title: const Text('Chi tiết cư dân'),
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700, fontSize: 20),
        actions: [
          TextButton(
            onPressed: residentAsync.value == null ? null : () async {
              final updated = await context.push<bool>(
                '/resident-detail/${widget.residentId}/edit',
                extra: residentAsync.value,
              );
              if (updated == true) ref.invalidate(residentDetailProvider(widget.residentId));
            },
            child: const Text('Sửa', style: TextStyle(color: Color(0xFF137FEC), fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: residentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Không tải được thông tin cư dân: $err'))),
        data: (resident) => _ResidentDetailsBody(resident: resident, residentId: widget.residentId),
      ),
    );
  }
}

class _ResidentDetailsBody extends ConsumerWidget {
  final Resident resident;
  final String residentId;

  const _ResidentDetailsBody({required this.resident, required this.residentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const SizedBox(height: 12),
              _buildHealthInsuranceSection(context, ref),
              const SizedBox(height: 12),
              _buildSocialInsuranceSection(context, ref),
              const SizedBox(height: 12),
              _buildTemporaryResidenceSection(context, ref),
              const SizedBox(height: 12),
              _buildTemporaryAbsenceSection(context, ref),
              const SizedBox(height: 12),
            ],
          ),
        ),
        _buildBottomActionBar(context),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final badgeText = resident.residenceTypeBadge();
    final badgeBg = resident.residenceTypeBgColor();
    final badgeColor = resident.residenceTypeColor();

    return Container(
      color: const Color(0xFFEDEEEF),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96, height: 96,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF93C5FD), width: 2.5)),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFDCEBFD),
                  child: Text(_avatarText(), style: const TextStyle(color: Color(0xFF0F172A), fontSize: 30, fontWeight: FontWeight.w700)),
                ),
              ),
              Positioned(
                right: 1, bottom: 7,
                child: Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: badgeColor, border: Border.all(color: Colors.white, width: 2))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(resident.fullName, style: const TextStyle(color: Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.w700, height: 1.05), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('CCCD: ${_displayValue(resident.identityCard)}', style: const TextStyle(color: Color(0xFF8293A8), fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(100)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: badgeColor),
                const SizedBox(width: 6),
                Text(badgeText, style: TextStyle(color: badgeColor, letterSpacing: 0.7, fontSize: 12, fontWeight: FontWeight.w700)),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDFE3E8))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFE8F1FE), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.home_rounded, color: Color(0xFF137FEC), size: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin hộ dân', style: TextStyle(color: Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Chủ hộ: ${_displayValue(resident.household?.headName)}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  if (relation != null && relation.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE7F0FD), borderRadius: BorderRadius.circular(8)),
                      child: Text(relation, style: const TextStyle(color: Color(0xFF137FEC), fontSize: 13, fontWeight: FontWeight.w700)),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cư dân chưa thuộc hộ gia đình nào')));
                  return;
                }
                context.push('/household/$householdId');
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(14, 11, 14, 11),
                child: Row(
                  children: [
                    Expanded(child: Text('Xem chi tiết hộ dân', style: TextStyle(color: Color(0xFF137FEC), fontSize: 14, fontWeight: FontWeight.w600))),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDFE3E8))),
        child: Column(
          children: [
            _DetailRow(icon: Icons.person, iconColor: const Color(0xFF98A2B3), iconBackground: const Color(0xFFF2F4F7), label: 'GIỚI TÍNH', value: resident.gender.toVnString()),
            if (resident.birthDate != null)
              _DetailRow(icon: Icons.cake_rounded, iconColor: const Color(0xFFEC4899), iconBackground: const Color(0xFFFCE7F3), label: 'NGÀY SINH', value: DateFormat('dd/MM/yyyy').format(resident.birthDate!)),
            _DetailRow(icon: Icons.call, iconColor: const Color(0xFF16A34A), iconBackground: const Color(0xFFDCFCE7), label: 'SỐ ĐIỆN THOẠI', value: _formatPhone(resident.phone), onTap: () => _callPhone(context, resident.phone)),
            _DetailRow(icon: Icons.work, iconColor: const Color(0xFF98A2B3), iconBackground: const Color(0xFFF2F4F7), label: 'NGHỀ NGHIỆP', value: _displayValue(resident.occupation)),
            if (resident.ethnicity != null && resident.ethnicity!.isNotEmpty)
              _DetailRow(icon: Icons.flag_rounded, iconColor: const Color(0xFF98A2B3), iconBackground: const Color(0xFFF2F4F7), label: 'DÂN TỘC', value: _displayValue(resident.ethnicity)),
            if (resident.religion != null && resident.religion!.isNotEmpty)
              _DetailRow(icon: Icons.temple_buddhist_rounded, iconColor: const Color(0xFF98A2B3), iconBackground: const Color(0xFFF2F4F7), label: 'TÔN GIÁO', value: _displayValue(resident.religion)),
            if (resident.educationLevel != null && resident.educationLevel!.isNotEmpty)
              _DetailRow(icon: Icons.school_rounded, iconColor: const Color(0xFF98A2B3), iconBackground: const Color(0xFFF2F4F7), label: 'TRÌNH ĐỘ HỌC VẤN', value: _displayValue(resident.educationLevel)),
            _DetailRow(
              icon: Icons.location_on,
              iconColor: const Color(0xFF98A2B3),
              iconBackground: const Color(0xFFF2F4F7),
              label: 'ĐỊA CHỈ',
              value: _displayValue(resident.address),
              hasBottomBorder: resident.permanentAddress != null && resident.permanentAddress!.isNotEmpty,
              child: _buildMapPreview(),
            ),
            if (resident.permanentAddress != null && resident.permanentAddress!.isNotEmpty)
              _DetailRow(icon: Icons.home_rounded, iconColor: const Color(0xFF137FEC), iconBackground: const Color(0xFFE8F1FE), label: 'ĐỊA CHỈ THƯỜNG TRÚ', value: _displayValue(resident.permanentAddress), hasBottomBorder: false),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInsuranceSection(BuildContext context, WidgetRef ref) {
    final insurancesAsync = ref.watch(healthInsurancesProvider(residentId));
    return _buildCollapsibleSection(
      context: context,
      icon: Icons.health_and_safety_rounded,
      iconColor: const Color(0xFF10B981),
      iconBg: const Color(0xFFD1FAE5),
      title: 'Bảo hiểm y tế',
      child: insurancesAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi: $e', style: const TextStyle(color: Color(0xFFEF4444)))),
        data: (list) {
          if (list.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Chưa có thông tin bảo hiểm y tế', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)));
          return Column(
            children: list.map((ins) => _HealthInsuranceTile(insurance: ins)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildSocialInsuranceSection(BuildContext context, WidgetRef ref) {
    final insurancesAsync = ref.watch(socialInsurancesProvider(residentId));
    return _buildCollapsibleSection(
      context: context,
      icon: Icons.account_balance_rounded,
      iconColor: const Color(0xFF3B82F6),
      iconBg: const Color(0xFFDBEAFE),
      title: 'Bảo hiểm xã hội',
      child: insurancesAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi: $e', style: const TextStyle(color: Color(0xFFEF4444)))),
        data: (list) {
          if (list.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Chưa có thông tin bảo hiểm xã hội', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)));
          return Column(children: list.map((ins) => _SocialInsuranceTile(insurance: ins)).toList());
        },
      ),
    );
  }

  Widget _buildTemporaryResidenceSection(BuildContext context, WidgetRef ref) {
    final tempsAsync = ref.watch(temporaryResidencesProvider(residentId));
    return _buildCollapsibleSection(
      context: context,
      icon: Icons.assignment_ind_rounded,
      iconColor: const Color(0xFF0EA5E9),
      iconBg: const Color(0xFFE0F2FE),
      title: 'Đăng ký tạm trú',
      child: tempsAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi: $e', style: const TextStyle(color: Color(0xFFEF4444)))),
        data: (list) {
          if (list.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Chưa có đăng ký tạm trú', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)));
          return Column(children: list.map((t) => _TemporaryResidenceTile(item: t)).toList());
        },
      ),
    );
  }

  Widget _buildTemporaryAbsenceSection(BuildContext context, WidgetRef ref) {
    final tempsAsync = ref.watch(temporaryAbsencesProvider(residentId));
    return _buildCollapsibleSection(
      context: context,
      icon: Icons.flight_takeoff_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBg: const Color(0xFFEDE9FE),
      title: 'Đăng ký tạm vắng',
      child: tempsAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi: $e', style: const TextStyle(color: Color(0xFFEF4444)))),
        data: (list) {
          if (list.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Chưa có đăng ký tạm vắng', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)));
          return Column(children: list.map((t) => _TemporaryAbsenceTile(item: t)).toList());
        },
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDFE3E8))),
          child: ExpansionTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
            title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
            tilePadding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
            childrenPadding: EdgeInsets.zero,
            children: [const Divider(height: 1, color: Color(0xFFE5E7EB)), child],
          ),
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
            gradient: const LinearGradient(colors: [Color(0xFFE6EDF6), Color(0xFFD4E1F0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _MapPatternPainter())),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Xem bản đồ', style: TextStyle(color: Color(0xFF1F2937), fontSize: 13, fontWeight: FontWeight.w700)),
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
              width: 76, height: 56,
              child: OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng chat chưa khả dụng'))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD6DCE5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.chat, size: 17, color: Color(0xFF6B7280)), SizedBox(height: 2), Text('NHẮN TIN', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.w700))],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _callPhone(context, resident.phone),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF137FEC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.call, size: 20),
                  label: const Text('Gọi cư dân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
    if (resident.relationship != null && resident.relationship!.trim().isNotEmpty) return resident.relationship;
    final household = resident.household;
    if (household == null) return null;
    try { return (household as dynamic).relationshipOf(resident.id)?.toString(); } catch (_) { return null; }
  }

  String _avatarText() {
    final parts = resident.fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.take(1).toString().toUpperCase();
    return '${parts.first.characters.take(1).toString().toUpperCase()}${parts.last.characters.take(1).toString().toUpperCase()}';
  }

  String _displayValue(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? '-' : trimmed;
  }

  String _formatPhone(String? phone) {
    final raw = phone?.trim() ?? '';
    if (raw.isEmpty) return '-';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    return raw;
  }

  Future<void> _callPhone(BuildContext context, String? phone) async {
    final raw = phone?.trim() ?? '';
    if (raw.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có số điện thoại'))); return; }
    final uri = Uri(scheme: 'tel', path: raw.replaceAll(RegExp(r'[^\d+]'), ''));
    if (!await canLaunchUrl(uri)) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở ứng dụng gọi'))); return; }
    await launchUrl(uri);
  }

  Future<void> _openMap(BuildContext context) async {
    final address = resident.address?.trim() ?? '';
    if (address.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có địa chỉ để mở bản đồ'))); return; }
    final enc = Uri.encodeComponent(address);
    var launched = await launchUrl(Uri.parse('geo:0,0?q=$enc'), mode: LaunchMode.externalApplication);
    if (!launched) launched = await launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$enc'), mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở Google Maps')));
  }
}

class _HealthInsuranceTile extends StatelessWidget {
  final HealthInsurance insurance;
  const _HealthInsuranceTile({required this.insurance});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final isExpired = insurance.isExpired;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(insurance.code, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: isExpired ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(4)),
                      child: Text(isExpired ? 'Hết hạn' : 'Còn hạn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isExpired ? const Color(0xFFEF4444) : const Color(0xFF10B981))),
                    ),
                  ],
                ),
                if (insurance.healthcareFacility != null) ...[
                  const SizedBox(height: 2),
                  Text(insurance.healthcareFacility!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (insurance.issuedDate != null) Text('Cấp: ${fmt.format(insurance.issuedDate!)}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    if (insurance.issuedDate != null && insurance.expiryDate != null) const Text(' · ', style: TextStyle(color: Color(0xFF9CA3AF))),
                    if (insurance.expiryDate != null) Text('HH: ${fmt.format(insurance.expiryDate!)}', style: TextStyle(fontSize: 11, color: isExpired ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialInsuranceTile extends StatelessWidget {
  final SocialInsurance insurance;
  const _SocialInsuranceTile({required this.insurance});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(insurance.code, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                child: Text(insurance.statusVn, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
              ),
            ],
          ),
          if (insurance.employer != null) ...[const SizedBox(height: 2), Text(insurance.employer!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))],
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Loại: ${insurance.insuranceTypeVn}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              if (insurance.enrolledDate != null) Text(' · Tham gia: ${fmt.format(insurance.enrolledDate!)}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemporaryResidenceTile extends StatelessWidget {
  final TemporaryResidence item;
  const _TemporaryResidenceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: item.isActive ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                child: Text(item.isActive ? 'Đang tạm trú' : 'Đã kết thúc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: item.isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF))),
              ),
            ],
          ),
          if (item.hostName != null) ...[const SizedBox(height: 2), Text('Chủ nhà: ${item.hostName}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))],
          const SizedBox(height: 4),
          Text(
            '${item.fromDate != null ? fmt.format(item.fromDate!) : '?'} → ${item.toDate != null ? fmt.format(item.toDate!) : 'Không xác định'}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
          if (item.reason != null) ...[const SizedBox(height: 2), Text('Lý do: ${item.reason}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)))],
        ],
      ),
    );
  }
}

class _TemporaryAbsenceTile extends StatelessWidget {
  final TemporaryAbsence item;
  const _TemporaryAbsenceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.destination, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: item.isActive ? const Color(0xFFEDE9FE) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                child: Text(item.isActive ? 'Đang vắng' : 'Đã về', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: item.isActive ? const Color(0xFF8B5CF6) : const Color(0xFF9CA3AF))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.fromDate != null ? fmt.format(item.fromDate!) : '?'} → ${item.toDate != null ? fmt.format(item.toDate!) : 'Không xác định'}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
          if (item.reason != null) ...[const SizedBox(height: 2), Text('Lý do: ${item.reason}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)))],
        ],
      ),
    );
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

  const _DetailRow({required this.icon, required this.iconColor, required this.iconBackground, required this.label, required this.value, this.child, this.hasBottomBorder = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayValue = (value == null || value!.trim().isEmpty) ? '-' : value!.trim();
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(border: hasBottomBorder ? const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))) : null),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF93A0B2), letterSpacing: 0.6, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(displayValue, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w700, height: 1.2)),
                  // ignore: use_null_aware_elements
                  if (child != null) child!,
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
    final line = Paint()..color = const Color(0xFFAFBFD3).withValues(alpha: 0.45)..strokeWidth = 2;
    final dot = Paint()..color = const Color(0xFF8DA5BF).withValues(alpha: 0.55);
    canvas.drawLine(Offset(8, size.height * 0.25), Offset(size.width - 12, size.height * 0.2), line);
    canvas.drawLine(Offset(15, size.height * 0.55), Offset(size.width - 14, size.height * 0.5), line);
    canvas.drawLine(Offset(22, size.height * 0.82), Offset(size.width - 20, size.height * 0.76), line);
    canvas.drawLine(Offset(size.width * 0.2, 8), Offset(size.width * 0.24, size.height - 10), line);
    canvas.drawLine(Offset(size.width * 0.58, 10), Offset(size.width * 0.62, size.height - 8), line);
    const points = [Offset(26, 18), Offset(68, 24), Offset(112, 14), Offset(158, 30), Offset(202, 22), Offset(44, 54), Offset(96, 46), Offset(142, 58), Offset(186, 48), Offset(224, 62)];
    for (final p in points) { canvas.drawCircle(p, 2.7, dot); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
