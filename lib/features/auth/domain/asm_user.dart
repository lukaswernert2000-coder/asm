import 'package:freezed_annotation/freezed_annotation.dart';

part 'asm_user.freezed.dart';

@freezed
abstract class AsmUser with _$AsmUser {
  const factory AsmUser({
    required String id,
    required String email,
    required bool emailConfirmed,
  }) = _AsmUser;
}
