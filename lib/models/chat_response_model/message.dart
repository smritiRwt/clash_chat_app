import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'receiver.dart';
import 'sender.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  @JsonKey(name: '_id')
  String? id;
  Sender? sender;
  Receiver? receiver;
  String? content;
  String? messageType;
  String? status;
  DateTime? createdAt;

  Message({
    this.id,
    this.sender,
    this.receiver,
    this.content,
    this.messageType,
    this.status,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return _$MessageFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Message) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      id.hashCode ^
      sender.hashCode ^
      receiver.hashCode ^
      content.hashCode ^
      messageType.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
}
