
import '../entities/measurement_entity.dart';
import '../repositories/measurement_repository.dart';

class SaveMeasurementUseCase {
  final MeasurementRepository repository;

  SaveMeasurementUseCase(this.repository);

  Future<MeasurementEntity> call(MeasurementEntity measurement) {
    if (measurement.customerId.trim().isEmpty) {
      throw Exception('Please select a customer');
    }

    if (measurement.garmentType.trim().isEmpty) {
      throw Exception('Please select a garment');
    }

    final values = [
      measurement.chest,
      measurement.waist,
      measurement.hip,
      measurement.shoulder,
      measurement.sleeve,
      measurement.length,
    ];

    if (values.any((value) => !value.isFinite || value <= 0)) {
      throw Exception(
        'Enter valid measurements greater than zero',
      );
    }

    return repository.saveMeasurement(measurement);
  }
}
