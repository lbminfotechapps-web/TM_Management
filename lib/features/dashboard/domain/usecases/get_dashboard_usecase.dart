import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase
    implements UseCase<DashboardEntity, NoParams> {
  final DashboardRepository repository;

  GetDashboardUseCase(this.repository);

  @override
  Future<DashboardEntity> call(NoParams params) {
    return repository.getDashboard();
  }
}