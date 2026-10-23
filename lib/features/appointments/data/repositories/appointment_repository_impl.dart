
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentLocalDataSource localDataSource;

  AppointmentRepositoryImpl(this.localDataSource);

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    return List<AppointmentEntity>.from(
      await localDataSource.getAppointments(),
    );
  }

  @override
  Future<AppointmentEntity> saveAppointment(
    AppointmentEntity appointment,
  ) {
    return localDataSource.saveAppointment(
      AppointmentModel.fromEntity(appointment),
    );
  }

  @override
  Future<void> deleteAppointment(String id) {
    return localDataSource.deleteAppointment(id);
  }
}
