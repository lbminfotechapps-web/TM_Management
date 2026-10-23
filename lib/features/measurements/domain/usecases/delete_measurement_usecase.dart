
import '../repositories/measurement_repository.dart';

class DeleteMeasurementUseCase {
  final MeasurementRepository repository;

  DeleteMeasurementUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteMeasurement(id);
  }
}
