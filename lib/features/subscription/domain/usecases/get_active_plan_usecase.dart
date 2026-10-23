import '../../../../core/usecases/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetActivePlanUseCase
    implements UseCase<SubscriptionEntity?, NoParams> {
  final SubscriptionRepository repository;

  GetActivePlanUseCase(this.repository);

  @override
  Future<SubscriptionEntity?> call(NoParams params) {
    return repository.getActivePlan();
  }
}