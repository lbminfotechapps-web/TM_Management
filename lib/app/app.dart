import '../features/team/presentation/bloc/team_bloc.dart';
import '../features/reports/presentation/bloc/report_bloc.dart';
import '../features/appointments/presentation/bloc/appointment_bloc.dart';
import '../features/measurements/presentation/bloc/measurement_bloc.dart';
import '../features/orders/presentation/bloc/order_bloc.dart';
import '../features/customers/presentation/bloc/customer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection_container.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/subscription/presentation/bloc/subscription_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';

class TailorProApp extends StatefulWidget {
  const TailorProApp({super.key});

  @override
  State<TailorProApp> createState() => _TailorProAppState();
}

class _TailorProAppState extends State<TailorProApp> {
  late final AuthBloc authBloc;
  late final SubscriptionBloc subscriptionBloc;
  late final DashboardBloc dashboardBloc;
  late final CustomerBloc customerBloc;
  late final OrderBloc orderBloc;
  late final AppRouter appRouter;

  @override
  void initState() {
    super.initState();

    authBloc = sl<AuthBloc>();
    subscriptionBloc = sl<SubscriptionBloc>();
    dashboardBloc = sl<DashboardBloc>();
    customerBloc = sl<CustomerBloc>();
    orderBloc = sl<OrderBloc>();

    appRouter = AppRouter(
      authBloc: authBloc,
      subscriptionBloc: subscriptionBloc,
    );

    authBloc.stream.listen((state) {
      if (state.status == AuthStatus.authenticated) {
        subscriptionBloc.add(CheckActivePlanEvent());
      }
    });

    subscriptionBloc.stream.listen((state) {
      if (state.status == SubscriptionStatus.active) {
        dashboardBloc.add(LoadDashboardEvent());
      }
    });

    authBloc.add(CheckAuthEvent());
  }

  @override
  void dispose() {
    appRouter.dispose();
    authBloc.close();
    subscriptionBloc.close();
    dashboardBloc.close();
    customerBloc.close();
    orderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TeamBloc>(create: (_) => sl<TeamBloc>()),
        BlocProvider<ReportBloc>(create: (_) => sl<ReportBloc>()),
        BlocProvider<AppointmentBloc>(create: (_) => sl<AppointmentBloc>()),
        BlocProvider<MeasurementBloc>(create: (_) => sl<MeasurementBloc>()),
        BlocProvider<OrderBloc>.value(value: orderBloc),
        BlocProvider<CustomerBloc>.value(value: customerBloc),
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SubscriptionBloc>.value(
          value: subscriptionBloc,
        ),
        BlocProvider<DashboardBloc>.value(
          value: dashboardBloc,
        ),
      ],
      child: MaterialApp.router(
        title: 'TailorPro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter.router,
      ),
    );
  }
}
