import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource localDataSource;

  SubscriptionRepositoryImpl(this.localDataSource);

  @override
  Future<List<SubscriptionEntity>> getPlans() {
    return localDataSource.getPlans();
  }

  @override
  Future<SubscriptionEntity?> getActivePlan() {
    return localDataSource.getActivePlan();
  }

  @override
  Future<void> activatePlan(String planId) {
    return localDataSource.activatePlan(planId);
  }

  @override
  Future<void> clearActivePlan() {
    return localDataSource.clearActivePlan();
  }
}