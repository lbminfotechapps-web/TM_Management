part of 'subscription_bloc.dart';


sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlansEvent extends SubscriptionEvent {}

class CheckActivePlanEvent extends SubscriptionEvent {}

class SelectPlanEvent extends SubscriptionEvent {
  final SubscriptionEntity plan;

  const SelectPlanEvent(this.plan);

  @override
  List<Object?> get props => [plan];
}

class SubmitPaymentEvent extends SubscriptionEvent {
  final String utr;

  const SubmitPaymentEvent(this.utr);

  @override
  List<Object?> get props => [utr];
}

class ClearSubscriptionEvent extends SubscriptionEvent {}