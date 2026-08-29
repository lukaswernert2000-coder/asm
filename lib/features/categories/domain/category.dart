import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String slug,
    required String name,
    required int sortOrder,
    @JsonKey(name: 'requires_age_18') required bool requiresAge18,
    required bool requiresFMarking,
    required bool requiresJoule,
    required bool requiresPropulsion,
    required bool isActive,
    String? parentId,
    String? icon,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
