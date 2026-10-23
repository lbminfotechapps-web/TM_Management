import '../../../../core/usecases/usecase.dart';
import '../repositories/subscription_repository.dart';

class ActivatePlanUseCase implements UseCase<void, String> {
  final SubscriptionRepository repository;

  ActivatePlanUseCase(this.repository);

  @override
  Future<void> call(String planId) {
    return repository.activatePlan(planId);
  }
}