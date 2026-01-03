import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'message.dart';

part 'chat_response_model.g.dart';

@JsonSerializable()
class ChatResponseModel {
  List<Message>? messages;
  int? unreadCount;

  ChatResponseModel({this.messages, this.unreadCount});

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return _$ChatResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ChatResponseModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! ChatResponseModel) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => messages.hashCode ^ unreadCount.hashCode;
}
