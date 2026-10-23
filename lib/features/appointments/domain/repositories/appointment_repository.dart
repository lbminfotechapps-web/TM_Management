
import '../entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntity>> getAppointments();

  Future<AppointmentEntity> saveAppointment(
    AppointmentEntity appointment,
  );

  Future<void> deleteAppointment(String id);
}
