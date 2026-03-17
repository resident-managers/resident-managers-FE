import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/graphql_client.dart';
import '../../graphql/mutations.dart';
import '../../models/health_insurance.dart';
import '../../models/social_insurance.dart';
import '../../models/temporary_residence.dart';
import '../../models/temporary_absence.dart';

// ─── shared helpers ───────────────────────────────────────────────────────────

InputDecoration _inputDec(String hint, {String? label}) => InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF137fec))),
    );

Widget _fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
    );

Future<DateTime?> _pickDate(BuildContext context, {DateTime? initial}) =>
    showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

String _fmt(DateTime? d) => d == null ? '' : DateFormat('yyyy-MM-dd').format(d);
String _fmtDisplay(DateTime? d) => d == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(d);

Widget _dateTile(BuildContext context, String label, DateTime? value, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(_fmtDisplay(value), style: TextStyle(fontSize: 14, color: value == null ? const Color(0xFF94A3B8) : const Color(0xFF0F172A)))),
            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );

Widget _saveButton(String label, bool saving, VoidCallback onPressed) => ElevatedButton(
      onPressed: saving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF137fec),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: saving
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );

// ─── Health Insurance ─────────────────────────────────────────────────────────

Future<bool?> showHealthInsuranceForm(
  BuildContext context, {
  required String residentId,
  HealthInsurance? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _HealthInsuranceForm(residentId: residentId, existing: existing),
  );
}

class _HealthInsuranceForm extends StatefulWidget {
  final String residentId;
  final HealthInsurance? existing;
  const _HealthInsuranceForm({required this.residentId, this.existing});

  @override
  State<_HealthInsuranceForm> createState() => _HealthInsuranceFormState();
}

class _HealthInsuranceFormState extends State<_HealthInsuranceForm> {
  final _codeCtrl = TextEditingController();
  final _facilityCtrl = TextEditingController();
  DateTime? _issuedDate;
  DateTime? _expiryDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _codeCtrl.text = widget.existing!.code;
      _facilityCtrl.text = widget.existing!.healthcareFacility ?? '';
      _issuedDate = widget.existing!.issuedDate;
      _expiryDate = widget.existing!.expiryDate;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _facilityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(isEdit ? 'Sửa bảo hiểm y tế' : 'Thêm bảo hiểm y tế', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 4),
          _fieldLabel('Mã BHYT *'),
          TextField(controller: _codeCtrl, decoration: _inputDec('VD: DN4012000123456789')),
          _fieldLabel('Nơi đăng ký KCB'),
          TextField(controller: _facilityCtrl, decoration: _inputDec('VD: BV Đa khoa tỉnh...')),
          _fieldLabel('Ngày cấp'),
          _dateTile(context, 'Ngày cấp', _issuedDate, () async {
            final d = await _pickDate(context, initial: _issuedDate);
            if (d != null) setState(() => _issuedDate = d);
          }),
          _fieldLabel('Ngày hết hạn'),
          _dateTile(context, 'Ngày hết hạn', _expiryDate, () async {
            final d = await _pickDate(context, initial: _expiryDate);
            if (d != null) setState(() => _expiryDate = d);
          }),
          const SizedBox(height: 20),
          _saveButton(isEdit ? 'Lưu thay đổi' : 'Thêm mới', _saving, _save),
        ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_codeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã BHYT không được để trống')));
      return;
    }
    setState(() => _saving = true);
    final client = GraphQLConfig.client.value;
    final isEdit = widget.existing != null;
    final input = {
      if (isEdit) 'id': widget.existing!.id,
      if (!isEdit) 'residentId': widget.residentId,
      'code': _codeCtrl.text.trim(),
      if (_facilityCtrl.text.trim().isNotEmpty) 'healthcareFacility': _facilityCtrl.text.trim(),
      if (_issuedDate != null) 'issuedDate': _fmt(_issuedDate),
      if (_expiryDate != null) 'expiryDate': _fmt(_expiryDate),
    };
    final result = await client.mutate(MutationOptions(
      document: gql(isEdit ? updateHealthInsuranceMutation : createHealthInsuranceMutation),
      variables: {'input': input},
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.exception!.graphqlErrors.firstOrNull?.message ?? result.exception.toString())));
      return;
    }
    Navigator.pop(context, true);
  }
}

// ─── Social Insurance ─────────────────────────────────────────────────────────

Future<bool?> showSocialInsuranceForm(
  BuildContext context, {
  required String residentId,
  SocialInsurance? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _SocialInsuranceForm(residentId: residentId, existing: existing),
  );
}

class _SocialInsuranceForm extends StatefulWidget {
  final String residentId;
  final SocialInsurance? existing;
  const _SocialInsuranceForm({required this.residentId, this.existing});

  @override
  State<_SocialInsuranceForm> createState() => _SocialInsuranceFormState();
}

class _SocialInsuranceFormState extends State<_SocialInsuranceForm> {
  final _codeCtrl = TextEditingController();
  final _employerCtrl = TextEditingController();
  DateTime? _enrolledDate;
  String _insuranceType = 'COMPULSORY';
  String _status = 'ACTIVE';
  bool _saving = false;

