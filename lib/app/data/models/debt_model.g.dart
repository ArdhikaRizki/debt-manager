// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtModel _$DebtModelFromJson(Map<String, dynamic> json) => DebtModel(
  id: const SafeIntConverter().fromJson(json['id']),
  userId: const SafeIntConverter().fromJson(json['userId']),
  otherUserId: const SafeIntConverter().fromJson(json['otherUserId']),
  counterpartId: const SafeIntConverter().fromJson(json['counterpartId']),
  amount: const SafeNumConverter().fromJson(json['amount']),
  description: const SafeStringConverter().fromJson(json['description']),
  status: const SafeStatusConverter().fromJson(json['status']),
  isPaid: json['is_paid'] as bool? ?? false,
  dueDate: json['due_date'] as String?,
  groupId: (json['group_id'] as num?)?.toInt(),
  createdAt: const SafeDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const SafeDateTimeConverter().fromJson(json['updatedAt']),
  owner: json['owner'] == null
      ? null
      : UserModel.fromJson(json['owner'] as Map<String, dynamic>),
  otherUser: json['otherUser'] == null
      ? null
      : UserModel.fromJson(json['otherUser'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DebtModelToJson(DebtModel instance) => <String, dynamic>{
  'id': const SafeIntConverter().toJson(instance.id),
  'userId': const SafeIntConverter().toJson(instance.userId),
  'otherUserId': const SafeIntConverter().toJson(instance.otherUserId),
  'counterpartId': _$JsonConverterToJson<dynamic, int>(
    instance.counterpartId,
    const SafeIntConverter().toJson,
  ),
  'amount': const SafeNumConverter().toJson(instance.amount),
  'description': const SafeStringConverter().toJson(instance.description),
  'status': const SafeStatusConverter().toJson(instance.status),
  'is_paid': instance.isPaid,
  'due_date': instance.dueDate,
  'group_id': instance.groupId,
  'createdAt': const SafeDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const SafeDateTimeConverter().toJson(instance.updatedAt),
  'owner': instance.owner?.toJson(),
  'otherUser': instance.otherUser?.toJson(),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
