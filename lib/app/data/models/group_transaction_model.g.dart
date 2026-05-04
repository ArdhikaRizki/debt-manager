// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupSettlementRequestModel _$GroupSettlementRequestModelFromJson(
  Map<String, dynamic> json,
) => GroupSettlementRequestModel(
  id: const SafeIntConverter().fromJson(json['id']),
  status: const SafeStatusConverter().fromJson(json['status']),
);

Map<String, dynamic> _$GroupSettlementRequestModelToJson(
  GroupSettlementRequestModel instance,
) => <String, dynamic>{
  'id': const SafeIntConverter().toJson(instance.id),
  'status': const SafeStatusConverter().toJson(instance.status),
};

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
  settlementRequests: (json['settlementRequests'] as List<dynamic>?)
      ?.map((e) => GroupSettlementRequestModel.fromJson(e as Map<String, dynamic>))
      .toList(),
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
  'settlementRequests': instance.settlementRequests?.map((e) => e.toJson()).toList(),
  'createdAt': const SafeDateTimeConverter().toJson(instance.createdAt),
};
