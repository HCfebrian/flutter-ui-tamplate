part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => <Object?>[];
}

class UserInitial extends UserState {
  @override
  List<Object> get props => [];
}

class UserLoadingState extends UserState {}

class UserLoggedOutState extends UserState {}

class UserLoggedInState extends UserState {
  final UserEntity userEntity;

  const UserLoggedInState({required this.userEntity});

  @override
  List<Object?> get props => [userEntity];
}
