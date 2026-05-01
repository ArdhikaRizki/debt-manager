import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/json_converters.dart';
import 'user_model.dart';
part 'debt_model.g.dart';

// fieldRename: none — kita kelola key JSON secara manual via @JsonKey
@JsonSerializable(explicitToJson: true)
class DebtModel {
  @SafeIntConverter()
  final int id;

  // Pemilik debt (yang membuat)
  @JsonKey(name: 'userId')
  @SafeIntConverter()
  final int userId;

  // Pihak lawan (yang dikonfirmasi)
  @JsonKey(name: 'otherUserId')
  @SafeIntConverter()
  final int otherUserId;

  // ID debt cermin (dibuat saat konfirmasi), opsional
  @JsonKey(name: 'counterpartId')
  @SafeIntConverter()
  final int? counterpartId;

  @SafeNumConverter()
  final double amount;

  @SafeStringConverter()
  final String description;

  @SafeStatusConverter()
  final String status;

  @JsonKey(name: 'is_paid')
  final bool isPaid;

  // null jika tidak ada due date
  @JsonKey(name: 'due_date')
  final String? dueDate;

  @JsonKey(name: 'group_id')
  final int? groupId;

  @JsonKey(name: 'createdAt')
  @SafeDateTimeConverter()
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  @SafeDateTimeConverter()
  final DateTime updatedAt;

  // Nested user objects dari backend
  final UserModel? owner;       // pemilik debt (userId)
  final UserModel? otherUser;   // pihak lawan (otherUserId)

  const DebtModel({
    required this.id,
    required this.userId,
    required this.otherUserId,
    this.counterpartId,
    required this.amount,
    required this.description,
    required this.status,
    this.isPaid = false,
    this.dueDate,
    this.groupId,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
    this.otherUser,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) =>
      _$DebtModelFromJson(json);

  Map<String, dynamic> toJson() => _$DebtModelToJson(this);
}
