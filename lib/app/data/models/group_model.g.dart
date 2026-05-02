// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMemberModel _$GroupMemberModelFromJson(Map<String, dynamic> json) =>
    GroupMemberModel(
      id: const SafeIntConverter().fromJson(json['id']),
      groupId: const SafeIntConverter().fromJson(json['groupId']),
      userId: const SafeIntConverter().fromJson(json['userId']),
      role: const SafeStringConverter().fromJson(json['role']),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupMemberModelToJson(GroupMemberModel instance) =>
    <String, dynamic>{
      'id': const SafeIntConverter().toJson(instance.id),
      'groupId': const SafeIntConverter().toJson(instance.groupId),
      'userId': const SafeIntConverter().toJson(instance.userId),
      'role': const SafeStringConverter().toJson(instance.role),
      'user': instance.user?.toJson(),
    };

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
  id: const SafeIntConverter().fromJson(json['id']),
  name: const SafeGroupNameConverter().fromJson(json['name']),
  description: json['description'] as String?,
  creatorId: const SafeIntConverter().fromJson(json['creatorId']),
  creator: json['creator'] == null
      ? null
      : UserModel.fromJson(json['creator'] as Map<String, dynamic>),
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => GroupMemberModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: const SafeDateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': const SafeIntConverter().toJson(instance.id),
      'name': const SafeGroupNameConverter().toJson(instance.name),
      'description': instance.description,
      'creatorId': const SafeIntConverter().toJson(instance.creatorId),
      'creator': instance.creator?.toJson(),
      'members': instance.members?.map((e) => e.toJson()).toList(),
      'createdAt': const SafeDateTimeConverter().toJson(instance.createdAt),
    };
