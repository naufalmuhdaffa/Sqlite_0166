import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';

class UserFormPage extends StatefulWidget {
  final UserEntity? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTelponController = TextEditingController();
  final _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _noTelponController.text = _extractPhoneNumberInput(widget.user!.noTelpon);
      _alamatController.text = widget.user!.alamat;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _noTelponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  String _extractPhoneNumberInput(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62')) {
      return digits.substring(2);
    }
    return digits;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final requiredError = _validateRequired(value, 'Email');
    if (requiredError != null) {
      return requiredError;
    }

    final email = value!.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format email belum valid';
    }
    return null;
  }

  String? _validateName(String? value) {
    final requiredError = _validateRequired(value, 'Nama Lengkap');
    if (requiredError != null) {
      return requiredError;
    }

    final name = value!.trim();
    final nameRegex = RegExp(r"^[A-Za-z .'-]+$");
    if (!nameRegex.hasMatch(name)) {
      return 'Nama hanya boleh berisi huruf, spasi, titik, petik satu, dan tanda hubung';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    final requiredError = _validateRequired(value, 'Alamat');
    if (requiredError != null) {
      return requiredError;
    }

    final address = value!.trim();
    final addressRegex = RegExp(r'^[A-Za-z0-9 ./,#()\n-]+$');
    if (!addressRegex.hasMatch(address)) {
      return 'Alamat hanya boleh berisi huruf, angka, spasi, titik, koma, garis miring, tanda pagar, kurung, dan tanda hubung';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final requiredError = _validateRequired(value, 'No Telpon');
    if (requiredError != null) {
      return requiredError;
    }

    final phone = value!.trim();
    if (!phone.startsWith('8')) {
      return 'No Telpon harus diawali angka 8';
    }
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'No Telpon hanya boleh berisi angka';
    }
    if ('+62$phone'.length > 15) {
      return 'No Telpon tidak boleh lebih dari 15 karakter';
    }
    return null;
  }

  Future<void> _saveUser(BuildContext context, bool isEdit) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final normalizedPhone = '+62${_noTelponController.text.trim()}';

    try {
      final parsedPhone = await parse(normalizedPhone, region: 'ID');
      if (parsedPhone['region_code'] != 'ID') {
        throw Exception('Nomor bukan Indonesia');
      }

      final newUser = UserEntity(
        id: isEdit ? widget.user!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        noTelpon: parsedPhone['e164'] as String? ?? normalizedPhone,
        alamat: _alamatController.text.trim(),
      );

      if (!mounted) return;

      if (isEdit) {
        context.read<UserBloc>().add(UpdateUserEvent(newUser));
      } else {
        context.read<UserBloc>().add(AddUserEvent(newUser));
      }

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Telpon belum valid. Gunakan format nomor Indonesia seperti +628123456789.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit User" : "Tambah User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z .'-]")),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap",
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _noTelponController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _PhoneNumberInputFormatter(),
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: const InputDecoration(
                    labelText: "No Telpon",
                    prefixText: "+62 ",
                    hintText: "8123456789",
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePhoneNumber,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _alamatController,
                  maxLines: 3,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9 ./,#()\n-]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Alamat",
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: _validateAddress,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _saveUser(context, isEdit),
                    child: Text(isEdit ? "Simpan Perubahan" : "Simpan User Baru"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    if (!text.startsWith('8')) {
      return oldValue;
    }

    return newValue;
  }
}
