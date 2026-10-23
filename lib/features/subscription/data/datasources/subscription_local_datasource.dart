import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription_model.dart';

abstract class SubscriptionLocalDataSource {
  Future<List<SubscriptionModel>> getPlans();
  Future<SubscriptionModel?> getActivePlan();
  Future<void> activatePlan(String planId);
  Future<void> clearActivePlan();
}

class SubscriptionLocalDataSourceImpl
    implements SubscriptionLocalDataSource {
  final SharedPreferencesAsync prefs;

  SubscriptionLocalDataSourceImpl(this.prefs);
  static final List<Map<String, dynamic>> demoPlans = [
    {
      'id': 'basic',
      'name': 'Basic',
      'price': 499,
      'customer_limit': 20,
      'benefits': [
        '20 Customers',
        'Order Management',
        'Body Measurements',
        'Basic Dashboard',
      ],
      'features': [
        'customers',
        'orders',
        'measurements',
      ],
    },
    {
      'id': 'pro',
      'name': 'Pro',
      'price': 1100,
      'customer_limit': 200,
      'benefits': [
        '200 Customers',
        'Unlimited Orders',
        'Body Measurements',
        'Appointments',
        'Advanced Reports',
      ],
      'features': [
        'customers',
        'orders',
        'measurements',
        'appointments',
        'reports',
      ],
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'price': 2600,
      'customer_limit': -1,
      'benefits': [
        'Unlimited Customers',
        'All Pro Features',
        'Team Management',
        'Priority Support',
        'Work Distribution',
      ],
      'features': [
        'customers',
        'orders',
        'measurements',
        'appointments',
        'reports',
        'team',
        'workDistribution',
      ],
    },
  ];

  @override
  Future<List<SubscriptionModel>> getPlans() async {
    return demoPlans
        .map((json) => SubscriptionModel.fromJson(json))
        .toList();
  }

  @override
  Future<SubscriptionModel?> getActivePlan() async {
    final id = await prefs.getString('active_plan_id');

    if (id == null) return null;
    final plans = await getPlans();

    for (final plan in plans) {
      if (plan.id == id) return plan;
    }

    return null;
  }

  @override
  Future<void> activatePlan(String planId) async {
    final plans = await getPlans();

    if (!plans.any((plan) => plan.id == planId)) {
      throw Exception('Invalid subscription plan');
    }

    await prefs.setString('active_plan_id', planId);
  }

  @override
  Future<void> clearActivePlan() async {
    await prefs.remove('active_plan_id');
  }
}