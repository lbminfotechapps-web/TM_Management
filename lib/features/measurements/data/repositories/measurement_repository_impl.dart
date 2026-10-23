
import '../../domain/entities/measurement_entity.dart';
import '../../domain/repositories/measurement_repository.dart';

import '../datasources/measurement_local_datasource.dart';
import '../models/measurement_model.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final MeasurementLocalDataSource localDataSource;

  MeasurementRepositoryImpl(this.localDataSource);

  @override
  Future<List<MeasurementEntity>> getMeasurements() async {
    final models = await localDataSource.getMeasurements();
    return List<MeasurementEntity>.from(models);
  }

  @override
  Future<MeasurementEntity> saveMeasurement(
    MeasurementEntity measurement,
  ) {
    return localDataSource.saveMeasurement(
      MeasurementModel.fromEntity(measurement),
    );
  }

  @override
  Future<void> deleteMeasurement(String id) {
    return localDataSource.deleteMeasurement(id);
  }
}
