import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/json_converters.dart';
import 'user_model.dart';

part 'group_model.g.dart';

// Member dalam grup (dari endpoint GET /groups/:id)
@JsonSerializable(explicitToJson: true)
class GroupMemberModel {
  @SafeIntConverter()
  final int id;

  @JsonKey(name: 'groupId')
  @SafeIntConverter()
  final int groupId;

  @JsonKey(name: 'userId')
  @SafeIntConverter()
  final int userId;

  @SafeStringConverter()
  final String role; // "admin" | "member"

  final UserModel? user;

  const GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    this.user,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupMemberModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GroupModel {
  @SafeIntConverter()
  final int id;

  @SafeGroupNameConverter()
  final String name;

  final String? description;

  // creator_id dari backend (flat) — dipakai di list endpoint
  @JsonKey(name: 'creatorId')
  @SafeIntConverter()
  final int creatorId;

  // creator object (nested) — dari detail endpoint
  final UserModel? creator;

  // List<GroupMemberModel> dari detail endpoint, null di list endpoint
  final List<GroupMemberModel>? members;

  @JsonKey(name: 'createdAt')
  @SafeDateTimeConverter()
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.creatorId,
    this.creator,
    this.members,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);
}
