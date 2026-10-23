import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/get_active_plan_usecase.dart';
import '../../domain/usecases/activate_plan_usecase.dart';
import '../../domain/repositories/subscription_repository.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc
    extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetPlansUseCase getPlans;
  final GetActivePlanUseCase getActivePlan;
  final ActivatePlanUseCase activatePlan;
  final SubscriptionRepository repository;

  SubscriptionBloc({
    required this.getPlans,
    required this.getActivePlan,
    required this.activatePlan,
    required this.repository,
  }) : super(const SubscriptionState()) {
    on<LoadPlansEvent>(_loadPlans);
    on<CheckActivePlanEvent>(_checkPlan);
    on<SelectPlanEvent>(_selectPlan);
    on<SubmitPaymentEvent>(_submitPayment);
    on<ClearSubscriptionEvent>(_clearPlan);
  }

  Future<void> _loadPlans(
    LoadPlansEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionState(
      status: SubscriptionStatus.loading,
    ));

    try {
      final plans = await getPlans(const NoParams());

      emit(SubscriptionState(
        status: SubscriptionStatus.plansLoaded,
        plans: plans,
      ));
    } catch (e) {
      emit(SubscriptionState(
        status: SubscriptionStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _checkPlan(
    CheckActivePlanEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionState(
      status: SubscriptionStatus.loading,
    ));

    try {
      final plan = await getActivePlan(const NoParams());

      if (plan != null) {
        emit(SubscriptionState(
          status: SubscriptionStatus.active,
          activePlan: plan,
        ));
      } else {
        final plans = await getPlans(const NoParams());

        emit(SubscriptionState(
          status: SubscriptionStatus.plansLoaded,
          plans: plans,
        ));
      }
    } catch (e) {
      emit(SubscriptionState(
        status: SubscriptionStatus.failure,
        message: e.toString(),
      ));
    }
  }

  void _selectPlan(
    SelectPlanEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(SubscriptionState(
      status: SubscriptionStatus.paymentRequired,
      plans: state.plans,
      selectedPlan: event.plan,
      activePlan: state.activePlan,
    ));
  }

  Future<void> _submitPayment(
    SubmitPaymentEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final plan = state.selectedPlan;

    if (plan == null) {
      emit(SubscriptionState(
        status: SubscriptionStatus.failure,
        plans: state.plans,
        message: 'Please select a subscription',
      ));
      return;
    }

    if (event.utr.trim().length < 6) {
      emit(SubscriptionState(
        status: SubscriptionStatus.failure,
        plans: state.plans,
        selectedPlan: plan,
        message: 'Enter a valid UTR reference',
      ));
      return;
    }

    emit(SubscriptionState(
      status: SubscriptionStatus.loading,
      plans: state.plans,
      selectedPlan: plan,
    ));

    try {
      // STATIC DEMO ONLY.
      // This does not check whether a payment succeeded.
      await activatePlan(plan.id);

      emit(SubscriptionState(
        status: SubscriptionStatus.active,
        activePlan: plan,
        message: 'Demo subscription activated',
      ));
    } catch (e) {
      emit(SubscriptionState(
        status: SubscriptionStatus.failure,
        selectedPlan: plan,
        plans: state.plans,
        message: e.toString(),
      ));
    }
  }

  Future<void> _clearPlan(
    ClearSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    await repository.clearActivePlan();

    emit(const SubscriptionState());
  }
}