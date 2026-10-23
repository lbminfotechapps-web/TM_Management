import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../router/app_routes.dart';
import '../../features/subscription/domain/entities/subscription_entity.dart';
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _brown = Color(0xFF392619);
  static const _gold = Color(0xFFC28E3D);
  static const _canvas = Color(0xFFFAF7F2);
  static const _line = Color(0xFFEFE7DB);

  @override
  Widget build(BuildContext context) {
    final plan = context.select<SubscriptionBloc, SubscriptionEntity?>(
      (bloc) => bloc.state.activePlan,
    );
    return Scaffold(
      backgroundColor: _canvas,
      resizeToAvoidBottomInset: false,
      body: widget.child,
      bottomNavigationBar: plan == null ? null : _bottomBar(plan),
    );
  }
  void _openFeature(SubscriptionEntity plan, SubscriptionFeature feature,
      String route, String title) {
    if (plan.canAccess(feature)) {
      if (route == AppRoutes.addOrder) {
        context.push(route);
      } else {
        context.go(route);
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upgrade your subscription to access $title')),
    );
  }

  void _showMore(SubscriptionEntity plan) {
    final items = <(String, IconData, SubscriptionFeature, String)>[
      ('Measurements', Icons.straighten_rounded,
          SubscriptionFeature.measurements, AppRoutes.measurements),
      ('Appointments', Icons.event_available_outlined,
          SubscriptionFeature.appointments, AppRoutes.appointments),
      ('Reports', Icons.insert_chart_outlined_rounded,
          SubscriptionFeature.reports, AppRoutes.reports),
      ('Team', Icons.groups_2_outlined,
          SubscriptionFeature.team, AppRoutes.team),

       ('Work Distribution', Icons.groups_2_outlined,
          SubscriptionFeature.workDistribution, AppRoutes.workDistribution),    
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _canvas,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Explore features', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: _brown)),
            ),
            const SizedBox(height: 12),
            for (final item in items)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                leading: Icon(item.$2, color: _gold),
                title: Text(item.$1, style: const TextStyle(
                    color: _brown, fontWeight: FontWeight.w600)),
                trailing: Icon(plan.canAccess(item.$3)
                    ? Icons.chevron_right : Icons.lock_outline, size: 20),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openFeature(plan, item.$3, item.$4, item.$1);
                },
              ),
          ]),
        ),
      ),
    );
  }

  Widget _bottomBar(SubscriptionEntity plan) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 7),
      decoration: const BoxDecoration(color: Colors.white,
          border: Border(top: BorderSide(color: _line))),
      child: Row(children: [
        _navItem(Icons.home_rounded, 'Home', selected: widget.location == AppRoutes.dashboard,
          onTap: () => context.go(AppRoutes.dashboard)),
        _navItem(Icons.shopping_bag_outlined, 'Orders', selected: widget.location.startsWith(AppRoutes.orders),
          onTap: () => _openFeature(plan, SubscriptionFeature.orders,
              AppRoutes.orders, 'Orders')),
        Expanded(flex: 2, child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _gold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12,
                  horizontal: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
            onPressed: () => _openFeature(plan, SubscriptionFeature.orders,
                AppRoutes.addOrder, 'Create order'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New', style: TextStyle(fontSize: 12)),
          ),
        )),
        _navItem(Icons.people_outline, 'Customers', selected: widget.location.startsWith(AppRoutes.customers),
          onTap: () => _openFeature(plan, SubscriptionFeature.customers,
              AppRoutes.customers, 'Customers')),
        _navItem(Icons.grid_view_rounded, 'More', selected: ![AppRoutes.dashboard, AppRoutes.orders, AppRoutes.customers].any((route) => widget.location == route || widget.location.startsWith('$route/')),
          onTap: () => _showMore(plan)),
      ]),
    ),
  );

  Widget _navItem(IconData icon, String label,
      {required VoidCallback onTap, bool selected = false}) => Expanded(
    child: InkWell(onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: selected ? _gold : AppColors.muted, size: 22),
          const SizedBox(height: 3),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, fontWeight: selected
                ? FontWeight.w800 : FontWeight.w500,
                color: selected ? _gold : AppColors.muted)),
        ]),
      ),
    ),
  );
}