  final _types = [
    {'value': 'COMPULSORY', 'label': 'Bắt buộc'},
    {'value': 'VOLUNTARY', 'label': 'Tự nguyện'},
  ];
  final _statuses = [
    {'value': 'ACTIVE', 'label': 'Đang tham gia'},
    {'value': 'RESERVED', 'label': 'Bảo lưu'},
    {'value': 'PENSION', 'label': 'Hưu trí'},
    {'value': 'STOPPED', 'label': 'Dừng đóng'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _codeCtrl.text = widget.existing!.code;
      _employerCtrl.text = widget.existing!.employer ?? '';
      _enrolledDate = widget.existing!.enrolledDate;
      _insuranceType = widget.existing!.insuranceType ?? 'COMPULSORY';
      _status = widget.existing!.status ?? 'ACTIVE';
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _employerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(isEdit ? 'Sửa bảo hiểm xã hội' : 'Thêm bảo hiểm xã hội', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 4),
            _fieldLabel('Mã BHXH *'),
            TextField(controller: _codeCtrl, decoration: _inputDec('VD: 0100234567')),
            _fieldLabel('Đơn vị công tác'),
            TextField(controller: _employerCtrl, decoration: _inputDec('Tên công ty / cơ quan...')),
            _fieldLabel('Ngày tham gia'),
            _dateTile(context, 'Ngày tham gia', _enrolledDate, () async {
              final d = await _pickDate(context, initial: _enrolledDate);
              if (d != null) setState(() => _enrolledDate = d);
            }),
            _fieldLabel('Loại bảo hiểm'),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _insuranceType,
              decoration: _inputDec(''),
              items: _types.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
              onChanged: (v) { if (v != null) setState(() => _insuranceType = v); },
            ),
            _fieldLabel('Trạng thái'),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _status,
              decoration: _inputDec(''),
              items: _statuses.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
              onChanged: (v) { if (v != null) setState(() => _status = v); },
            ),
            const SizedBox(height: 20),
            _saveButton(isEdit ? 'Lưu thay đổi' : 'Thêm mới', _saving, _save),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_codeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã BHXH không được để trống')));
      return;
    }
    setState(() => _saving = true);
    final client = GraphQLConfig.client.value;
    final isEdit = widget.existing != null;
    final input = {
      if (isEdit) 'id': widget.existing!.id,
      if (!isEdit) 'residentId': widget.residentId,
      'code': _codeCtrl.text.trim(),
      if (_employerCtrl.text.trim().isNotEmpty) 'employer': _employerCtrl.text.trim(),
      if (_enrolledDate != null) 'enrolledDate': _fmt(_enrolledDate),
      'insuranceType': _insuranceType,
      'status': _status,
    };
    final result = await client.mutate(MutationOptions(
      document: gql(isEdit ? updateSocialInsuranceMutation : createSocialInsuranceMutation),
      variables: {'input': input},
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.exception!.graphqlErrors.firstOrNull?.message ?? result.exception.toString())));
      return;
    }
    Navigator.pop(context, true);
  }
}

// ─── Temporary Residence ─────────────────────────────────────────────────────

Future<bool?> showTemporaryResidenceForm(
  BuildContext context, {
  required String residentId,
  TemporaryResidence? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _TemporaryResidenceForm(residentId: residentId, existing: existing),
  );
}

class _TemporaryResidenceForm extends StatefulWidget {
  final String residentId;
  final TemporaryResidence? existing;
  const _TemporaryResidenceForm({required this.residentId, this.existing});

  @override
  State<_TemporaryResidenceForm> createState() => _TemporaryResidenceFormState();
}

class _TemporaryResidenceFormState extends State<_TemporaryResidenceForm> {
  final _addressCtrl = TextEditingController();
  final _hostCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _addressCtrl.text = widget.existing!.address;
      _hostCtrl.text = widget.existing!.hostName ?? '';
      _reasonCtrl.text = widget.existing!.reason ?? '';
      _fromDate = widget.existing!.fromDate;
      _toDate = widget.existing!.toDate;
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _hostCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(isEdit ? 'Sửa đăng ký tạm trú' : 'Thêm đăng ký tạm trú', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 4),
            _fieldLabel('Địa chỉ tạm trú *'),
            TextField(controller: _addressCtrl, maxLines: 2, decoration: _inputDec('Nhập địa chỉ tạm trú...')),
            _fieldLabel('Chủ nhà / chủ hộ'),
            TextField(controller: _hostCtrl, decoration: _inputDec('Tên chủ nhà...')),
            _fieldLabel('Từ ngày *'),
            _dateTile(context, 'Từ ngày', _fromDate, () async {
              final d = await _pickDate(context, initial: _fromDate);
              if (d != null) setState(() => _fromDate = d);
            }),
            _fieldLabel('Đến ngày'),
            _dateTile(context, 'Đến ngày', _toDate, () async {
              final d = await _pickDate(context, initial: _toDate);
              if (d != null) setState(() => _toDate = d);
            }),
            _fieldLabel('Lý do'),
            TextField(controller: _reasonCtrl, maxLines: 2, decoration: _inputDec('Lý do tạm trú...')),
            const SizedBox(height: 20),
            _saveButton(isEdit ? 'Lưu thay đổi' : 'Thêm mới', _saving, _save),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Địa chỉ không được để trống')));
      return;
    }
    if (_fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn từ ngày')));
      return;
    }
    setState(() => _saving = true);
    final client = GraphQLConfig.client.value;
    final isEdit = widget.existing != null;
    final input = {
      if (isEdit) 'id': widget.existing!.id,
      if (!isEdit) 'residentId': widget.residentId,
      'address': _addressCtrl.text.trim(),
      'fromDate': _fmt(_fromDate),
      if (_hostCtrl.text.trim().isNotEmpty) 'hostName': _hostCtrl.text.trim(),
      if (_toDate != null) 'toDate': _fmt(_toDate),
      if (_reasonCtrl.text.trim().isNotEmpty) 'reason': _reasonCtrl.text.trim(),
    };
    final result = await client.mutate(MutationOptions(
      document: gql(isEdit ? updateTemporaryResidenceMutation : createTemporaryResidenceMutation),
      variables: {'input': input},
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.exception!.graphqlErrors.firstOrNull?.message ?? result.exception.toString())));
      return;
    }
    Navigator.pop(context, true);
  }
}

