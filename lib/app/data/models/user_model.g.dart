// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: const SafeIntConverter().fromJson(json['id']),
  email: const SafeStringConverter().fromJson(json['email']),
  username: const SafeUsernameConverter().fromJson(json['username']),
  photoPath: json['photo_path'] as String?,
  isVerified: json['is_verified'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': const SafeIntConverter().toJson(instance.id),
  'email': const SafeStringConverter().toJson(instance.email),
  'username': const SafeUsernameConverter().toJson(instance.username),
  'photo_path': instance.photoPath,
  'is_verified': instance.isVerified,
};
