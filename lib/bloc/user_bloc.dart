import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../domain/repository/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUsers>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await repository.getAllUsers();
        emit(UserLoaded(users));
      } catch (e) {
        emit(UserError("Gagal memuat data"));
      }
    });

    on<AddUserEvent>((event, emit) async {
      await repository.addUser(event.user);
      add(LoadUsers());
    });

    on<UpdateUserEvent>((event, emit) async {
      await repository.updateUser(event.user);
      add(LoadUsers());
    });

    on<DeleteUserEvent>((event, emit) async {
      await repository.deleteUser(event.id);
      add(LoadUsers());
    });
  }
}