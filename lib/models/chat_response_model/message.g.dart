// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['_id'] as String?,
  sender: json['sender'] == null
      ? null
      : Sender.fromJson(json['sender'] as Map<String, dynamic>),
  receiver: json['receiver'] == null
      ? null
      : Receiver.fromJson(json['receiver'] as Map<String, dynamic>),
  content: json['content'] as String?,
  messageType: json['messageType'] as String?,
  status: json['status'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  '_id': instance.id,
  'sender': instance.sender,
  'receiver': instance.receiver,
  'content': instance.content,
  'messageType': instance.messageType,
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
};
