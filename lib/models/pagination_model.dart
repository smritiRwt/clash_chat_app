/// Pagination Model
/// Represents pagination information from API responses
class PaginationModel {
  final int page;
  final int limit;
  final int offset;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.offset,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  /// Create PaginationModel from JSON
  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPrevPage: json['hasPrevPage'] as bool,
    );
  }

  /// Convert PaginationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'offset': offset,
      'total': total,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}
