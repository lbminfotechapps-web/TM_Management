
import '../models/measurement_model.dart';

abstract class MeasurementLocalDataSource {
  Future<List<MeasurementModel>> getMeasurements();

  Future<MeasurementModel> saveMeasurement(
    MeasurementModel measurement,
  );

  Future<void> deleteMeasurement(String id);
}

class MeasurementLocalDataSourceImpl
    implements MeasurementLocalDataSource {
  final List<MeasurementModel> _measurements = [
    MeasurementModel.fromJson({
      'id': 'M001',
      'customer_id': 'C001',
      'customer_name': 'Anita Sharma',
      'garment_type': 'Blouse',
      'chest': 36,
      'waist': 30,
      'hip': 38,
      'shoulder': 14,
      'sleeve': 11,
      'length': 15,
      'notes': 'Boat neck, slim fitting',
      'created_at': '2026-10-10T10:00:00',
    }),
    MeasurementModel.fromJson({
      'id': 'M002',
      'customer_id': 'C002',
      'customer_name': 'Vikram Mehta',
      'garment_type': 'Suit',
      'chest': 40,
      'waist': 34,
      'hip': 40,
      'shoulder': 18,
      'sleeve': 24,
      'length': 29,
      'notes': 'Regular fit',
      'created_at': '2026-10-11T11:00:00',
    }),
  ];

  @override
  Future<List<MeasurementModel>> getMeasurements() async {
    return List<MeasurementModel>.unmodifiable(_measurements);
  }

  @override
  Future<MeasurementModel> saveMeasurement(
    MeasurementModel measurement,
  ) async {
    final index = _measurements.indexWhere(
      (item) => item.id == measurement.id,
    );

    if (index == -1) {
      _measurements.insert(0, measurement);
    } else {
      _measurements[index] = measurement;
    }

    return measurement;
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    _measurements.removeWhere((item) => item.id == id);
  }
}
