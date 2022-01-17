import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String senderId;
  final String receiverId;
  final String type;
  final String message;
  final DateTime timestamp;
  final String? photoUrl;

  const MessageEntity({
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.message,
    required this.timestamp,
    this.photoUrl,
  });

  const MessageEntity.imageMessage({
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [
        senderId,
        receiverId,
        type,
        message,
        timestamp,
        photoUrl,
      ];
}
