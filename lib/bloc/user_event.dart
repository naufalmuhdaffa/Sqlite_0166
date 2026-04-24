import '../../domain/entities/user_entity.dart';

abstract class UserEvent {}
class LoadUsers extends UserEvent {}
class AddUserEvent extends UserEvent {
  final UserEntity user;
  AddUserEvent(this.user);
}
class DeleteUserEvent extends UserEvent {
  final String id;
  DeleteUserEvent(this.id);
}
class UpdateUserEvent extends UserEvent {
  final UserEntity user;
  UpdateUserEvent(this.user);
}