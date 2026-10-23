
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/measurement_entity.dart';
import '../../domain/usecases/get_measurements_usecase.dart';
import '../../domain/usecases/save_measurement_usecase.dart';
import '../../domain/usecases/delete_measurement_usecase.dart';

part 'measurement_event.dart';
part 'measurement_state.dart';

class MeasurementBloc
    extends Bloc<MeasurementEvent, MeasurementState> {
  final GetMeasurementsUseCase getMeasurementsUseCase;
  final SaveMeasurementUseCase saveMeasurementUseCase;
  final DeleteMeasurementUseCase deleteMeasurementUseCase;

  MeasurementBloc({
    required this.getMeasurementsUseCase,
    required this.saveMeasurementUseCase,
    required this.deleteMeasurementUseCase,
  }) : super(const MeasurementState()) {
    on<LoadMeasurementsEvent>(_onLoad);
    on<SaveMeasurementEvent>(_onSave);
    on<DeleteMeasurementEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadMeasurementsEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(state.copyWith(
      status: MeasurementStatus.loading,
      message: '',
    ));

    try {
      final items = await getMeasurementsUseCase();

      emit(state.copyWith(
        status: MeasurementStatus.success,
        measurements: items,
        message: '',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MeasurementStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }

  Future<void> _onSave(
    SaveMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(state.copyWith(
      status: MeasurementStatus.saving,
      message: '',
    ));

    try {
      await saveMeasurementUseCase(event.measurement);

      final items = await getMeasurementsUseCase();

      emit(state.copyWith(
        status: MeasurementStatus.saved,
        measurements: items,
        message: 'Measurements saved successfully',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MeasurementStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }

  Future<void> _onDelete(
    DeleteMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(state.copyWith(
      status: MeasurementStatus.deleting,
      message: '',
    ));

    try {
      await deleteMeasurementUseCase(event.measurementId);

      final items = await getMeasurementsUseCase();

      emit(state.copyWith(
        status: MeasurementStatus.deleted,
        measurements: items,
        message: 'Measurements deleted successfully',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MeasurementStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }
}
