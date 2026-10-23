import 'package:equatable/equatable.dart';

enum SubscriptionFeature {
  customers,
  orders,
  measurements,
  appointments,
  reports,
  team,
  workDistribution,
}

class SubscriptionEntity extends Equatable {
  final String id;
  final String name;
  final int price;
  final int customerLimit;
  final List<String> benefits;
  final Set<SubscriptionFeature> features;

  const SubscriptionEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.customerLimit,
    required this.benefits,
    required this.features,
  });

  bool canAccess(SubscriptionFeature feature) {
    return features.contains(feature);
  }

  @override
  List<Object?> get props => [
    id, name, price, customerLimit, benefits, features,
  ];
}