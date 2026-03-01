import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/enum_mapper.dart';
import '../../models/household.dart';
import '../../providers/household_provider.dart';

class HouseholdDetailScreen extends ConsumerWidget {
  final String householdId;

  const HouseholdDetailScreen({super.key, required this.householdId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdsAsync = ref.watch(
      householdsProvider(const HouseholdsQueryParams()),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF137FEC)),
        ),
        title: const Text(
          'Full Household',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/household/$householdId/edit'),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFF137FEC),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: householdsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Cannot load household: $err'),
          ),
        ),
        data: (households) {
          Household? household;
          for (final item in households) {
            if (item.id == householdId) {
              household = item;
              break;
            }
          }

          if (household == null) {
            return const Center(child: Text('Household not found'));
          }

          return _HouseholdDetailBody(household: household);
        },
      ),
    );
  }
}

class _HouseholdDetailBody extends StatelessWidget {
  final Household household;

  const _HouseholdDetailBody({required this.household});

  @override
  Widget build(BuildContext context) {
    final members = household.members ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
      children: [
        _HouseholdHeaderCard(household: household),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCE2EA)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    Icon(Icons.groups, color: Color(0xFF137FEC), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Members',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (members.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 8, 14, 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No members in this household',
                      style: TextStyle(
                        color: Color(0xFF7C8A9F),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                ...members.map((member) => _MemberTile(member: member)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HouseholdHeaderCard extends StatelessWidget {
  final Household household;

  const _HouseholdHeaderCard({required this.household});

  @override
  Widget build(BuildContext context) {
    final members = household.members ?? const [];
    final head = household.head;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_rounded, color: Color(0xFF137FEC)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Household Information',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: ${_display(household.householdCode)}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.person,
            label: 'Head',
            value: head?.fullName ?? '-',
          ),
          const SizedBox(height: 8),
          _InfoLine(
            icon: Icons.location_on,
            label: 'Address',
            value: household.address.isEmpty ? '-' : household.address,
          ),
          const SizedBox(height: 8),
          _InfoLine(
            icon: Icons.groups_2,
            label: 'Total residents',
            value: '${members.length}',
          ),
        ],
      ),
    );
  }

  static String _display(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? '-' : text;
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5FA),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF111827), fontSize: 13),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final HouseholdMember member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final resident = member.resident;
    final fullName = resident.fullName.trim().isEmpty ? '-' : resident.fullName.trim();
    final relation =
        EnumMapper.relationshipToVietnamese(member.relationship, resident.gender) ??
        (member.relationship.trim().isEmpty ? '-' : member.relationship.trim());
    final initials = _initials(fullName);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5EAF1))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFDCEBFD),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF137FEC),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: #${resident.id} • $relation',
                  style: const TextStyle(
                    color: Color(0xFF7C8A9F),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
  }
}