// ─── Temporary Absence ───────────────────────────────────────────────────────

Future<bool?> showTemporaryAbsenceForm(
  BuildContext context, {
  required String residentId,
  TemporaryAbsence? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _TemporaryAbsenceForm(residentId: residentId, existing: existing),
  );
}

class _TemporaryAbsenceForm extends StatefulWidget {
  final String residentId;
  final TemporaryAbsence? existing;
  const _TemporaryAbsenceForm({required this.residentId, this.existing});

  @override
  State<_TemporaryAbsenceForm> createState() => _TemporaryAbsenceFormState();
}

class _TemporaryAbsenceFormState extends State<_TemporaryAbsenceForm> {
  final _destinationCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _destinationCtrl.text = widget.existing!.destination;
      _reasonCtrl.text = widget.existing!.reason ?? '';
      _fromDate = widget.existing!.fromDate;
      _toDate = widget.existing!.toDate;
    }
  }

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(isEdit ? 'Sửa đăng ký tạm vắng' : 'Thêm đăng ký tạm vắng', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 4),
            _fieldLabel('Nơi đến *'),
            TextField(controller: _destinationCtrl, decoration: _inputDec('Địa điểm đến...')),
            _fieldLabel('Từ ngày *'),
            _dateTile(context, 'Từ ngày', _fromDate, () async {
              final d = await _pickDate(context, initial: _fromDate);
              if (d != null) setState(() => _fromDate = d);
            }),
            _fieldLabel('Đến ngày'),
            _dateTile(context, 'Đến ngày', _toDate, () async {
              final d = await _pickDate(context, initial: _toDate);
              if (d != null) setState(() => _toDate = d);
            }),
            _fieldLabel('Lý do'),
            TextField(controller: _reasonCtrl, maxLines: 2, decoration: _inputDec('Lý do tạm vắng...')),
            const SizedBox(height: 20),
            _saveButton(isEdit ? 'Lưu thay đổi' : 'Thêm mới', _saving, _save),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_destinationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nơi đến không được để trống')));
      return;
    }
    if (_fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn từ ngày')));
      return;
    }
    setState(() => _saving = true);
    final client = GraphQLConfig.client.value;
    final isEdit = widget.existing != null;
    final input = {
      if (isEdit) 'id': widget.existing!.id,
      if (!isEdit) 'residentId': widget.residentId,
      'destination': _destinationCtrl.text.trim(),
      'fromDate': _fmt(_fromDate),
      if (_toDate != null) 'toDate': _fmt(_toDate),
      if (_reasonCtrl.text.trim().isNotEmpty) 'reason': _reasonCtrl.text.trim(),
    };
    final result = await client.mutate(MutationOptions(
      document: gql(isEdit ? updateTemporaryAbsenceMutation : createTemporaryAbsenceMutation),
      variables: {'input': input},
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.exception!.graphqlErrors.firstOrNull?.message ?? result.exception.toString())));
      return;
    }
    Navigator.pop(context, true);
  }
}

// ─── Delete helpers ───────────────────────────────────────────────────────────

Future<bool> confirmDelete(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: const Text('Bạn có chắc muốn xóa? Hành động này không thể hoàn tác.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Xóa', style: TextStyle(color: Color(0xFFEF4444))),
        ),
      ],
    ),
  );
  return result == true;
}

Future<bool> deleteRecord(BuildContext context, String mutation, String id) async {
  final client = GraphQLConfig.client.value;
  final result = await client.mutate(MutationOptions(
    document: gql(mutation),
    variables: {'id': id},
  ));
  if (result.hasException) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.exception!.graphqlErrors.firstOrNull?.message ?? result.exception.toString()),
      ));
    }
    return false;
  }
  return true;
}
