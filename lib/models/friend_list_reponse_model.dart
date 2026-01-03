import 'package:chat_app/models/friend_model_new.dart';
import 'package:chat_app/models/pagination_model.dart';

class FriendListResponseModel {
  final List<FriendModel> data;
  final PaginationModel pagination;

  FriendListResponseModel({required this.data, required this.pagination});

  factory FriendListResponseModel.fromJson(Map<String, dynamic> json) {
    return FriendListResponseModel(
      data: json['data'] != null
          ? List<FriendModel>.from(
              json['data'].map((x) => FriendModel.fromJson(x)),
            )
          : [],
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
