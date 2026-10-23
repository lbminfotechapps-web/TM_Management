import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tailorpro_clean/features/invoices/domain/entities/invoice_entity.dart';
import 'package:tailorpro_clean/features/invoices/presentation/bloc/invoice_bloc.dart';
import 'package:tailorpro_clean/features/invoices/presentation/pages/invoice_preview_page.dart';
import 'package:tailorpro_clean/features/workdistribution/presentation/pages/assign_work_page.dart';
import 'package:tailorpro_clean/features/workdistribution/presentation/pages/work_distribution_page.dart';

import '../widgets/app_shell.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorpro_clean/features/team/domain/entities/team_member_entity.dart';
import 'package:tailorpro_clean/features/team/presentation/pages/team_details_page.dart';
import 'package:tailorpro_clean/features/team/presentation/pages/team_form_page.dart';
import 'package:tailorpro_clean/features/team/presentation/pages/team_page.dart';

// ======================================================
// AUTHENTICATION
// ======================================================
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';


// ======================================================
// SPLASH
// ======================================================
import '../../features/splash/presentation/pages/splash_page.dart';

// ======================================================
// SUBSCRIPTION
// ======================================================
import '../../features/subscription/domain/entities/subscription_entity.dart';
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/subscription/presentation/pages/payment_page.dart';

// ======================================================
// DASHBOARD
// ======================================================
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

// ======================================================
// CUSTOMERS
// ======================================================
import '../../features/customers/domain/entities/customer_entity.dart';
import '../../features/customers/presentation/pages/customer_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/customers/presentation/pages/customer_details_page.dart';

// ======================================================
// ORDERS
// ======================================================
import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/orders/presentation/pages/order_page.dart';
import '../../features/orders/presentation/pages/order_form_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';

// ======================================================
// MEASUREMENTS
// ======================================================
import '../../features/measurements/domain/entities/measurement_entity.dart';
import '../../features/measurements/presentation/pages/measurement_page.dart';
import '../../features/measurements/presentation/pages/measurement_form_page.dart';
import '../../features/measurements/presentation/pages/measurement_details_page.dart';

// ======================================================
// APPOINTMENTS
// ======================================================
import '../../features/appointments/domain/entities/appointment_entity.dart';
import '../../features/appointments/presentation/pages/appointment_page.dart';
import '../../features/appointments/presentation/pages/appointment_form_page.dart';
import '../../features/appointments/presentation/pages/appointment_details_page.dart';

// ======================================================
// REPORTS
// ======================================================
import '../../features/reports/presentation/pages/report_page.dart';

// ======================================================
// ROUTE CONSTANTS
// ======================================================
import 'app_routes.dart';

// ======================================================
// ROUTER NOTIFIER
// ======================================================

class RouterNotifier extends ChangeNotifier {
  final AuthBloc authBloc;
  final SubscriptionBloc subscriptionBloc;

  late final StreamSubscription<AuthState> _authSubscription;
  late final StreamSubscription<SubscriptionState>
      _subscriptionSubscription;

  RouterNotifier({
    required this.authBloc,
    required this.subscriptionBloc,
  }) {
    _authSubscription = authBloc.stream.listen((_) {
      notifyListeners();
    });

    _subscriptionSubscription =
        subscriptionBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _subscriptionSubscription.cancel();
    super.dispose();
  }
}

// ======================================================
// APP ROUTER
// ======================================================

class AppRouter {
  final AuthBloc authBloc;
  final SubscriptionBloc subscriptionBloc;

  late final RouterNotifier notifier;
  late final GoRouter router;

