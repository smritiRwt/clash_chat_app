import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'receiver.g.dart';

@JsonSerializable()
class Receiver {
  @JsonKey(name: '_id')
  String? id;
  String? username;
  String? avatar;

  Receiver({this.id, this.username, this.avatar});

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return _$ReceiverFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReceiverToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Receiver) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ avatar.hashCode;
}
