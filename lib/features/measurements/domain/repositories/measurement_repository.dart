
import '../entities/measurement_entity.dart';

abstract class MeasurementRepository {
  Future<List<MeasurementEntity>> getMeasurements();

  Future<MeasurementEntity> saveMeasurement(
    MeasurementEntity measurement,
  );

  Future<void> deleteMeasurement(String id);
}
