import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.name,
    required super.price,
    required super.customerLimit,
    required super.benefits,
    required super.features,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      customerLimit: (json['customer_limit'] as num).toInt(),
      benefits: List<String>.from(json['benefits']),
      features: (json['features'] as List)
          .map((item) => SubscriptionFeature.values.byName(
                item.toString(),
              ))
          .toSet(),
    );
  }
}