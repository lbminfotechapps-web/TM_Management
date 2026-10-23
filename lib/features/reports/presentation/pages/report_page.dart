
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/report_bloc.dart';
import '../widgets/report_stat_card.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late DateTime fromDate;
  late DateTime toDate;

  static const _brown = Color(0xFF392417);
  static const _gold = Color(0xFFBD8A47);
  static const _muted = Color(0xFF8B8178);
  static const _border = Color(0xFFEDE6DE);
  static const _green = Color(0xFF26866A);
  static const _red = Color(0xFFD35555);
  static const _blue = Color(0xFF487CB6);

  final money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    fromDate = DateTime(now.year, now.month, 1);
    toDate = DateTime(now.year, now.month + 1, 0);

    _load();
  }

  void _load() {
    context.read<ReportBloc>().add(
      LoadReportEvent(
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  Future<void> _chooseRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: fromDate,
        end: toDate,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      fromDate = result.start;
      toDate = result.end;
    });

    _load();
  }

  Future<void> _refresh() async {
    final bloc = context.read<ReportBloc>();
    final oldRevision = bloc.state.revision;

    _load();

    await bloc.stream.firstWhere(
      (state) =>
          state.revision > oldRevision &&
          (state.status == ReportStatus.success ||
              state.status == ReportStatus.failure),
    );
  }

  double _ratio(num value, num total) {
    if (total <= 0) return 0;

    return (value / total).clamp(0.0, 1.0).toDouble();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'received':
        return const Color(0xFF64748B);
      case 'cutting':
        return const Color(0xFF3B82F6);
      case 'stitching':
        return _gold;
      case 'trial':
        return const Color(0xFF8B5CF6);
      case 'ready':
        return const Color(0xFF0D9488);
      case 'delivered':
        return _green;
      case 'cancelled':
        return _red;
      default:
        return _blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Business Reports',
          style: TextStyle(
            color: _brown,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh report',
            onPressed: _load,
            icon: const Icon(
              Icons.refresh_rounded,
              color: _brown,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          final report = state.report;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 950,
                ),
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    14, 8, 14, 28,
                  ),
                  children: [
                    // ==============================
                    // COMPACT HEADER
                    // ==============================

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            _brown,
                            Color(0xFF79512E),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.insights_rounded,
                                color: Color(0xFFF2CD96),
                                size: 22,
                              ),
                              SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Business Performance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Financial, orders & customer analytics',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Material(
                            color: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius.circular(9),
                            child: InkWell(
                              onTap: _chooseRange,
                              borderRadius:
                                  BorderRadius.circular(9),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${DateFormat('dd MMM yy').format(fromDate)}'
                                        '  –  '
                                        '${DateFormat('dd MMM yy').format(toDate)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (state.status == ReportStatus.loading)
                      const Padding(
                        padding: EdgeInsets.all(35),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    if (state.status == ReportStatus.failure)
                      _Panel(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 32,
                              color: _red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),

                    if (report != null &&
                        state.status == ReportStatus.success) ...[
                      // ==============================
                      // KPI OVERVIEW
                      // ==============================

                      const _SectionTitle(
                        title: 'Financial Overview',
                        icon: Icons.account_balance_wallet_outlined,
                      ),

                      const SizedBox(height: 9),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns =
                              constraints.maxWidth >= 650 ? 4 : 2;

                          final collectionRatio = _ratio(
                            report.advanceCollected,
                            report.totalOrderValue,
                          );

                          final dueRatio = _ratio(
                            report.balanceDue,
                            report.totalOrderValue,
                          );

                          return GridView.count(
                            crossAxisCount: columns,
                            crossAxisSpacing: 9,
                            mainAxisSpacing: 9,
                            mainAxisExtent: 118,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            children: [
                              ReportStatCard(
                                title: 'Order Value',
                                value: money.format(
                                  report.totalOrderValue,
                                ),
                                icon: Icons.wallet_outlined,
                                color: _green,
                                progress: 1,
                              ),
                              ReportStatCard(
                                title: 'Advance Collected',
                                value: money.format(
                                  report.advanceCollected,
                                ),
                                icon: Icons.payments_outlined,
                                color: _gold,
                                progress: collectionRatio,
                              ),
                              ReportStatCard(
                                title: 'Balance Due',
                                value: money.format(
                                  report.balanceDue,
                                ),
                                icon: Icons.pending_actions_rounded,
                                color: _red,
                                progress: dueRatio,
                              ),
                              ReportStatCard(
                                title: 'Total Orders',
                                value: '${report.totalOrders}',
                                icon: Icons.shopping_bag_outlined,
                                color: _blue,
                                progress: _ratio(
                                  report.deliveredOrders,
                                  report.totalOrders,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 17),

                      // ==============================
                      // PAYMENT DISTRIBUTION CHART
                      // ==============================

                      const _SectionTitle(
                        title: 'Payment Distribution',
                        icon: Icons.donut_large_rounded,
                      ),

                      const SizedBox(height: 9),

                      _Panel(
                        child: _PaymentChart(
                          collected: report.advanceCollected,
                          due: report.balanceDue,
                          money: money,
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==============================
                      // CUSTOMER & ORDER OVERVIEW
                      // ==============================

                      const _SectionTitle(
                        title: 'Customer & Order Summary',
                        icon: Icons.people_outline_rounded,
                      ),

                      const SizedBox(height: 9),

                      _Panel(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    title: 'All Customers',
                                    value:
                                        '${report.totalCustomers}',
                                    icon: Icons.people_alt_outlined,
                                    color: _blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MiniStat(
                                    title: 'New Customers',
                                    value:
                                        '${report.newCustomers}',
                                    icon: Icons.person_add_alt_outlined,
                                    color: _green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    title: 'Pending Orders',
                                    value:
                                        '${report.pendingOrders}',
                                    icon: Icons.hourglass_empty_rounded,
                                    color: _gold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MiniStat(
                                    title: 'Delivered',
                                    value:
                                        '${report.deliveredOrders}',
                                    icon: Icons.task_alt_rounded,
                                    color: _green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _SummaryLine(
                              title: 'Cancelled Orders',
                              value: '${report.cancelledOrders}',
                              color: _red,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==============================
                      // APPOINTMENTS
                      // ==============================

                      const _SectionTitle(
                        title: 'Appointments',
                        icon: Icons.event_available_outlined,
                      ),

                      const SizedBox(height: 9),

                      _Panel(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    title: 'Total',
                                    value:
                                        '${report.totalAppointments}',
                                    icon: Icons.calendar_month_outlined,
                                    color: _blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MiniStat(
                                    title: 'Upcoming',
                                    value:
                                        '${report.upcomingAppointments}',
                                    icon: Icons.schedule_rounded,
                                    color: _gold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    title: 'Completed',
                                    value:
                                        '${report.completedAppointments}',
                                    icon: Icons.check_circle_outline,
                                    color: _green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MiniStat(
                                    title: 'Cancelled',
                                    value:
                                        '${report.cancelledAppointments}',
                                    icon: Icons.cancel_outlined,
                                    color: _red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==============================
                      // ORDER STATUS BAR CHART
                      // ==============================

                      const _SectionTitle(
                        title: 'Orders by Status',
                        icon: Icons.bar_chart_rounded,
                      ),

                      const SizedBox(height: 9),

                      _Panel(
                        child: _BarChart(
                          data: report.orderStatusCounts,
                          colorFor: _statusColor,
                          emptyMessage: 'No order data available',
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==============================
                      // GARMENT QUANTITY CHART
                      // ==============================

                      const _SectionTitle(
                        title: 'Garment-wise Quantities',
                        icon: Icons.checkroom_outlined,
                      ),

                      const SizedBox(height: 9),

                      _Panel(
                        child: _BarChart(
                          data: report.garmentCounts,
                          colorFor: (_) => _gold,
                          emptyMessage:
                              'No garment orders in selected period',
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// SECTION TITLE
// ==========================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF79512E),
          size: 18,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF392417),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// COMMON PANEL
// ==========================================

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEDE6DE),
        ),
      ),
      child: child,
    );
  }
}

// ==========================================
// COMPACT MINI STAT
// ==========================================

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF392417),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8B8178),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SUMMARY LINE
// ==========================================

class _SummaryLine extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryLine({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8B8178),
              fontSize: 11,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF392417),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// PAYMENT CHART
// ==========================================

class _PaymentChart extends StatelessWidget {
  final num collected;
  final num due;
  final NumberFormat money;

  const _PaymentChart({
    required this.collected,
    required this.due,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    final total = collected + due;

    final collectedRatio = total > 0
        ? (collected / total).clamp(0.0, 1.0).toDouble()
        : 0.0;

    final dueRatio = total > 0
        ? (due / total).clamp(0.0, 1.0).toDouble()
        : 0.0;

    const green = Color(0xFF26866A);
    const red = Color(0xFFD35555);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 102,
              height: 102,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: collectedRatio,
                      strokeWidth: 11,
                      strokeCap: StrokeCap.round,
                      backgroundColor: total > 0
                          ? red
                          : const Color(0xFFEDE6DE),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        green,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(collectedRatio * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFF392417),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Collected',
                        style: TextStyle(
                          color: Color(0xFF8B8178),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(
                    color: green,
                    title: 'Collected',
                    value: money.format(collected),
                    percent: collectedRatio,
                  ),

                  const SizedBox(height: 13),

                  _LegendItem(
                    color: red,
                    title: 'Balance Due',
                    value: money.format(due),
                    percent: dueRatio,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Text(
          'Collection Breakdown',
          style: TextStyle(
            color: Color(0xFF8B8178),
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (collectedRatio > 0)
                  Expanded(
                    flex: (collectedRatio * 10000)
                        .round()
                        .clamp(1, 10000),
                    child: Container(color: green),
                  ),
                if (dueRatio > 0)
                  Expanded(
                    flex: (dueRatio * 10000)
                        .round()
                        .clamp(1, 10000),
                    child: Container(color: red),
                  ),
                if (total <= 0)
                  Expanded(
                    child: Container(
                      color: const Color(0xFFEDE6DE),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// CHART LEGEND
// ==========================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String value;
  final double percent;

  const _LegendItem({
    required this.color,
    required this.title,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8B8178),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF392417),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        Text(
          '${(percent * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// DYNAMIC HORIZONTAL BAR CHART
// ==========================================

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  final Color Function(String) colorFor;
  final String emptyMessage;

  const _BarChart({
    required this.data,
    required this.colorFor,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(
              color: Color(0xFF8B8178),
              fontSize: 11,
            ),
          ),
        ),
      );
    }

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = entries
        .map((e) => e.value)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _BarRow(
            title: entries[i].key,
            value: entries[i].value,
            maxValue: maxValue,
            color: colorFor(entries[i].key),
          ),
          if (i != entries.length - 1)
            const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ==========================================
// CHART ROW
// ==========================================

class _BarRow extends StatelessWidget {
  final String title;
  final int value;
  final int maxValue;
  final Color color;

  const _BarRow({
    required this.title,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxValue > 0
        ? (value / maxValue).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF392417),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFF392417),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: const Color(0xFFF3EEE8),
            valueColor: AlwaysStoppedAnimation<Color>(
              color,
            ),
          ),
        ),
      ],
    );
  }
}
