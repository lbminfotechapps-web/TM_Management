
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorpro_clean/core/router/app_routes.dart';
import 'package:intl/intl.dart';
import 'team_work_list_page.dart';

class WorkDistributionPage extends StatefulWidget {
  const WorkDistributionPage({super.key});

  @override
  State<WorkDistributionPage> createState() =>
      _WorkDistributionPageState();
}

class _WorkDistributionPageState
    extends State<WorkDistributionPage> {
  static const Color _brown = Color(0xFF392619);
  static const Color _gold = Color(0xFFC28E3D);
  static const Color _canvas = Color(0xFFFAF7F2);
  static const Color _line = Color(0xFFEFE7DB);
  static const Color _green = Color(0xFF16A36A);
  static const Color _red = Color(0xFFE05252);
  static const Color _orange = Color(0xFFEF9C35);
  static const Color _muted = Color(0xFF85909F);

  int _selectedTab = 0;
  DateTime _selectedDate = DateTime.now();

  final List<TeamMember> _members = [
    const TeamMember(
      id: '1',
      name: 'Ramesh Kumar',
      role: 'Master Tailor',
      completed: 6,
      total: 7,
      present: true,
      avatarColor: Color(0xFFE8D7C4),
    ),
    const TeamMember(
      id: '2',
      name: 'Sita Devi',
      role: 'Tailor',
      completed: 4,
      total: 5,
      present: true,
      avatarColor: Color(0xFFF4D9E8),
    ),
    const TeamMember(
      id: '3',
      name: 'Imran Khan',
      role: 'Cutter',
      completed: 0,
      total: 3,
      present: false,
      avatarColor: Color(0xFFDCEAF8),
    ),
    const TeamMember(
      id: '4',
      name: 'Pooja Sharma',
      role: 'Finishing Specialist',
      completed: 5,
      total: 6,
      present: true,
      avatarColor: Color(0xFFE5E0FA),
    ),
    const TeamMember(
      id: '5',
      name: 'Amit Patel',
      role: 'Tailor',
      completed: 3,
      total: 3,
      present: true,
      avatarColor: Color(0xFFE0F2DF),
    ),
  ];

  int get _totalMembers => _members.length;

  int get _presentMembers =>
      _members.where((e) => e.present).length;

  int get _absentMembers =>
      _members.where((e) => !e.present).length;

  int get _totalWork =>
      _members.fold(0, (sum, e) => sum + e.total);

  int get _completedWork =>
      _members.fold(0, (sum, e) => sum + e.completed);

  int get _pendingWork =>
      (_totalWork - _completedWork).clamp(0, _totalWork);

  double get _progress =>
      _totalWork == 0 ? 0 : _completedWork / _totalWork;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _brown,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _brown,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _brown,
            size: 19,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Work Distribution',
          style: TextStyle(
            color: _brown,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Filter',
            onPressed: () => _showMessage(
              'Additional filters coming soon',
            ),
            icon: const Icon(
              Icons.tune_rounded,
              color: _brown,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 940,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                14, 4, 14, 22,
              ),
              children: [
                _buildFilters(),
                const SizedBox(height: 12),
                _buildSummary(),
                const SizedBox(height: 12),
                _buildProgressCard(),
                const SizedBox(height: 16),
                _buildTeamSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================
  // FILTERS
  // ===========================================

  Widget _buildFilters() {
    const tabs = [
      'Today',
      'This Week',
      'Assignments',
    ];

    return _card(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            height: 43,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final selected = _selectedTab == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(9),
                        boxShadow: selected
                            ? [
                                const BoxShadow(
                                  color: Color(0x10000000),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? _brown : _muted,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 11),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(11),
            child: Container(
              height: 43,
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAF7),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _line),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: _gold,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, dd MMM yyyy')
                          .format(_selectedDate),
                      style: const TextStyle(
                        color: _brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _muted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================
  // SUMMARY
  // ===========================================

  Widget _buildSummary() {
    return _card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'Work Overview',
            'Team attendance & assignments',
            Icons.dashboard_outlined,
          ),


          
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _openTeamWorkList,
                  borderRadius: BorderRadius.circular(13),
                  child: _statTile(
                    'Members',
                    '$_totalMembers',
                    Icons.groups_rounded,
                    const Color(0xFFF1E9DD),
                    _brown,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statTile(
                  'Present',
                  '$_presentMembers',
                  Icons.check_circle_outline,
                  const Color(0xFFE9F8F0),
                  _green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statTile(
                  'Absent',
                  '$_absentMembers',
                  Icons.person_off_outlined,
                  const Color(0xFFFFEEEE),
                  _red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  'Total Work',
                  '$_totalWork',
                  Icons.assignment_outlined,
                  const Color(0xFFEAF0FF),
                  const Color(0xFF4664BE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statTile(
                  'Completed',
                  '$_completedWork',
                  Icons.task_alt_rounded,
                  const Color(0xFFE9F8F0),
                  _green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statTile(
                  'Pending',
                  '$_pendingWork',
                  Icons.pending_actions_rounded,
                  const Color(0xFFFFF3E3),
                  _orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(
    String title,
    String value,
    IconData icon,
    Color bg,
    Color foreground,
  ) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: foreground, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF657184),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================
  // PROGRESS CARD
  // ===========================================

  Widget _buildProgressCard() {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'Team Progress',
            'Work completion overview',
            Icons.insights_rounded,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 104,
                      height: 104,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 11,
                        strokeCap: StrokeCap.round,
                        backgroundColor:
                            const Color(0xFFF1E8DB),
                        valueColor:
                            const AlwaysStoppedAnimation(
                          _green,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(_progress * 100).round()}%',
                          style: const TextStyle(
                            color: _brown,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  children: [
                    _legendRow(
                      'Completed',
                      _completedWork,
                      _green,
                    ),
                    const SizedBox(height: 13),
                    _legendRow(
                      'Pending',
                      _pendingWork,
                      _orange,
                    ),
                    const SizedBox(height: 13),
                    _legendRow(
                      'Total Work',
                      _totalWork,
                      _brown,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          SizedBox(
            height: 45,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.assignWork),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.add_task_rounded,
                size: 20,
              ),
              label: const Text(
                'Assign Work',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(
    String label,
    int value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: _brown,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ===========================================
  // TEAM LIST
  // ===========================================

  Widget _buildTeamSection() {
    final visibleMembers = _selectedTab == 2
        ? _members.where((m) => m.total > 0).toList()
        : _members;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Today's Team Status",
                style: TextStyle(
                  color: _brown,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${visibleMembers.length} members',
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (visibleMembers.isEmpty)
          _card(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No team members available'),
              ),
            ),
          )
        else
          ...visibleMembers.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _memberCard(member),
            ),
          ),
      ],
    );
  }

  Widget _memberCard(TeamMember member) {
    final double percent = member.total == 0
        ? 0
        : member.completed / member.total;

    return _card(
      padding: const EdgeInsets.all(11),
      child: InkWell(
        onTap: () {
          _openTeamWorkList();
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: member.avatarColor,
              child: Text(
                _initials(member.name),
                style: const TextStyle(
                  color: _brown,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _brown,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _statusChip(member.present),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.role,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 5,
                            backgroundColor:
                                const Color(0xFFEEE9E1),
                            valueColor:
                                const AlwaysStoppedAnimation(
                              _green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${member.completed}/${member.total}',
                        style: const TextStyle(
                          color: _brown,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFADB5C0),
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(bool present) {
    final color = present ? _green : _red;
    final bg = present
        ? const Color(0xFFEAF8F0)
        : const Color(0xFFFFEEEE);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        present ? 'Present' : 'Absent',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ===========================================
  // MEMBER DETAILS
  // ===========================================

  void _openTeamWorkList() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const TeamWorkListPage(),
      ),
    );
  }

  // ===========================================
  // REUSABLE WIDGETS
  // ===========================================

  Widget _sectionHeading(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF6E8D3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _gold,
            size: 19,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _brown,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(12),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _brown.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}

// ===========================================
// TEMPORARY TEAM MEMBER MODEL
// ===========================================

class TeamMember {
  final String id;
  final String name;
  final String role;
  final int completed;
  final int total;
  final bool present;
  final Color avatarColor;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.completed,
    required this.total,
    required this.present,
    required this.avatarColor,
  });
}
