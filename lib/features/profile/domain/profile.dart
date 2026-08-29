import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

enum UserRole { user, moderator }

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String username,
    required bool isCommercial,
    required UserRole role,
    required DateTime createdAt,
    required DateTime lastSeenAt,
    String? displayName,
    String? avatarPath,
    String? bio,
    String? postalCode,
    String? city,
    String? commercialName,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
