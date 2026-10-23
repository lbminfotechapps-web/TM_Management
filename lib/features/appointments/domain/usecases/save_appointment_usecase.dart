
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class SaveAppointmentUseCase {
  final AppointmentRepository repository;

  SaveAppointmentUseCase(this.repository);

  Future<AppointmentEntity> call(AppointmentEntity appointment) {
    if (appointment.customerId.trim().isEmpty) {
      throw Exception('Please select a customer');
    }

    if (appointment.purpose.trim().isEmpty) {
      throw Exception('Enter appointment purpose');
    }

    return repository.saveAppointment(appointment);
  }
}
