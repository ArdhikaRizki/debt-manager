import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/json_converters.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  @SafeIntConverter()
  final int id;

  @SafeStringConverter()
  final String email;

  @SafeUsernameConverter()
  final String username;

  final String? photoPath;
  final String? isVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.photoPath,
    this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
