
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment_entity.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import '../../domain/usecases/save_appointment_usecase.dart';
import '../../domain/usecases/delete_appointment_usecase.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc
    extends Bloc<AppointmentEvent, AppointmentState> {
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final SaveAppointmentUseCase saveAppointmentUseCase;
  final DeleteAppointmentUseCase deleteAppointmentUseCase;

  AppointmentBloc({
    required this.getAppointmentsUseCase,
    required this.saveAppointmentUseCase,
    required this.deleteAppointmentUseCase,
  }) : super(const AppointmentState()) {
    on<LoadAppointmentsEvent>(_onLoad);
    on<SaveAppointmentEvent>(_onSave);
    on<DeleteAppointmentEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(state.copyWith(
      status: AppointmentBlocStatus.loading,
      message: '',
    ));

    try {
      final items = await getAppointmentsUseCase();

      emit(state.copyWith(
        status: AppointmentBlocStatus.success,
        appointments: items,
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentBlocStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }

  Future<void> _onSave(
    SaveAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(state.copyWith(
      status: AppointmentBlocStatus.saving,
      message: '',
    ));

    try {
      await saveAppointmentUseCase(event.appointment);

      emit(state.copyWith(
        status: AppointmentBlocStatus.saved,
        appointments: await getAppointmentsUseCase(),
        message: 'Appointment saved successfully',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentBlocStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }

  Future<void> _onDelete(
    DeleteAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(state.copyWith(
      status: AppointmentBlocStatus.deleting,
      message: '',
    ));

    try {
      await deleteAppointmentUseCase(event.id);

      emit(state.copyWith(
        status: AppointmentBlocStatus.deleted,
        appointments: await getAppointmentsUseCase(),
        message: 'Appointment deleted successfully',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentBlocStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }
}
