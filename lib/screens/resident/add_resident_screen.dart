import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/graphql_client.dart';
import '../../graphql/mutations.dart';

class AddResidentScreen extends StatefulWidget {
  const AddResidentScreen({super.key});

  @override
  State<AddResidentScreen> createState() => _AddResidentScreenState();
}

class _AddResidentScreenState extends State<AddResidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _occupationController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _religionController = TextEditingController();
  final _educationController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedGender = 'Nam';
  String _selectedResidenceType = 'PERMANENT';
  bool _isSaving = false;

  final List<Map<String, String>> _residenceTypes = [
    {'value': 'PERMANENT', 'label': 'Thường trú'},
    {'value': 'TEMPORARY', 'label': 'Tạm trú'},
    {'value': 'ABSENT', 'label': 'Tạm vắng'},
    {'value': 'MOVED_OUT', 'label': 'Đã chuyển đi'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: const Text(
          'Thêm cư dân mới',
          style: TextStyle(fontWeight: .bold, fontSize: 18),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    _buildSectionHeader('Danh tính'),
                    _buildFieldLabel('Họ và tên'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Nhập họ và tên',
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Căn cước công dân'),
                    _buildTextField(
                      controller: _idController,
                      hint: 'Nhập số CCCD',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Ngày sinh'),
                    _buildDatePicker(),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Nhân khẩu học'),
                    _buildFieldLabel('Giới tính'),
                    _buildGenderSelection(),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Tình trạng cư trú'),
                    _buildResidenceTypeDropdown(),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Dân tộc'),
                    _buildTextField(
                      controller: _ethnicityController,
                      hint: 'VD: Kinh, Tày...',
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Tôn giáo'),
                    _buildTextField(
                      controller: _religionController,
                      hint: 'VD: Không, Phật giáo...',
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Trình độ học vấn'),
                    _buildTextField(
                      controller: _educationController,
                      hint: 'VD: Đại học, THPT...',
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Thông tin liên hệ'),
                    _buildFieldLabel('Số điện thoại'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '(123) 456-7890',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Nghề nghiệp'),
                    _buildTextField(
                      controller: _occupationController,
                      hint: 'Nhập nghề nghiệp',
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Địa chỉ hiện tại'),
                    _buildTextField(
                      controller: _addressController,
                      hint: 'Nhập địa chỉ hiện tại...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 100), // Space for sticky button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildStickyFooter(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: .bold,
          color: Color(0xFF137fec),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: .w500,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF137fec)),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueGrey.shade100),
        ),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? 'Chọn ngày sinh'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              style: TextStyle(
                color: _selectedDate == null
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF0F172A),
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildGenderOption('Nam'),
          _buildGenderOption('Nữ'),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF137fec)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResidenceTypeDropdown() {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: _selectedResidenceType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF137fec)),
        ),
      ),
      items: _residenceTypes
          .map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedResidenceType = v);
      },
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: Colors.blueGrey.shade50)),
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveResident,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF137fec),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF137fec).withValues(alpha: 0.4),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: .center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text(
                    'Lưu thông tin',
                    style: TextStyle(fontSize: 16, fontWeight: .bold),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveResident() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Họ và tên không được để trống')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final client = GraphQLConfig.client.value;

    final gender = switch (_selectedGender) {
      'Nam' => 'MALE',
      'Nữ' => 'FEMALE',
      _ => 'MALE',
    };

    final result = await client.mutate(
      MutationOptions(
        document: gql(createResidentMutation),
        variables: {
          'input': {
            'fullName': _nameController.text.trim(),
            'gender': gender,
            'dateOfBirth': _selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                : null,
            'phone': _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            'nationalId': _idController.text.trim().isEmpty
                ? null
                : _idController.text.trim(),
            'address': _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            'occupation': _occupationController.text.trim().isEmpty
                ? null
                : _occupationController.text.trim(),
            'ethnicity': _ethnicityController.text.trim().isEmpty
                ? null
                : _ethnicityController.text.trim(),
            'religion': _religionController.text.trim().isEmpty
                ? null
                : _religionController.text.trim(),
            'educationLevel': _educationController.text.trim().isEmpty
                ? null
                : _educationController.text.trim(),
            'residenceType': _selectedResidenceType,
          },
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (result.hasException) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.exception.toString())));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Thêm thông tin thành công')));
    context.pop(true);
  }
}
