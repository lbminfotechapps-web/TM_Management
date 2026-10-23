
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailorpro_clean/features/invoices/data/datasources/invoice_local_data_source.dart';
import 'package:tailorpro_clean/features/invoices/data/datasources/invoice_pdf_data_source.dart';
import 'package:tailorpro_clean/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:tailorpro_clean/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:tailorpro_clean/features/invoices/domain/usecases/export_invoice_usecase.dart';
import 'package:tailorpro_clean/features/invoices/domain/usecases/get_invoice_usecase.dart';
import 'package:tailorpro_clean/features/invoices/domain/usecases/save_invoice_usecase.dart';
import 'package:tailorpro_clean/features/invoices/presentation/bloc/invoice_bloc.dart';

// ============================================================
// AUTHENTICATION
// ============================================================

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// ============================================================
// SUBSCRIPTION
// ============================================================

import '../../features/subscription/data/datasources/subscription_local_datasource.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/subscription/domain/usecases/get_plans_usecase.dart';
import '../../features/subscription/domain/usecases/get_active_plan_usecase.dart';
import '../../features/subscription/domain/usecases/activate_plan_usecase.dart';
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';

// ============================================================
// DASHBOARD
// ============================================================

import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// ============================================================
// CUSTOMERS
// ============================================================

import '../../features/customers/data/datasources/customer_local_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/customer_usecases.dart';
import '../../features/customers/domain/usecases/save_customer_usecase.dart';
import '../../features/customers/domain/usecases/delete_customer_usecase.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';

// ============================================================
// ORDERS
// ============================================================

import '../../features/orders/data/datasources/order_local_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/get_orders_usecase.dart';
import '../../features/orders/domain/usecases/save_order_usecase.dart';
import '../../features/orders/domain/usecases/delete_order_usecase.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';

// ============================================================
// MEASUREMENTS
// ============================================================

import '../../features/measurements/data/datasources/measurement_local_datasource.dart';
import '../../features/measurements/data/repositories/measurement_repository_impl.dart';
import '../../features/measurements/domain/repositories/measurement_repository.dart';
import '../../features/measurements/domain/usecases/delete_measurement_usecase.dart';
import '../../features/measurements/domain/usecases/get_measurements_usecase.dart';
import '../../features/measurements/domain/usecases/save_measurement_usecase.dart';
import '../../features/measurements/presentation/bloc/measurement_bloc.dart';

// ============================================================
// APPOINTMENTS
// ============================================================

import '../../features/appointments/data/datasources/appointment_local_datasource.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart';
import '../../features/appointments/domain/usecases/get_appointments_usecase.dart';
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart';
import '../../features/appointments/presentation/bloc/appointment_bloc.dart';

// ============================================================
// REPORTS
// ============================================================

import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/get_report_usecase.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';

// ============================================================
// TEAM
// ============================================================

import '../../features/team/data/datasources/team_local_datasource.dart';
import '../../features/team/data/repositories/team_repository_impl.dart';
import '../../features/team/domain/repositories/team_repository.dart';
import '../../features/team/domain/usecases/delete_team_member_usecase.dart';
import '../../features/team/domain/usecases/get_team_members_usecase.dart';
import '../../features/team/domain/usecases/save_team_member_usecase.dart';
import '../../features/team/presentation/bloc/team_bloc.dart';



// ============================================================
// GETIT INSTANCE
// ============================================================

final GetIt sl = GetIt.instance;

// ============================================================
// INITIALIZE ALL DEPENDENCIES
// ============================================================

