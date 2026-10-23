
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/report_entity.dart';
import '../../domain/usecases/get_report_usecase.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetReportUseCase getReportUseCase;

  ReportBloc({
    required this.getReportUseCase,
  }) : super(const ReportState()) {
    on<LoadReportEvent>(_onLoadReport);
  }

  Future<void> _onLoadReport(
    LoadReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(
      status: ReportStatus.loading,
      message: '',
    ));

    try {
      final report = await getReportUseCase(
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(ReportState(
        status: ReportStatus.success,
        report: report,
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReportStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }
}
