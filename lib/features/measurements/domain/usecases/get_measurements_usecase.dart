
import '../entities/measurement_entity.dart';
import '../repositories/measurement_repository.dart';

class GetMeasurementsUseCase {
  final MeasurementRepository repository;

  GetMeasurementsUseCase(this.repository);

  Future<List<MeasurementEntity>> call() {
    return repository.getMeasurements();
  }
}