Future<void> initializeDependencies() async {

  // ==========================================================
  // SHARED STORAGE
  // ==========================================================

  sl.registerLazySingleton<SharedPreferencesAsync>(
    () => SharedPreferencesAsync(),
  );

  // ==========================================================
  // AUTHENTICATION
  // ==========================================================

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(
    () => LoginUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => GetCurrentUserUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => LogoutUseCase(sl()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      currentUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ==========================================================
  // SUBSCRIPTION
  // ==========================================================

  sl.registerLazySingleton<SubscriptionLocalDataSource>(
    () => SubscriptionLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(
    () => GetPlansUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => GetActivePlanUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => ActivatePlanUseCase(sl()),
  );

  sl.registerFactory<SubscriptionBloc>(
    () => SubscriptionBloc(
      getPlans: sl(),
      getActivePlan: sl(),
      activatePlan: sl(),
      repository: sl(),
    ),
  );

  // ==========================================================
  // DASHBOARD
  // ==========================================================

  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(
    () => GetDashboardUseCase(sl()),
  );

  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(sl()),
  );

  // ==========================================================
  // CUSTOMERS
  // ==========================================================

  sl.registerLazySingleton<CustomerLocalDataSource>(
    () => CustomerLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(
    () => GetCustomersUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => SaveCustomerUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => DeleteCustomerUseCase(sl()),
  );

  sl.registerFactory<CustomerBloc>(
    () => CustomerBloc(
      getCustomersUseCase: sl(),
      saveCustomerUseCase: sl(),
      deleteCustomerUseCase: sl(),
    ),
  );

  // ==========================================================
  // ORDERS
  // ==========================================================

  sl.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(
    () => GetOrdersUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => SaveOrderUseCase(sl()),
  );

  sl.registerLazySingleton(
    () => DeleteOrderUseCase(sl()),
  );

  sl.registerFactory<OrderBloc>(
    () => OrderBloc(
      getOrdersUseCase: sl(),
      saveOrderUseCase: sl(),
      deleteOrderUseCase: sl(),
    ),
  );

  // ==========================================================
  // MEASUREMENTS
  // ==========================================================

  sl.registerLazySingleton<MeasurementLocalDataSource>(
    () => MeasurementLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<MeasurementRepository>(
    () => MeasurementRepositoryImpl(
      sl<MeasurementLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetMeasurementsUseCase>(
    () => GetMeasurementsUseCase(
      sl<MeasurementRepository>(),
    ),
  );

  sl.registerLazySingleton<SaveMeasurementUseCase>(
    () => SaveMeasurementUseCase(
      sl<MeasurementRepository>(),
    ),
  );

  sl.registerLazySingleton<DeleteMeasurementUseCase>(
    () => DeleteMeasurementUseCase(
      sl<MeasurementRepository>(),
    ),
  );

  sl.registerFactory<MeasurementBloc>(
    () => MeasurementBloc(
      getMeasurementsUseCase:
          sl<GetMeasurementsUseCase>(),
      saveMeasurementUseCase:
          sl<SaveMeasurementUseCase>(),
      deleteMeasurementUseCase:
          sl<DeleteMeasurementUseCase>(),
    ),
  );

  // ==========================================================
  // APPOINTMENTS
  // ==========================================================

  sl.registerLazySingleton<AppointmentLocalDataSource>(
    () => AppointmentLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      sl<AppointmentLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetAppointmentsUseCase>(
    () => GetAppointmentsUseCase(
      sl<AppointmentRepository>(),
    ),
  );

  sl.registerLazySingleton<SaveAppointmentUseCase>(
    () => SaveAppointmentUseCase(
      sl<AppointmentRepository>(),
    ),
  );

  sl.registerLazySingleton<DeleteAppointmentUseCase>(
    () => DeleteAppointmentUseCase(
      sl<AppointmentRepository>(),
    ),
  );

  sl.registerFactory<AppointmentBloc>(
    () => AppointmentBloc(
      getAppointmentsUseCase:
          sl<GetAppointmentsUseCase>(),
      saveAppointmentUseCase:
          sl<SaveAppointmentUseCase>(),
      deleteAppointmentUseCase:
          sl<DeleteAppointmentUseCase>(),
    ),
  );

  // ==========================================================
  // REPORTS
  // ==========================================================

  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      customerRepository: sl<CustomerRepository>(),
      orderRepository: sl<OrderRepository>(),
      appointmentRepository: sl<AppointmentRepository>(),
    ),
  );

  sl.registerLazySingleton<GetReportUseCase>(
    () => GetReportUseCase(
      sl<ReportRepository>(),
    ),
  );

  sl.registerFactory<ReportBloc>(
    () => ReportBloc(
      getReportUseCase: sl<GetReportUseCase>(),
    ),
  );

  // ==========================================================
  // TEAM
  // ==========================================================

  sl.registerLazySingleton<TeamLocalDataSource>(
    () => TeamLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(
      sl<TeamLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetTeamMembersUseCase>(
    () => GetTeamMembersUseCase(
      sl<TeamRepository>(),
    ),
  );

  sl.registerLazySingleton<SaveTeamMemberUseCase>(
    () => SaveTeamMemberUseCase(
      sl<TeamRepository>(),
    ),
  );

  sl.registerLazySingleton<DeleteTeamMemberUseCase>(
    () => DeleteTeamMemberUseCase(
      sl<TeamRepository>(),
    ),
  );

  sl.registerFactory<TeamBloc>(
    () => TeamBloc(
      getMembers: sl<GetTeamMembersUseCase>(),
      saveMember: sl<SaveTeamMemberUseCase>(),
      deleteMember: sl<DeleteTeamMemberUseCase>(),
    ),
  );

  // ==========================================================
  // INVOICE MODULE - NEW
  // ==========================================================

  // 1. LOCAL DATA SOURCE
  sl.registerLazySingleton<InvoiceLocalDataSource>(
    () => InvoiceLocalDataSourceImpl(),
  );

  // 2. PDF DATA SOURCE
  sl.registerLazySingleton<InvoicePdfDataSource>(
    () => InvoicePdfDataSourceImpl(),
  );

  // 3. REPOSITORY
  sl.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(
      local: sl<InvoiceLocalDataSource>(),
      pdf: sl<InvoicePdfDataSource>(),
    ),
  );

  // 4. SAVE INVOICE USE CASE
  sl.registerLazySingleton<SaveInvoiceUseCase>(
    () => SaveInvoiceUseCase(
      sl<InvoiceRepository>(),
    ),
  );

  // 5. GET INVOICE USE CASE
  sl.registerLazySingleton<GetInvoiceUseCase>(
    () => GetInvoiceUseCase(
      sl<InvoiceRepository>(),
    ),
  );

  // 6. EXPORT INVOICE USE CASE
  sl.registerLazySingleton<ExportInvoiceUseCase>(
    () => ExportInvoiceUseCase(
      sl<InvoiceRepository>(),
    ),
  );

  // 7. INVOICE BLOC
  sl.registerFactory<InvoiceBloc>(
    () => InvoiceBloc(
      saveInvoice: sl<SaveInvoiceUseCase>(),
      getInvoice: sl<GetInvoiceUseCase>(),
      exportInvoice: sl<ExportInvoiceUseCase>(),
    ),
  );
}
