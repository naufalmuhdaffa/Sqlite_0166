import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit User" : "Tambah User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final newUser = UserEntity(
                    id: isEdit ? widget.user!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    email: _emailController.text,
                  );

                  if (isEdit) {
                    context.read<UserBloc>().add(UpdateUserEvent(newUser));
                  } else {
                    context.read<UserBloc>().add(AddUserEvent(newUser));
                  }

                  Navigator.pop(context);
                },
                child: Text(isEdit ? "Simpan Perubahan" : "Simpan User Baru"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}