  AppRouter({
    required this.authBloc,
    required this.subscriptionBloc,
  }) {
    notifier = RouterNotifier(
      authBloc: authBloc,
      subscriptionBloc: subscriptionBloc,
    );

    router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: notifier,
      debugLogDiagnostics: true,

      // ==================================================
      // GLOBAL REDIRECT / ROUTE GUARD
      // ==================================================
      redirect: (context, state) {
        final authState = authBloc.state;
        final subscriptionState = subscriptionBloc.state;
        final location = state.matchedLocation;

        // ================================================
        // 1. WAIT FOR AUTH INITIALIZATION
        // ================================================

        final isAuthLoading =
            authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading;

        if (isAuthLoading) {
          if (location == AppRoutes.splash) {
            return null;
          }

          return AppRoutes.splash;
        }

        // ================================================
        // 2. CHECK USER LOGIN
        // ================================================

        final isAuthenticated =
            authState.status == AuthStatus.authenticated;

        if (!isAuthenticated) {
          if (location == AppRoutes.login ||
              location == AppRoutes.splash) {
            return null;
          }

          return AppRoutes.login;
        }

        // ================================================
        // 3. WAIT FOR SUBSCRIPTION INITIALIZATION
        // ================================================

        final isSubscriptionLoading =
            subscriptionState.status ==
                SubscriptionStatus.initial ||
            subscriptionState.status ==
                SubscriptionStatus.loading;

        if (isSubscriptionLoading) {
          if (location == AppRoutes.splash) {
            return null;
          }

          return AppRoutes.splash;
        }

        // ================================================
        // 4. ACTIVE SUBSCRIPTION
        // ================================================

        final hasActivePlan =
            subscriptionState.status ==
                SubscriptionStatus.active &&
            subscriptionState.activePlan != null;

        if (hasActivePlan) {
          final plan = subscriptionState.activePlan!;

            // ================================================
            // INVOICE MODULE - NEW
            // ================================================

            if (location == AppRoutes.invoicePreview) {
              if (plan.canAccess(SubscriptionFeature.orders)) {
                return null;
              }

              return AppRoutes.dashboard;
            }


          // ----------------------------------------------
          // CUSTOMER MODULE
          // ----------------------------------------------

          final isCustomerRoute =
              location == AppRoutes.customers ||
              location.startsWith('${AppRoutes.customers}/');

          if (isCustomerRoute) {
            if (plan.canAccess(SubscriptionFeature.customers)) {
              return null;
            }

            return AppRoutes.dashboard;
          }

          // ----------------------------------------------
          // ORDER MODULE
          // ----------------------------------------------

          final isOrderRoute =
              location == AppRoutes.orders ||
              location.startsWith('${AppRoutes.orders}/');

          if (isOrderRoute) {
            if (plan.canAccess(SubscriptionFeature.orders)) {
              return null;
            }

            return AppRoutes.dashboard;
          }

          // ----------------------------------------------
          // MEASUREMENT MODULE
          // ----------------------------------------------

          final isMeasurementRoute =
              location == AppRoutes.measurements ||
              location.startsWith(
                '${AppRoutes.measurements}/',
              );

          if (isMeasurementRoute) {
            if (plan.canAccess(
              SubscriptionFeature.measurements,
            )) {
              return null;
            }

            return AppRoutes.dashboard;
          }

          // ----------------------------------------------
          // APPOINTMENT MODULE
          // ----------------------------------------------

          final isAppointmentRoute =
              location == AppRoutes.appointments ||
              location.startsWith(
                '${AppRoutes.appointments}/',
              );

          if (isAppointmentRoute) {
            if (plan.canAccess(
              SubscriptionFeature.appointments,
            )) {
              return null;
            }

            return AppRoutes.dashboard;
          }

          // ----------------------------------------------
          // REPORTS MODULE
          // ----------------------------------------------

          final isReportRoute =
              location == AppRoutes.reports ||
              location.startsWith('${AppRoutes.reports}/');

          if (isReportRoute) {
            if (plan.canAccess(SubscriptionFeature.reports)) {
              return null;
            }

            return AppRoutes.dashboard;
          }

          // ----------------------------------------------
          // TEAM MODULE
          // ----------------------------------------------

          final isTeamRoute =
              location == AppRoutes.team ||
              location.startsWith('${AppRoutes.team}/');

          if (isTeamRoute) {
            if (plan.canAccess(SubscriptionFeature.team)) {
              return null;
            }

            return AppRoutes.dashboard;
          }



           // ----------------------------------------------
          // Work Distribution Module
          // ----------------------------------------------


          final iswWrkDistribution =
              location == AppRoutes.workDistribution ||
              location == AppRoutes.assignWork ||
              location.startsWith('${AppRoutes.workDistribution}/');

          if (iswWrkDistribution) {
            if (plan.canAccess(SubscriptionFeature.workDistribution)) {
              return null;
            }

            return AppRoutes.dashboard;
          }




          // ----------------------------------------------
          // DASHBOARD
          // ----------------------------------------------

          if (location == AppRoutes.dashboard) {
            return null;
          }

          // Logged-in users with an active subscription
          // should not return to login, splash or payment.

          return AppRoutes.dashboard;
        }

        // ================================================
        // 5. PAYMENT REQUIRED
        // ================================================

        if (subscriptionState.status ==
            SubscriptionStatus.paymentRequired) {
          if (location == AppRoutes.payment) {
            return null;
          }

          return AppRoutes.payment;
        }

        // ================================================
        // 6. NO ACTIVE SUBSCRIPTION
        // ================================================

        if (location == AppRoutes.subscription) {
          return null;
        }

        return AppRoutes.subscription;
      },

      // ==================================================
      // ALL ROUTES
      // ==================================================
      routes: [
        // ================================================
        // SPLASH
        // ================================================

        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) {
            return SplashPage(
              onContinue: () {
                context.go(AppRoutes.login);
              },
            );
          },
        ),

