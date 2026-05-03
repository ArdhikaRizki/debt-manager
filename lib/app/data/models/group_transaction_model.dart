import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/json_converters.dart';
import 'user_model.dart';

part 'group_transaction_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GroupTransactionModel {
  @SafeIntConverter()
  final int id;

  @JsonKey(name: 'groupId')
  @SafeIntConverter()
  final int groupId;

  @JsonKey(name: 'fromUserId')
  @SafeIntConverter()
  final int fromUserId;

  @JsonKey(name: 'toUserId')
  @SafeIntConverter()
  final int toUserId;

  @SafeNumConverter()
  final double amount;

  @SafeStringConverter()
  final String description;

  // Nested objects dari backend (include User)
  final UserModel? fromUser;
  final UserModel? toUser;

  @JsonKey(name: 'createdAt')
  @SafeDateTimeConverter()
  final DateTime createdAt;

  const GroupTransactionModel({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.description,
    this.fromUser,
    this.toUser,
    required this.createdAt,
  });

  factory GroupTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$GroupTransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupTransactionModelToJson(this);
}
