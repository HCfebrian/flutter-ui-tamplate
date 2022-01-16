import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? name;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.photoUrl,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? photoUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        photoUrl,
      ];
}