        // ================================================
        // LOGIN
        // ================================================

        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) {
            return const LoginPage();
          },
        ),

        // ================================================
        // SUBSCRIPTION
        // ================================================

        GoRoute(
          path: AppRoutes.subscription,
          builder: (context, state) {
            return const SubscriptionPage();
          },
        ),

        // ================================================
        // PAYMENT
        // ================================================

        GoRoute(
          path: AppRoutes.payment,
          builder: (context, state) {
            return const PaymentPage();
          },
        ),

        // ================================================
        // DASHBOARD
        // ================================================

        ShellRoute(
          builder: (context, state, child) => AppShell(
            location: state.uri.path, child: child),
          routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) {
            return const DashboardPage();
          },
        ),

        // ================================================
        // CUSTOMER MODULE
        // ================================================

        GoRoute(
          path: AppRoutes.customers,
          builder: (context, state) {
            return const CustomerPage();
          },
        ),

        GoRoute(
          path: AppRoutes.addCustomer,
          builder: (context, state) {
            return const CustomerFormPage();
          },
        ),

        GoRoute(
          path: AppRoutes.editCustomer,
          builder: (context, state) {
            final customer = state.extra;

            if (customer is! CustomerEntity) {
              return _notFoundPage('Customer');
            }

            return CustomerFormPage(customer: customer);
          },
        ),

        GoRoute(
          path: AppRoutes.customerDetails,
          builder: (context, state) {
            final customer = state.extra;

            if (customer is! CustomerEntity) {
              return _notFoundPage('Customer');
            }

            return CustomerDetailsPage(customer: customer);
          },
        ),

        // ================================================
        // ORDER MODULE
        // ================================================

        GoRoute(
          path: AppRoutes.orders,
          builder: (context, state) {
            return const OrderPage();
          },
        ),

        GoRoute(
          path: AppRoutes.addOrder,
          builder: (context, state) {
            return const OrderFormPage();
          },
        ),

        GoRoute(
          path: AppRoutes.editOrder,
          builder: (context, state) {
            final order = state.extra;

            if (order is! OrderEntity) {
              return _notFoundPage('Order');
            }

            return OrderFormPage(order: order);
          },
        ),

        GoRoute(
          path: AppRoutes.orderDetails,
          builder: (context, state) {
            final order = state.extra;

            if (order is! OrderEntity) {
              return _notFoundPage('Order');
            }

            return OrderDetailsPage(order: order);
          },
        ),

        // ================================================
        // MEASUREMENT MODULE
        // ================================================

        GoRoute(
          path: AppRoutes.measurements,
          builder: (context, state) {
            return const MeasurementPage();
          },
        ),

        GoRoute(
          path: AppRoutes.addMeasurement,
          builder: (context, state) {
            return const MeasurementFormPage();
          },
        ),

        GoRoute(
          path: AppRoutes.editMeasurement,
          builder: (context, state) {
            final measurement = state.extra;

            if (measurement is! MeasurementEntity) {
              return _notFoundPage('Measurement');
            }

            return MeasurementFormPage(
              measurement: measurement,
            );
          },
        ),

        GoRoute(
          path: AppRoutes.measurementDetails,
          builder: (context, state) {
            final measurement = state.extra;

            if (measurement is! MeasurementEntity) {
              return _notFoundPage('Measurement');
            }

            return MeasurementDetailsPage(
              measurement: measurement,
            );
          },
        ),

        // ================================================
        // APPOINTMENT MODULE
        // ================================================

        GoRoute(
          path: AppRoutes.appointments,
          builder: (context, state) {
            return const AppointmentPage();
          },
        ),

        GoRoute(
          path: AppRoutes.addAppointment,
          builder: (context, state) {
            return const AppointmentFormPage();
          },
        ),

        GoRoute(
          path: AppRoutes.editAppointment,
          builder: (context, state) {
            final appointment = state.extra;

            if (appointment is! AppointmentEntity) {
              return _notFoundPage('Appointment');
            }

            return AppointmentFormPage(
              appointment: appointment,
            );
          },
        ),

        GoRoute(
          path: AppRoutes.appointmentDetails,
          builder: (context, state) {
            final appointment = state.extra;

            if (appointment is! AppointmentEntity) {
              return _notFoundPage('Appointment');
            }

            return AppointmentDetailsPage(
              appointment: appointment,
            );
          },
        ),

        // ================================================
        // REPORTS MODULE
        // ================================================

        GoRoute(
          path: AppRoutes.reports,
          builder: (context, state) {
            return const ReportPage();
          },
        ),


      
          GoRoute(
            path: AppRoutes.team,
            builder: (context, state) => const TeamPage(),
          ),

           GoRoute(
            path: AppRoutes.workDistribution,
            builder: (context, state) => const WorkDistributionPage(),
          ),



            GoRoute(
            path: AppRoutes.assignWork,
            builder: (context, state) => const AssignWorkPage(),
          ),

          

            
          GoRoute(
            path: AppRoutes.addTeamMember,
            builder: (context, state) => const TeamFormPage(),
          ),

          GoRoute(
            path: AppRoutes.editTeamMember,
            builder: (context, state) {
              final member = state.extra;

              if (member is! TeamMemberEntity) {
                return const Scaffold(
                  body: Center(child: Text('Team member not found')),
                );
              }

              return TeamFormPage(member: member);
            },
          ),

          GoRoute(
            path: AppRoutes.teamMemberDetails,
            builder: (context, state) {
              final member = state.extra;

              if (member is! TeamMemberEntity) {
                return const Scaffold(
                  body: Center(child: Text('Team member not found')),
                );
              }

              return TeamDetailsPage(member: member);
            },
          ),




                GoRoute(
                path: AppRoutes.invoicePreview,
                name: 'invoicePreview',
                builder: (context, state) {
                  final invoice = state.extra is InvoiceEntity
                      ? state.extra as InvoiceEntity
                      : null;

                  final invoiceId = invoice?.id ??
                      state.uri.queryParameters['id'] ??
                      '';

                  return BlocProvider<InvoiceBloc>(
                    create: (_) => GetIt.instance<InvoiceBloc>(),
                    child: InvoicePreviewPage(
                      invoiceId: invoiceId,
                      initialInvoice: invoice,
                    ),
                  );
                },
              ),



        ],
        ),
      ],



      // ==================================================
      // GLOBAL ERROR PAGE
      // ==================================================
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Page Not Found'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.error?.toString() ??
                        'The requested page could not be found.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.dashboard);
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ====================================================
  // COMMON NOT FOUND PAGE
  // ====================================================

  static Widget _notFoundPage(String moduleName) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$moduleName Not Found'),
      ),
      body: Center(
        child: Text(
          '$moduleName details are not available.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ====================================================
  // DISPOSE
  // ====================================================

  void dispose() {
    router.dispose();
    notifier.dispose();
  }
}
