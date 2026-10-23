import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionEntity>> getPlans();
  Future<SubscriptionEntity?> getActivePlan();
  Future<void> activatePlan(String planId);
  Future<void> clearActivePlan();
}