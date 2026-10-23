import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../subscription/domain/entities/subscription_entity.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _brown = Color(0xFF392619);
  static const _gold = Color(0xFFC28E3D);
  static const _canvas = Color(0xFFFAF7F2);
  static const _line = Color(0xFFEFE7DB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<DashboardBloc>();
      if (bloc.state.status == DashboardStatus.initial) {
        bloc.add(LoadDashboardEvent());
      }
    });
  }

  Future<void> _refresh() async {
    final bloc = context.read<DashboardBloc>();
    final prior = bloc.state;
    bloc.add(LoadDashboardEvent());
    await bloc.stream.firstWhere((s) =>
        (s.status == DashboardStatus.success ||
            s.status == DashboardStatus.failure) &&
        !identical(s, prior));
  }

  void _openFeature(SubscriptionEntity plan, SubscriptionFeature feature,
      String route, String title) {
    if (plan.canAccess(feature)) {
      context.push(route);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upgrade your subscription to access $title')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = context.select<SubscriptionBloc, SubscriptionEntity?>(
      (bloc) => bloc.state.activePlan,
    );
    final userName = context.select<AuthBloc, String>(
      (bloc) => bloc.state.user?.name ?? 'Tailor',
    );

    if (plan == null) {
      return const Scaffold(body: Center(child: Text('No active subscription')));
    }

    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if ((state.status == DashboardStatus.loading ||
                    state.status == DashboardStatus.initial) &&
                state.dashboard == null) {
              return const Center(child: CircularProgressIndicator(color: _gold));
            }
            if (state.dashboard == null) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message.isEmpty ? 'Unable to load dashboard' : state.message),
                  TextButton(onPressed: () => context.read<DashboardBloc>()
                      .add(LoadDashboardEvent()), child: const Text('Try again')),
                ],
              ));
            }
            final data = state.dashboard!;
            return RefreshIndicator(
              color: _gold,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _header(userName)),
                  SliverToBoxAdapter(child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 940),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 16, 15, 24),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _welcome(userName),
                            const SizedBox(height: 14),
                            _balanceBanner(data, plan),
                            const SizedBox(height: 18),
                            _sectionTitle('Business overview', 'A quick look at your work',
                                Icons.insights_outlined),
                            const SizedBox(height: 6),
                            _metrics(data),
                            const SizedBox(height: 14),
                            _sectionTitle('Quick access', 'Run your business faster',
                                Icons.grid_view_rounded),
                            const SizedBox(height: 10),
                            _quickAccess(plan),
                            const SizedBox(height: 20),
                            _sectionTitle('Today’s appointments', 'Upcoming fittings and visits',
                                Icons.event_note_outlined,
                                onSeeAll: plan.canAccess(SubscriptionFeature.appointments)
                                    ? () => context.push(AppRoutes.appointments) : null),
                            const SizedBox(height: 10),
                            _appointments(data.appointments, plan),
                            const SizedBox(height: 20),
                            _sectionTitle('Recent orders', 'Your latest stitching work',
                                Icons.receipt_long_outlined,
                                onSeeAll: plan.canAccess(SubscriptionFeature.orders)
                                    ? () => context.push(AppRoutes.orders) : null),
                            const SizedBox(height: 10),
                            _recentOrders(plan),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            );
          },
        ),
      ),

    );
  }

  Widget _header(String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 10, 12, 13),
      decoration: const BoxDecoration(color: _brown,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22))),
      child: Row(children: [
        Container(height: 40, width: 40,
          decoration: BoxDecoration(color: _gold,
              borderRadius: BorderRadius.circular(13)),
          child: const Icon(Icons.content_cut_rounded, color: Colors.white)),
        const SizedBox(width: 11),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TailorPro', style: TextStyle(fontSize: 20, color: Colors.white,
                fontWeight: FontWeight.w900)),
            Text('Business workspace', style: TextStyle(
                fontSize: 10, color: Colors.white70)),
          ],
        )),
        IconButton(tooltip: 'Notifications',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications coming soon'))),
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
        PopupMenuButton<String>(
          icon: CircleAvatar(radius: 18, backgroundColor: const Color(0xFFF6E6CC),
            child: Text(name.isEmpty ? 'T' : name[0].toUpperCase(),
              style: const TextStyle(color: _brown, fontWeight: FontWeight.w800))),
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthBloc>().add(LogoutRequestedEvent());
            } else {
              context.read<SubscriptionBloc>().add(LoadPlansEvent());
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'subscription', child: Text('Subscription plans')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
      ]),
    );
  }

  Widget _welcome(String name) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Hello, $name 👋', maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900,
            color: _brown, letterSpacing: -.4)),
      const SizedBox(height: 3),
      Text(DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
    ],
  );

  Widget _balanceBanner(DashboardEntity data, SubscriptionEntity plan) {
    final money = NumberFormat.decimalPattern('en_IN');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_brown, Color(0xFF75502F)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 18, color: Color(0xFFF1CF93)),
          const SizedBox(width: 7),
          const Expanded(child: Text('BUSINESS REVENUE', style: TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w700,
              fontSize: 10, letterSpacing: 1))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: Colors.white12,
                borderRadius: BorderRadius.circular(9)),
            child: Text('${plan.name} Plan', style: const TextStyle(
                fontSize: 10, color: Color(0xFFF1CF93),
                fontWeight: FontWeight.w700))),
        ]),
       
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text('₹${money.format(data.revenue)}', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
     
        
      ]),
    );
  }

  Widget _sectionTitle(String title, String subtitle, IconData icon,
      {VoidCallback? onSeeAll}) => Row(children: [
    Container(width: 35, height: 35,
      decoration: BoxDecoration(color: const Color(0xFFF4E7D2),
          borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, color: _brown, size: 19)),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: _brown,
            fontWeight: FontWeight.w800, fontSize: 15)),
        Text(subtitle, style: const TextStyle(
            fontSize: 10.5, color: AppColors.muted)),
      ],
    )),
    if (onSeeAll != null) TextButton(onPressed: onSeeAll,
      style: TextButton.styleFrom(foregroundColor: _gold,
          padding: const EdgeInsets.symmetric(horizontal: 6)),
      child: const Text('See all', style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.w800))),
  ]);

  Widget _metrics(DashboardEntity data) {
    final metrics = <(String, int, Color)>[
      ('Total orders', data.totalOrders, _brown),
      ('Customers', data.totalCustomers, _brown),
      ('Pending', data.pendingOrders, const Color(0xFFAA6B20)),
      ('Completed',
        (data.totalOrders - data.pendingOrders).clamp(0, data.totalOrders).toInt(),
        const Color(0xFF278B66)),
    ];
    final number = NumberFormat.decimalPattern('en_IN');
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(color: _brown.withValues(alpha: .035),
            blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(10) / 10;
        final minimumWidth = 280.0 * textScale;
        final width = constraints.maxWidth < minimumWidth
            ? minimumWidth : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: const TableBorder(
                verticalInside: BorderSide(color: _line),
                horizontalInside: BorderSide(color: _line),
              ),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF1E2CC)),
                  children: [
                    for (final metric in metrics)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Text(metric.$1, textAlign: TextAlign.center,
                          style: const TextStyle(color: _brown, fontSize: 9,
                            fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                TableRow(children: [
                  for (final metric in metrics)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
                      child: Semantics(
                        label: '${metric.$1}: ${number.format(metric.$2)}',
                        excludeSemantics: true,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(number.format(metric.$2),
                            style: TextStyle(color: metric.$3, fontSize: 18,
                              fontWeight: FontWeight.w800, letterSpacing: -.4)),
                        ),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }
  Widget _quickAccess(SubscriptionEntity plan) {
    final items = <(String, IconData, SubscriptionFeature, String)>[
      ('Customers', Icons.people_alt_outlined,
          SubscriptionFeature.customers, AppRoutes.customers),
      ('Orders', Icons.shopping_bag_outlined,
          SubscriptionFeature.orders, AppRoutes.orders),
      ('Measurements', Icons.straighten_rounded,
          SubscriptionFeature.measurements, AppRoutes.measurements),
      ('Appointments', Icons.event_note_outlined,
          SubscriptionFeature.appointments, AppRoutes.appointments),
      ('Reports', Icons.insert_chart_outlined_rounded,
          SubscriptionFeature.reports, AppRoutes.reports),
      ('Team', Icons.groups_2_outlined,
          SubscriptionFeature.team, AppRoutes.team),
      ('Work Distribution', Icons.groups_2_outlined,
          SubscriptionFeature.workDistribution, AppRoutes.workDistribution),
    ];
    
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 750 ? 6 : 3;
      const spacing = 9.0;
      final width = (constraints.maxWidth - (columns - 1) * spacing) / columns;
      return Wrap(spacing: spacing, runSpacing: spacing, children: [
        for (final item in items)
          SizedBox(width: width, child: _FeatureShortcut(
            title: item.$1,
            icon: item.$2,
            enabled: plan.canAccess(item.$3),
            onTap: () => _openFeature(plan, item.$3, item.$4, item.$1),
          )),
      ]);
    });
  }

  Widget _appointments(List<dynamic> items, SubscriptionEntity plan) {
    if (!plan.canAccess(SubscriptionFeature.appointments)) {
      return _panel(child: const Row(children: [
        Icon(Icons.lock_outline, color: _gold), SizedBox(width: 10),
        Expanded(child: Text('Upgrade your plan to view appointments')),
      ]));
    }
    if (items.isEmpty) {
      return _panel(child: const Text('No appointments scheduled',
          style: TextStyle(color: AppColors.muted, fontSize: 12)));
    }
    return _panel(child: Column(children: [
      for (var index = 0; index < items.length && index < 3; index++) ...[
        InkWell(
          onTap: () => context.push(AppRoutes.appointments),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Container(width: 37, height: 37,
                decoration: BoxDecoration(color: const Color(0xFFF5E7D1),
                    borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.schedule, color: _gold, size: 19)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(items[index].name.toString(),
                    style: const TextStyle(color: _brown,
                        fontWeight: FontWeight.w800, fontSize: 12)),
                  Text(items[index].description.toString(), maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                ],
              )),
              Text(items[index].time.toString(),
                style: const TextStyle(color: _gold,
                    fontWeight: FontWeight.w800, fontSize: 10)),
            ]),
          ),
        ),
        if (index != items.length - 1 && index != 2)
          const Divider(height: 12, color: _line),
      ],
    ]));
  }

  Widget _recentOrders(SubscriptionEntity plan) {
    if (!plan.canAccess(SubscriptionFeature.orders)) {
      return _panel(child: const Text('Upgrade to view orders'));
    }
    const samples = <(String, String, String)>[
      ('#ORD-00124', 'Designer Blouse', 'Stitching'),
      ('#ORD-00125', 'Men Suit', 'Cutting'),
      ('#ORD-00126', 'Wedding Lehenga', 'Trial'),
    ];
    return _panel(child: Column(children: [
      for (var i = 0; i < samples.length; i++) ...[
        InkWell(onTap: () => context.push(AppRoutes.orders),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Container(width: 37, height: 37,
                decoration: BoxDecoration(color: const Color(0xFFF5E7D1),
                    borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.checkroom_outlined, size: 19,
                    color: _brown)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(samples[i].$1, style: const TextStyle(
                      color: _brown, fontWeight: FontWeight.w800, fontSize: 12)),
                  Text(samples[i].$2, style: const TextStyle(
                      color: AppColors.muted, fontSize: 10)),
                ],
              )),
              Text(samples[i].$3, style: const TextStyle(
                  color: _gold, fontSize: 10, fontWeight: FontWeight.w800)),
            ]),
          )),
        if (i < samples.length - 1) const Divider(height: 12, color: _line),
      ],
    ]));
  }

  Widget _panel({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line)),
    child: child,
  );

}

class _FeatureShortcut extends StatelessWidget {
  const _FeatureShortcut({required this.title, required this.icon,
      required this.enabled, required this.onTap});

  final String title;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 91,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEFE7DB)),
          borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(width: 39, height: 39,
              decoration: BoxDecoration(color: const Color(0xFFF6E8D3),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF9D6B28), size: 21)),
            if (!enabled) const Positioned(right: -5, top: -5,
              child: Icon(Icons.lock, color: Colors.grey, size: 13)),
          ]),
          const SizedBox(height: 7),
          FittedBox(fit: BoxFit.scaleDown,
            child: Text(title, maxLines: 1,
              style: const TextStyle(color: Color(0xFF392619),
                  fontWeight: FontWeight.w700, fontSize: 11))),
        ]),
      ),
    ),
  );
}
