part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserGetDataEvent extends UserEvent {}

class UserStataeStreamInitEvent extends UserEvent {}

class _UserGetUpdatedEvent extends UserEvent {
  final UserEntity? userEntity;

  const _UserGetUpdatedEvent(this.userEntity);

  @override
  List<Object?> get props => [userEntity];
}

class UserLoggedOutEvent extends UserEvent {}
