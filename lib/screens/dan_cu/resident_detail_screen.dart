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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Resident Details'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resident.fullName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('ID: ${resident.id}'),
                Text('Giới tính: ${resident.gender.toVnString()}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _InfoTile(label: 'Ngày sinh', value: _fmtDate(resident.birthDate)),
        _InfoTile(
          label: 'Số điện thoại',
          value: resident.phone,
          isAction: true,
          onTap: () => _callPhone(context, resident.phone),
        ),
        _InfoTile(label: 'Căn cước công dân', value: resident.identityCard),
        _InfoTile(label: 'Chủ hộ', value: resident.household?.headName),
        _InfoTile(label: 'Địa chỉ thường trú', value: resident.address),
        _InfoTile(label: 'Nghề nghiệp', value: resident.occupation),
        _InfoTile(label: 'Dân tộc', value: resident.ethnicity),
        _InfoTile(label: 'Tôn giáo', value: resident.religion),
        _InfoTile(label: 'Trình độ học vấn', value: resident.educationLevel),
        _InfoTile(label: 'Quan hệ với chủ hộ', value: _relationshipWithHead()),
        _InfoTile(label: 'Ghi chú', value: resident.notes),
      ],
    );
  }

  String? _relationshipWithHead() {
    final raw = _rawRelationshipWithHead();
    return EnumMapper.relationshipToVietnamese(raw, resident.gender);
  }

  String? _rawRelationshipWithHead() {
    if (resident.relationship != null &&
        resident.relationship!.trim().isNotEmpty) {
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

  String _fmtDate(DateTime? date) {
    if (date == null) {
      return '-';
    }
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng gọi')),
      );
      return;
    }

    await launchUrl(uri);
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String? value;
  final bool isAction;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.label,
    required this.value,
    this.isAction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = (value == null || value!.trim().isEmpty)
        ? '-'
        : value!.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(label),
        subtitle: Text(displayValue),
        trailing: isAction ? const Icon(Icons.call_outlined, size: 20) : null,
      ),
    );
  }
}
