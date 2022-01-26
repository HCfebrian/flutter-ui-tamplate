import 'package:equatable/equatable.dart';

enum Role { admin, agent, moderator, user }

class UserEntity extends Equatable {
  /// Created user timestamp, in ms
  final int? createdAt;

  /// First name of the user
  final String firstName;

  /// Unique ID of the user
  final String id;

  /// Remote image URL representing user's avatar
  final String imageUrl;

  /// Last name of the user
  final String? lastName;

  /// Timestamp when user was last visible, in ms
  final int? lastSeen;

  /// Additional custom metadata or attributes related to the user
  final Map<String, dynamic>? metadata;

  /// User [Role]
  final Role? role;

  /// Updated user timestamp, in ms
  final int? updatedAt;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.imageUrl,
    this.createdAt,
    this.lastName,
    this.lastSeen,
    this.metadata,
    this.role,
    this.updatedAt,
  });

  UserEntity copyWith({
    String? id,
    int? createdAt,
    String? firstName,
    String? imageUrl,
    String? lastName,
    int? lastSeen,
    Map<String, dynamic>? metadata,
    Role? role,
    int? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      imageUrl: imageUrl ?? this.imageUrl,
      lastName: lastName ?? this.lastName,
      lastSeen: lastSeen ?? this.lastSeen,
      metadata: metadata ?? this.metadata,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        firstName,
        imageUrl,
        lastName,
        lastSeen,
        metadata,
        role,
        updatedAt,
      ];
}
