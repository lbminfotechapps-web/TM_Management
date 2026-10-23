
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

import '../../domain/entities/subscription_entity.dart';
import '../bloc/subscription_bloc.dart';
import '../widgets/plan_card.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() =>
      _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedId = 'pro';

  void _continueToPayment(List<SubscriptionEntity> plans) {
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subscription plans available'),
        ),
      );
      return;
    }

    // Find the selected plan safely.
    // indexWhere avoids firstWhere's orElse type mismatch.
    final selectedIndex = plans.indexWhere(
      (plan) => plan.id == selectedId,
    );

    // Default to first plan if selected plan was not found.
    final SubscriptionEntity selectedPlan =
        selectedIndex >= 0
            ? plans[selectedIndex]
            : plans.first;

    // Send selected plan to SubscriptionBloc.
    context.read<SubscriptionBloc>().add(
      SelectPlanEvent(selectedPlan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<SubscriptionBloc>().add(
                LoadPlansEvent(),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Plans',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            // Loading
            if (state.status == SubscriptionStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                ),
              );
            }

            // Error
            if (state.status == SubscriptionStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.red,
                        size: 45,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        title: 'Try Again',
                        onTap: () {
                          context.read<SubscriptionBloc>().add(
                            LoadPlansEvent(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            // Empty plans
            if (state.plans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_outlined,
                        color: AppColors.gold,
                        size: 50,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No Subscription Plans Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        title: 'Load Plans',
                        onTap: () {
                          context.read<SubscriptionBloc>().add(
                            LoadPlansEvent(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20, 8, 20, 18,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.primary,
                          size: 31,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Find Your Perfect Plan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Simple pricing for every tailoring business',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Subscription cards
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    itemCount: state.plans.length,
                    itemBuilder: (context, index) {
                      final plan = state.plans[index];

                      return PlanCard(
                        plan: plan,
                        selected: selectedId == plan.id,
                        onTap: () {
                          setState(() {
                            selectedId = plan.id;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Bottom button
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    18, 12, 18, 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFECE3D8),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.green,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Select a plan to continue',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      AppButton(
                        title: 'Continue to Payment →',
                        onTap: () {
                          _continueToPayment(
                            List<SubscriptionEntity>.from(
                              state.plans,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
