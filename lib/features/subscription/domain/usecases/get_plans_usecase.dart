import '../../../../core/usecases/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetPlansUseCase
    implements UseCase<List<SubscriptionEntity>, NoParams> {
  final SubscriptionRepository repository;

  GetPlansUseCase(this.repository);

  @override
  Future<List<SubscriptionEntity>> call(NoParams params) {
    return repository.getPlans();
  }
}