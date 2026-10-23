part of 'subscription_bloc.dart';


enum SubscriptionStatus {
  initial,
  loading,
  plansLoaded,
  paymentRequired,
  active,
  failure,
}

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final List<SubscriptionEntity> plans;
  final SubscriptionEntity? selectedPlan;
  final SubscriptionEntity? activePlan;
  final String message;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.plans = const [],
    this.selectedPlan,
    this.activePlan,
    this.message = '',
  });

  @override
  List<Object?> get props => [
    status, plans, selectedPlan, activePlan, message,
  ];
}