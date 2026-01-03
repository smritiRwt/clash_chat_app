import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sender.g.dart';

@JsonSerializable()
class Sender {
  @JsonKey(name: '_id')
  String? id;
  String? username;
  String? avatar;

  Sender({this.id, this.username, this.avatar});

  factory Sender.fromJson(Map<String, dynamic> json) {
    return _$SenderFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SenderToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Sender) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ avatar.hashCode;
}
