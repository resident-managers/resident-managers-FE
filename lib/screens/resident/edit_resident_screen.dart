import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/graphql_client.dart';
import '../../graphql/mutations.dart';
import '../../models/resident.dart';

class EditResidentScreen extends StatefulWidget {
  final Resident resident;
  const EditResidentScreen({super.key, required this.resident});

  @override
  State<EditResidentScreen> createState() => _EditResidentScreenState();
}

class _EditResidentScreenState extends State<EditResidentScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _occupationController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _religionController = TextEditingController();
  final _educationController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedGender = 'MALE';
  String _selectedResidenceType = 'PERMANENT';
  bool _isSaving = false;

  final List<Map<String, String>> _residenceTypes = [
    {'value': 'PERMANENT', 'label': 'Thường trú'},
    {'value': 'TEMPORARY', 'label': 'Tạm trú'},
    {'value': 'ABSENT', 'label': 'Tạm vắng'},
    {'value': 'MOVED_OUT', 'label': 'Đã chuyển đi'},
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.resident;
    _nameController.text = r.fullName;
    _idController.text = r.identityCard ?? '';
    _phoneController.text = r.phone ?? '';
    _addressController.text = r.address ?? '';
    _permanentAddressController.text = r.permanentAddress ?? '';
    _occupationController.text = r.occupation ?? '';
    _ethnicityController.text = r.ethnicity ?? '';
    _religionController.text = r.religion ?? '';
    _educationController.text = r.educationLevel ?? '';
    _noteController.text = r.notes ?? '';
    _selectedDate = r.birthDate;
    _selectedGender = r.gender == Gender.nam ? 'MALE' : 'FEMALE';
    _selectedResidenceType = r.residenceType ?? 'PERMANENT';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _permanentAddressController.dispose();
    _occupationController.dispose();
    _ethnicityController.dispose();
    _religionController.dispose();
    _educationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
        title: const Text('Chỉnh sửa cư dân', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.blueGrey.shade50),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Danh tính'),
                  _fieldLabel('Họ và tên *'),
                  _textField(_nameController, 'Nhập họ và tên'),
                  const SizedBox(height: 16),
                  _fieldLabel('Căn cước công dân'),
                  _textField(_idController, 'Nhập số CCCD', prefixIcon: Icons.badge_outlined),
                  const SizedBox(height: 16),
                  _fieldLabel('Ngày sinh'),
                  _datePicker(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  _sectionHeader('Nhân khẩu học'),
                  _fieldLabel('Giới tính'),
                  _genderToggle(),
                  const SizedBox(height: 16),
                  _fieldLabel('Tình trạng cư trú'),
                  _residenceTypeDropdown(),
                  const SizedBox(height: 16),
                  _fieldLabel('Dân tộc'),
                  _textField(_ethnicityController, 'VD: Kinh, Tày...'),
                  const SizedBox(height: 16),
                  _fieldLabel('Tôn giáo'),
                  _textField(_religionController, 'VD: Không, Phật giáo...'),
                  const SizedBox(height: 16),
                  _fieldLabel('Trình độ học vấn'),
                  _textField(_educationController, 'VD: Đại học, THPT...'),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  _sectionHeader('Thông tin liên hệ'),
                  _fieldLabel('Số điện thoại'),
                  _textField(_phoneController, '(123) 456-7890', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _fieldLabel('Nghề nghiệp'),
                  _textField(_occupationController, 'Nhập nghề nghiệp'),
                  const SizedBox(height: 16),
                  _fieldLabel('Địa chỉ hiện tại'),
                  _textField(_addressController, 'Nhập địa chỉ hiện tại...', maxLines: 3),
                  const SizedBox(height: 16),
                  _fieldLabel('Địa chỉ thường trú'),
                  _textField(_permanentAddressController, 'Nhập địa chỉ thường trú...', maxLines: 3),
                  const SizedBox(height: 16),
                  _fieldLabel('Ghi chú'),
                  _textField(_noteController, 'Ghi chú thêm...', maxLines: 3),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _stickyFooter(),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF137fec), letterSpacing: 1.2)),
  );

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
  );

  Widget _textField(TextEditingController ctrl, String hint, {IconData? prefixIcon, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blueGrey.shade100)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blueGrey.shade100)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF137fec))),
      ),
    );
  }

  Widget _datePicker() => InkWell(
    onTap: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime(1990),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (date != null) setState(() => _selectedDate = date);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueGrey.shade100)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedDate == null ? 'Chọn ngày sinh' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
            style: TextStyle(color: _selectedDate == null ? const Color(0xFF94A3B8) : const Color(0xFF0F172A)),
          ),
          const Icon(Icons.calendar_today, color: Color(0xFF94A3B8), size: 20),
        ],
      ),
    ),
  );

  Widget _genderToggle() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: ['MALE', 'FEMALE'].map((g) {
        final isSelected = _selectedGender == g;
        return Expanded(
          child: InkWell(
            onTap: () => setState(() => _selectedGender = g),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))] : null,
              ),
              alignment: Alignment.center,
              child: Text(g == 'MALE' ? 'Nam' : 'Nữ', style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF137fec) : const Color(0xFF64748B))),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _residenceTypeDropdown() => DropdownButtonFormField<String>(
    // ignore: deprecated_member_use
    value: _selectedResidenceType,
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blueGrey.shade100)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blueGrey.shade100)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF137fec))),
    ),
    items: _residenceTypes.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
    onChanged: (v) { if (v != null) setState(() => _selectedResidenceType = v); },
  );

  Widget _stickyFooter() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.blueGrey.shade50))),
    child: ElevatedButton(
      onPressed: _isSaving ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF137fec),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: const Color(0xFF137fec).withValues(alpha: 0.4),
      ),
      child: _isSaving
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.save), SizedBox(width: 8), Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
    ),
  );

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Họ và tên không được để trống')));
      return;
    }
    setState(() => _isSaving = true);
    final client = GraphQLConfig.client.value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(updateResidentMutation),
        variables: {
          'id': widget.resident.id,
          'input': {
            'fullName': _nameController.text.trim(),
            'gender': _selectedGender,
            'dateOfBirth': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
            'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            'nationalId': _idController.text.trim().isEmpty ? null : _idController.text.trim(),
            'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            'permanentAddress': _permanentAddressController.text.trim().isEmpty ? null : _permanentAddressController.text.trim(),
            'occupation': _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim(),
            'ethnicity': _ethnicityController.text.trim().isEmpty ? null : _ethnicityController.text.trim(),
            'religion': _religionController.text.trim().isEmpty ? null : _religionController.text.trim(),
            'educationLevel': _educationController.text.trim().isEmpty ? null : _educationController.text.trim(),
            'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
            'residenceType': _selectedResidenceType,
          },
        },
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.exception.toString())));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
    context.pop(true);
  }
}
