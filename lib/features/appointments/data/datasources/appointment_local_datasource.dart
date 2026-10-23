
import '../models/appointment_model.dart';

abstract class AppointmentLocalDataSource {
  Future<List<AppointmentModel>> getAppointments();

  Future<AppointmentModel> saveAppointment(
    AppointmentModel appointment,
  );

  Future<void> deleteAppointment(String id);
}

class AppointmentLocalDataSourceImpl
    implements AppointmentLocalDataSource {
  final List<AppointmentModel> _appointments = [
    AppointmentModel.fromJson({
      'id': 'APT001',
      'customer_id': 'C001',
      'customer_name': 'Anita Sharma',
      'purpose': 'Blouse fitting',
      'date_time': DateTime.now()
          .add(const Duration(hours: 2))
          .toIso8601String(),
      'status': 'confirmed',
      'notes': 'Bring blouse sample',
      'created_at': DateTime.now().toIso8601String(),
    }),
    AppointmentModel.fromJson({
      'id': 'APT002',
      'customer_id': 'C002',
      'customer_name': 'Vikram Mehta',
      'purpose': 'Suit trial',
      'date_time': DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String(),
      'status': 'scheduled',
      'notes': 'First fitting',
      'created_at': DateTime.now().toIso8601String(),
    }),
    AppointmentModel.fromJson({
      'id': 'APT003',
      'customer_id': 'C003',
      'customer_name': 'Sneha Patel',
      'purpose': 'Lehenga consultation',
      'date_time': DateTime.now()
          .add(const Duration(days: 2))
          .toIso8601String(),
      'status': 'scheduled',
      'notes': 'Discuss embroidery design',
      'created_at': DateTime.now().toIso8601String(),
    }),
  ];

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    final items = List<AppointmentModel>.from(_appointments);
    items.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return List.unmodifiable(items);
  }

  @override
  Future<AppointmentModel> saveAppointment(
    AppointmentModel appointment,
  ) async {
    final index = _appointments.indexWhere(
      (item) => item.id == appointment.id,
    );

    if (index == -1) {
      _appointments.add(appointment);
    } else {
      _appointments[index] = appointment;
    }

    return appointment;
  }

  @override
  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((item) => item.id == id);
  }
}
