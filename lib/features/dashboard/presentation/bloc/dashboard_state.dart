part of 'dashboard_bloc.dart';


enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardEntity? dashboard;
  final String message;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.dashboard,
    this.message = '',
  });

  @override
  List<Object?> get props => [status, dashboard, message];
}