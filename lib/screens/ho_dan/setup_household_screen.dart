import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SetupHouseholdScreen extends StatefulWidget {
  const SetupHouseholdScreen({super.key});

  @override
  State<SetupHouseholdScreen> createState() => _SetupHouseholdScreenState();
}

class _SetupHouseholdScreenState extends State<SetupHouseholdScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedHead;
  final List<Map<String, dynamic>> _members = [
    {'name': 'Jane Doe', 'id': '839202', 'relation': 'Wife', 'initials': 'JD'},
    {'name': 'Timmy Doe', 'id': '839205', 'relation': 'Son', 'initials': 'TD'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
        title: const Text('Setup Household', style: TextStyle(fontWeight: .bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: (_selectedHead != null || _members.isNotEmpty) ? () {} : null,
            child: const Text('Save', style: TextStyle(fontWeight: .bold, fontSize: 16)),
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.blueGrey.shade50),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeadSection(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(),
            ),
            _buildMembersSection(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(),
            ),
            _buildSummarySection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Widget _buildHeadSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_pin, color: Color(0xFF137fec), size: 20),
              SizedBox(width: 8),
              Text('HEAD OF HOUSEHOLD', style: TextStyle(fontSize: 12, fontWeight: .bold, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            readOnly: true,
            onTap: () {
              // Simulate selection for demo
              setState(() {
                _selectedHead = {'name': 'Robert Fox', 'id': '839201', 'age': 45};
              });
            },
            decoration: InputDecoration(
              hintText: 'Search resident by name or ID...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              suffixIcon: const Icon(Icons.expand_more, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey.shade100),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedHead != null)
            _buildSelectedHeadCard()
          else
            _buildEmptyHeadPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildSelectedHeadCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF137fec).withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: Color(0xFF137fec)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(_selectedHead!['name'], style: const TextStyle(fontWeight: .bold, fontSize: 16)),
                Text('ID: #${_selectedHead!['id']} • Age: ${_selectedHead!['age']}', 
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF137fec).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Head', style: TextStyle(fontSize: 12, fontWeight: .bold, color: Color(0xFF137fec))),
          ),
          IconButton(
            onPressed: () => setState(() => _selectedHead = null),
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHeadPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blueGrey.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.person_off, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 8),
          const Text('No Head Selected', style: TextStyle(fontWeight: .bold, fontSize: 14)),
          const Text('Select a resident above to assign them as the head.', 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.diversity_3, color: Color(0xFF137fec), size: 20),
                  SizedBox(width: 8),
                  Text('FAMILY MEMBERS', style: TextStyle(fontSize: 12, fontWeight: .bold, color: Color(0xFF64748B))),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle, size: 18),
                label: const Text('Add Member'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._members.map((m) => _buildMemberItem(m)),
          _buildAddPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEEF2FF),
            child: Text(member['initials'], style: const TextStyle(fontSize: 12, fontWeight: .bold, color: Color(0xFF4F46E5))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(member['name'], style: const TextStyle(fontWeight: .bold, fontSize: 14)),
                Text('ID: #${member['id']} • ${member['relation']}', 
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(Icons.add, color: Color(0xFF94A3B8), size: 18),
          ),
          SizedBox(width: 12),
          Text('Add another member...', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: Color(0xFF137fec), size: 20),
              SizedBox(width: 8),
              Text('HOUSEHOLD SUMMARY', style: TextStyle(fontSize: 12, fontWeight: .bold, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    const Text('Total Residents', style: TextStyle(fontWeight: .w500, fontSize: 14)),
                    Text('${(_selectedHead != null ? 1 : 0) + _members.length}', 
                        style: const TextStyle(fontWeight: .bold, fontSize: 18)),
                  ],
                ),
                const Divider(height: 24, thickness: 1, color: Colors.white),
                _buildSummaryRow('Head', _selectedHead != null ? 1 : 0, const Color(0xFF137fec)),
                const SizedBox(height: 8),
                _buildSummaryRow('Members', _members.length, const Color(0xFF6366F1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        Text('$count', style: const TextStyle(fontSize: 12, fontWeight: .bold)),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: Colors.blueGrey.shade50)),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF137fec),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: const Color(0xFF137fec).withValues(alpha: 0.4),
        ),
        child: const Row(
          mainAxisAlignment: .center,
          children: [
            Icon(Icons.check),
            SizedBox(width: 8),
            Text('Create Household', style: TextStyle(fontSize: 16, fontWeight: .bold)),
          ],
        ),
      ),
    );
  }
}
