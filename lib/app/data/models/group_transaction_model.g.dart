// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupTransactionModel _$GroupTransactionModelFromJson(
  Map<String, dynamic> json,
) => GroupTransactionModel(
  id: const SafeIntConverter().fromJson(json['id']),
  groupId: const SafeIntConverter().fromJson(json['groupId']),
  fromUserId: const SafeIntConverter().fromJson(json['fromUserId']),
  toUserId: const SafeIntConverter().fromJson(json['toUserId']),
  amount: const SafeNumConverter().fromJson(json['amount']),
  description: const SafeStringConverter().fromJson(json['description']),
  fromUser: json['fromUser'] == null
      ? null
      : UserModel.fromJson(json['fromUser'] as Map<String, dynamic>),
  toUser: json['toUser'] == null
      ? null
      : UserModel.fromJson(json['toUser'] as Map<String, dynamic>),
  createdAt: const SafeDateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$GroupTransactionModelToJson(
  GroupTransactionModel instance,
) => <String, dynamic>{
  'id': const SafeIntConverter().toJson(instance.id),
  'groupId': const SafeIntConverter().toJson(instance.groupId),
  'fromUserId': const SafeIntConverter().toJson(instance.fromUserId),
  'toUserId': const SafeIntConverter().toJson(instance.toUserId),
  'amount': const SafeNumConverter().toJson(instance.amount),
  'description': const SafeStringConverter().toJson(instance.description),
  'fromUser': instance.fromUser?.toJson(),
  'toUser': instance.toUser?.toJson(),
  'createdAt': const SafeDateTimeConverter().toJson(instance.createdAt),
};
