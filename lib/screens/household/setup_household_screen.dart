import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/graphql_client.dart';
import '../../graphql/mutations.dart';
import '../../models/household.dart';
import '../../models/resident.dart';
import '../../providers/household_provider.dart';
import '../../providers/resident_provider.dart';

class SetupHouseholdScreen extends ConsumerStatefulWidget {
  final bool isEditMode;
  final String? householdId;

  const SetupHouseholdScreen({
    super.key,
    this.isEditMode = false,
    this.householdId,
  });

  @override
  ConsumerState<SetupHouseholdScreen> createState() => _SetupHouseholdScreenState();
}

class _SetupHouseholdScreenState extends ConsumerState<SetupHouseholdScreen> {
  static const _relationships = <MapEntry<String, String>>[
    MapEntry('HUSBAND', 'Chồng'),
    MapEntry('WIFE', 'Vợ'),
    MapEntry('FATHER', 'Bố'),
    MapEntry('MOTHER', 'Mẹ'),
    MapEntry('SON', 'Con trai'),
    MapEntry('OLDER_BROTHER', 'Anh trai'),
    MapEntry('OLDER_SISTER', 'Chị gái'),
    MapEntry('YOUNGER_SIBLING', 'Em'),
  ];

  final TextEditingController _addressController = TextEditingController();
  Resident? _selectedHead;
  final List<_HouseholdMemberDraft> _members = [];
  final Set<String> _editableResidentIds = {};
  bool _isSaving = false;
  bool _isLoadingExisting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _isLoadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingHousehold();
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.isEditMode ? 'Edit Household' : 'Setup Household';
    final actionText = widget.isEditMode ? 'Update Household' : 'Create Household';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            widget.isEditMode ? Icons.arrow_back_ios_new : Icons.close,
            color: const Color(0xFF334155),
            size: widget.isEditMode ? 18 : 24,
          ),
        ),
        title: Text(
          pageTitle,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                'Save',
                style: TextStyle(
                  color: widget.isEditMode ? const Color(0xFF137FEC) : const Color(0xFF93C5FD),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: _isLoadingExisting
            ? const [
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
              ]
            : [
                _buildHeadSection(),
                _buildSectionDivider(),
                _buildMembersSection(),
                _buildSectionDivider(),
                _buildSummarySection(),
              ],
      ),
      bottomNavigationBar: _buildBottomActionBar(actionText),
    );
  }

  Widget _buildHeadSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.person_pin, title: 'HEAD OF HOUSEHOLD'),
          const SizedBox(height: 10),
          _buildResidentPickerField(
            hint: _selectedHead == null
                ? 'Search resident by name or ID...'
                : _selectedHead!.fullName,
            onTap: widget.isEditMode ? null : _pickHead,
          ),
          const SizedBox(height: 10),
          const _SectionHeader(icon: Icons.location_on, title: 'HOUSEHOLD ADDRESS'),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Nhập địa chỉ hộ dân...',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDCE2EA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDCE2EA)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _selectedHead == null ? _buildEmptyHead() : _buildSelectedHead(),
        ],
      ),
    );
  }

  Widget _buildResidentPickerField({required String hint, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDCE2EA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF94A3B8)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _selectedHead == null ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.expand_more, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedHead() {
    final head = _selectedHead!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE2EA)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFDCEBFD),
            child: Text(
              _avatarInitials(head.fullName),
              style: const TextStyle(
                color: Color(0xFF137FEC),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  head.fullName,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: #${head.id}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Head',
              style: TextStyle(
                color: Color(0xFF137FEC),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.isEditMode
                ? null
                : () => setState(() => _selectedHead = null),
            icon: Icon(
              widget.isEditMode ? Icons.lock : Icons.close,
              size: 16,
              color: widget.isEditMode ? const Color(0xFF9CA3AF) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHead() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE2EA)),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE6EBF2),
            child: Icon(Icons.person_off, color: Color(0xFF8894A7), size: 22),
          ),
          SizedBox(height: 10),
          Text(
            'No Head Selected',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Select a resident above to assign\nthem as the head of this\nhousehold.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7C8A9F),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionHeader(icon: Icons.diversity_3, title: 'FAMILY MEMBERS'),
              ),
              TextButton.icon(
                onPressed: _pickMember,
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF137FEC)),
                icon: const Icon(Icons.add_circle, size: 16),
                label: const Text(
                  'Add Member',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_members.isEmpty)
            _buildAddMemberPlaceholder()
          else ...[
            ..._members.map(_buildMemberItem),
            _buildAddMemberPlaceholder(),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberItem(_HouseholdMemberDraft member) {
    final isHeadMember = _isHeadRelationship(member.relationship);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE2EA)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE0E7FF),
            child: Text(
              _avatarInitials(member.resident.fullName),
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.resident.fullName,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: #${member.resident.id} • ${member.relationshipLabel}',
                  style: const TextStyle(
                    color: Color(0xFF7C8A9F),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isHeadMember
                ? null
                : () {
                    setState(() {
                      _members.remove(member);
                    });
                  },
            icon: Icon(
              isHeadMember ? Icons.lock : Icons.remove_circle,
              color: isHeadMember ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberPlaceholder() {
    return InkWell(
      onTap: _pickMember,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EAF1)),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE5E7EB),
              child: Icon(Icons.add, color: Color(0xFF9CA3AF), size: 16),
            ),
            SizedBox(width: 10),
            Text(
              'Add another member...',
              style: TextStyle(
                color: Color(0xFFA1A9B8),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final headCount = _selectedHead == null ? 0 : 1;
    final memberCount = _members.length;
    final total = headCount + memberCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
      child: Column(
        children: [
          const _SectionHeader(icon: Icons.receipt_long, title: 'HOUSEHOLD SUMMARY'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCE2EA)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Residents',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '$total',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18, color: Color(0xFFD9E1EA)),
                _summaryDotRow('Head', headCount, const Color(0xFF137FEC)),
                const SizedBox(height: 8),
                _summaryDotRow('Members', memberCount, const Color(0xFF6366F1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDotRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7C8A9F),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Divider(height: 1, color: Color(0xFFDCE2EA)),
    );
  }

  Widget _buildBottomActionBar(String actionText) {
    return Container(
      color: const Color(0xFFF6F7F8),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF137FEC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check, size: 18),
            label: Text(
              actionText,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickHead() async {
    if (widget.isEditMode) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể thay đổi chủ hộ khi cập nhật')));
      return;
    }
    final excluded = _members.map((m) => m.resident.id).toSet();
    final selected = await _showResidentPicker(
      title: 'Select Head of Household',
      excludedResidentIds: excluded,
      excludeResidentsInAnyHousehold: true,
      allowedResidentIds: _editableResidentIds,
    );
    if (selected == null) {
      return;
    }
    setState(() {
      _selectedHead = selected;
    });
  }

  Future<void> _pickMember() async {
    final excluded = _members.map((m) => m.resident.id).toSet();
    if (_selectedHead != null) {
      excluded.add(_selectedHead!.id);
    }

    final selected = await _showResidentPicker(
      title: 'Add Family Member',
      excludedResidentIds: excluded,
      excludeResidentsInAnyHousehold: true,
      allowedResidentIds: _editableResidentIds,
    );
    if (selected == null || !mounted) {
      return;
    }

    final relation = await _showRelationshipPicker();
    if (relation == null || !mounted) {
      return;
    }

    setState(() {
      _members.add(
        _HouseholdMemberDraft(
          resident: selected,
          relationship: relation.key,
          relationshipLabel: relation.value,
        ),
      );
    });
  }

  Future<Resident?> _showResidentPicker({
    required String title,
    required Set<String> excludedResidentIds,
    bool excludeResidentsInAnyHousehold = false,
    Set<String> allowedResidentIds = const {},
  }) async {
    var keyword = '';
    return showModalBottomSheet<Resident>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Consumer(
              builder: (context, ref, _) {
                final media = MediaQuery.of(context);
                final availableHeight =
                    media.size.height - media.viewInsets.bottom - media.padding.top - 24;
                final sheetHeight = availableHeight.clamp(280.0, media.size.height * 0.9);
                final householdsAsync = ref.watch(
                  householdsProvider(const HouseholdsQueryParams()),
                );

                final residentsAsync = ref.watch(
                  residentsProvider(
                    ResidentsQueryParams(
                      search: keyword.trim().isEmpty ? null : keyword.trim(),
                      sortOrder: 'ASC',
                    ),
                  ),
                );

                return SafeArea(
                  top: false,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: SizedBox(
                        height: sheetHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1D5DB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              autofocus: true,
                              onChanged: (value) {
                                setModalState(() {
                                  keyword = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search resident by name or ID...',
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFDCE2EA)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFDCE2EA)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: householdsAsync.when(
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (err, _) => Center(
                                  child: Text(
                                    'Cannot load households\n$err',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                data: (households) => residentsAsync.when(
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                  error: (err, _) => Center(
                                    child: Text(
                                      'Cannot load residents\n$err',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  data: (residents) {
                                    final occupiedResidentIds = <String>{};
                                    if (excludeResidentsInAnyHousehold) {
                                      for (final household in households) {
                                        final headId = household.head?.id.trim();
                                        if (headId != null && headId.isNotEmpty) {
                                          occupiedResidentIds.add(headId);
                                        }
                                        for (final member in household.members ?? const []) {
                                          final memberId = member.resident.id.trim();
                                          if (memberId.isNotEmpty) {
                                            occupiedResidentIds.add(memberId);
                                          }
                                        }
                                      }
                                    }

                                    final options = residents
                                        .where((r) => !excludedResidentIds.contains(r.id))
                                        .where(
                                          (r) =>
                                              !occupiedResidentIds.contains(r.id) ||
                                              allowedResidentIds.contains(r.id),
                                        )
                                        .toList();
                                    if (options.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'No resident available',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }
                                    return ListView.separated(
                                      itemCount: options.length,
                                      separatorBuilder: (_, _) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final resident = options[index];
                                        return ListTile(
                                          onTap: () => Navigator.of(sheetContext).pop(resident),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                          leading: CircleAvatar(
                                            backgroundColor: const Color(0xFFDCEBFD),
                                            child: Text(
                                              _avatarInitials(resident.fullName),
                                              style: const TextStyle(
                                                color: Color(0xFF137FEC),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            resident.fullName,
                                            style: const TextStyle(
                                              color: Color(0xFF111827),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'ID: #${resident.id}',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<MapEntry<String, String>?> _showRelationshipPicker() async {
    return showModalBottomSheet<MapEntry<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final media = MediaQuery.of(context);
        final availableHeight =
            media.size.height - media.viewInsets.bottom - media.padding.top - 24;
        final sheetHeight = availableHeight.clamp(260.0, media.size.height * 0.75);

        return SafeArea(
          top: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: SizedBox(
                height: sheetHeight,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Relationship',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _relationships.length,
                        itemBuilder: (context, index) {
                          final item = _relationships[index];
                          return ListTile(
                            onTap: () => Navigator.of(context).pop(item),
                            title: Text(item.value),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_selectedHead == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn chủ hộ')));
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập địa chỉ hộ dân')));
      return;
    }
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 thành viên')),
      );
      return;
    }
    final hasHeadRoleInMembers = _members.any((m) => _isHeadRelationship(m.relationship));
    if (hasHeadRoleInMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thành viên có vai trò chủ hộ không được phép cập nhật/xóa')),
      );
      return;
    }
    final hasInvalidRelationship = _members.any((m) => !_isValidMemberRelationship(m.relationship));
    if (hasInvalidRelationship) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ được cập nhật thành viên có quan hệ hợp lệ với chủ hộ')),
      );
      return;
    }
    final memberIds = _members.map((m) => m.resident.id).toList();
    if (memberIds.toSet().length != memberIds.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Danh sách thành viên đang bị trùng')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final client = GraphQLConfig.client.value;
    final payload = widget.isEditMode
        ? {
            'id': widget.householdId ?? '',
            'address': address,
            'members': _members
                .map(
                  (m) => {
                    'residentId': m.resident.id,
                    'relationship': m.relationship,
                  },
                )
                .toList(),
          }
        : {
            'residentId': _selectedHead!.id,
            'address': address,
            'members': _members
                .map(
                  (m) => {
                    'residentId': m.resident.id,
                    'relationship': m.relationship,
                  },
                )
                .toList(),
          };

    final result = await client.mutate(
      MutationOptions(
        document: gql(widget.isEditMode ? updateHouseholdMutation : createHouseholdMutation),
        variables: {
          'input': payload,
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (result.hasException) {
      final message = _graphqlErrorMessage(
        result.exception,
        widget.isEditMode ? 'Cập nhật hộ dân thất bại' : 'Tạo hộ dân thất bại',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ref.invalidate(householdsProvider(const HouseholdsQueryParams()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(content: Text(widget.isEditMode ? 'Cập nhật hộ dân thành công' : 'Tạo hộ dân thành công')),
    );
    context.pop(true);
  }

  Future<void> _loadExistingHousehold() async {
    final householdId = widget.householdId?.trim();
    if (householdId == null || householdId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingExisting = false;
      });
      return;
    }

    try {
      final households = await ref.read(
        householdsProvider(const HouseholdsQueryParams()).future,
      );
      Household? household;
      for (final item in households) {
        if (item.id == householdId) {
          household = item;
          break;
        }
      }

      if (!mounted) {
        return;
      }

      if (household == null) {
        setState(() {
          _isLoadingExisting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không tìm thấy hộ dân để cập nhật')));
        return;
      }

      final head = household.head;
      final drafts = <_HouseholdMemberDraft>[];
      final editableIds = <String>{};

      if (head != null && head.id.trim().isNotEmpty) {
        editableIds.add(head.id.trim());
      }

      for (final member in household.members ?? const []) {
        final id = member.resident.id.trim();
        if (id.isEmpty) {
          continue;
        }
        if (_isHeadRelationship(member.relationship)) {
          continue;
        }
        if (head != null && id == head.id.trim()) {
          continue;
        }
        editableIds.add(id);
        drafts.add(
          _HouseholdMemberDraft(
            resident: member.resident,
            relationship: member.relationship,
            relationshipLabel: _relationshipLabel(member.relationship),
          ),
        );
      }

      setState(() {
        _selectedHead = head;
        _members
          ..clear()
          ..addAll(drafts);
        _editableResidentIds
          ..clear()
          ..addAll(editableIds);
        _addressController.text = household!.address;
        _isLoadingExisting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingExisting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không tải được dữ liệu hộ dân hiện tại')));
    }
  }

  String _relationshipLabel(String relationship) {
    for (final item in _relationships) {
      if (item.key.toUpperCase() == relationship.trim().toUpperCase()) {
        return item.value;
      }
    }
    return relationship;
  }

  bool _isHeadRelationship(String relationship) {
    final value = relationship.trim().toUpperCase();
    return value == 'HEAD' || value == 'HOUSEHOLD_HEAD';
  }

  bool _isValidMemberRelationship(String relationship) {
    final value = relationship.trim().toUpperCase();
    if (value.isEmpty || _isHeadRelationship(value)) {
      return false;
    }
    for (final item in _relationships) {
      if (item.key.toUpperCase() == value) {
        return true;
      }
    }
    return false;
  }

  String _graphqlErrorMessage(OperationException? exception, String fallbackMessage) {
    if (exception == null) {
      return fallbackMessage;
    }
    if (exception.graphqlErrors.isNotEmpty) {
      final message = exception.graphqlErrors.first.message.trim();
      if (message.isNotEmpty) {
        return message;
      }
    }
    if (exception.linkException != null) {
      return 'Lỗi kết nối tới máy chủ';
    }
    return exception.toString();
  }

  String _avatarInitials(String fullName) {
    final parts = fullName
        .trim()
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

class _HouseholdMemberDraft {
  final Resident resident;
  final String relationship;
  final String relationshipLabel;

  const _HouseholdMemberDraft({
    required this.resident,
    required this.relationship,
    required this.relationshipLabel,
  });
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF137FEC), size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF72839A),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
