import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc
    extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardUseCase getDashboard;

  DashboardBloc(this.getDashboard)
      : super(const DashboardState()) {
    on<LoadDashboardEvent>((event, emit) async {
      emit(const DashboardState(
        status: DashboardStatus.loading,
      ));

      try {
        final data = await getDashboard(const NoParams());

        emit(DashboardState(
          status: DashboardStatus.success,
          dashboard: data,
        ));
      } catch (e) {
        emit(DashboardState(
          status: DashboardStatus.failure,
          message: e.toString(),
        ));
      }
    });
  }
}