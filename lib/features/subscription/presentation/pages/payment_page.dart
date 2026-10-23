import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/subscription_bloc.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final utrController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  static const merchantUpi = 'merchant@upi';

  @override
  void dispose() {
    utrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubscriptionBloc>().state;
    final plan = state.selectedPlan;

    if (plan == null) {
      return const Scaffold(
        body: Center(child: Text('No subscription selected')),
      );
    }

    final qrData = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': merchantUpi,
        'pn': 'TailorPro',
        'am': plan.price.toStringAsFixed(2),
        'cu': 'INR',
        'tn': '${plan.name} Subscription',
      },
    ).toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context
              .read<SubscriptionBloc>()
              .add(LoadPlansEvent()),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.qr_code_2,
                            size: 36,
                            color: AppColors.gold,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Scan & Pay',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${plan.name} Subscription'),
                          const SizedBox(height: 8),
                          Text(
                            '₹${plan.price}',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 15),
                          QrImageView(
                            data: qrData,
                            size: 210,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Scan with a UPI payment app',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            merchantUpi,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'UPI Transaction ID / UTR',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: utrController,
                            decoration: const InputDecoration(
                              hintText: 'Enter transaction reference',
                              prefixIcon: Icon(
                                Icons.receipt_long_outlined,
                              ),
                            ),
                            validator: (value) =>
                                value == null ||
                                        value.trim().length < 6
                                    ? 'Enter a valid UTR'
                                    : null,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Demo mode: Payment is not verified. '
                            'Submitting a reference activates '
                            'the demo plan.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            title: 'Submit Payment',
                            loading: state.status ==
                                SubscriptionStatus.loading,
                            onTap: () {
                              if (!formKey.currentState!
                                  .validate()) return;

                              context
                                  .read<SubscriptionBloc>()
                                  .add(
                                    SubmitPaymentEvent(
                                      utrController.text.trim(),
                                    ),
                                  );
                            },
                          ),
                          if (state.status ==
                              SubscriptionStatus.failure)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                state.message,
                                style: const TextStyle(
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}