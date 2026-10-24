import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tailorpro_clean/features/workdistribution/data/models/team_work_model.dart';
import 'package:tailorpro_clean/features/workdistribution/presentation/pages/team_work_detail_page.dart';

class TeamWorkListPage extends StatefulWidget {
  const TeamWorkListPage({super.key});

  @override
  State<TeamWorkListPage> createState() => _TeamWorkListPageState();
}

class _TeamWorkListPageState extends State<TeamWorkListPage> {
  static const Color primary = Color(0xFF16A36A);
  static const Color background = Color(0xFFF5F7FA);
  static const Color dark = Color(0xFF182230);

  final TextEditingController searchController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  int? selectedMemberId;
  String selectedStatus = 'All';
  String searchQuery = '';
  bool _filtersExpanded = false;

  List<TeamWorkModel> get filteredMembers {
    return TeamWorkDemoData.members.where((member) {
      final matchesMember =
          selectedMemberId == null || member.id == selectedMemberId;

      final matchesSearch =
          member.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              member.role.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = switch (selectedStatus) {
        'Present' => member.attendance == AttendanceStatus.present,
        'Absent' => member.attendance == AttendanceStatus.absent,
        'Holiday' => member.attendance == AttendanceStatus.holiday,
        _ => true,
      };

      return matchesMember && matchesSearch && matchesStatus;
    }).toList();
  }
  Future<void> pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: primary),
        ),
        child: child!,
      ),
    );

    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = filteredMembers;
    final totalTasks = members.fold<int>(0, (s, e) => s + e.total);
    final completedTasks = members.fold<int>(0, (s, e) => s + e.completed);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        title: const Text(
          'Team Work',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: dark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset filters',
            onPressed: () {
              searchController.clear();
              setState(() {
                selectedMemberId = null;
                selectedStatus = 'All';
                searchQuery = '';
                selectedDate = DateTime.now();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              children: [
                _buildFilterSection(),
                const SizedBox(height: 14),
                _buildSummary(members.length, totalTasks, completedTasks),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text(
                      'Team Members',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7EE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${members.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Progress overview',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                if (members.isEmpty)
                  _buildEmptyState()
                else
                  ...members.map(
                    (member) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildMemberCard(member),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final activeCount = (searchQuery.trim().isNotEmpty ? 1 : 0) +
        (selectedMemberId != null ? 1 : 0) +
        (selectedStatus != 'All' ? 1 : 0);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EBE8)),
        boxShadow: [
          BoxShadow(
            color: dark.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Semantics(
            expanded: _filtersExpanded,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() => _filtersExpanded = !_filtersExpanded);
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7EE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: primary, size: 21),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Filters',
                                style: TextStyle(
                                    color: dark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(
                              activeCount > 0
                                  ? '$activeCount active · ${filteredMembers.length} members'
                                  : 'Search, member & date',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _filtersExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _filtersExpanded
                ? Column(
                    children: [
                      const Divider(height: 1, color: Color(0xFFEBEEF2)),
                      _buildFilterControls(),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 13),
      child: Column(
        children: [
          SizedBox(
            height: 43,
            child: TextField(
              controller: searchController,
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search member or role...',
                hintStyle: const TextStyle(fontSize: 12.5),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: background,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _filterBox(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedMemberId,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: dark,
                        fontWeight: FontWeight.w600,
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'All Members',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...TeamWorkDemoData.members.map(
                          (member) => DropdownMenuItem<int?>(
                            value: member.id,
                            child: Text(
                              member.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => selectedMemberId = v);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: pickDate,
                  borderRadius: BorderRadius.circular(11),
                  child: _filterBox(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMM yyyy').format(selectedDate),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: dark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEBEEF2)),
            ),
            child: Row(
              children: [
                for (final item in ['All', 'Present', 'Absent', 'Holiday']) ...[
                  if (item != 'All') const SizedBox(width: 4),
                  Expanded(
                    child: Semantics(
                      selected: selectedStatus == item,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: selectedStatus == item
                              ? primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: selectedStatus == item
                              ? [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() => selectedStatus = item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 14),
                              child: Center(
                                child: Text(
                                  item,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: selectedStatus == item
                                        ? Colors.white
                                        : const Color(0xFF667085),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBox({required Widget child}) {
    return Container(
      height: 41,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFEBEEF2)),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildSummary(int memberCount, int total, int completed) {
    final percent = total == 0 ? 0 : ((completed / total) * 100).round();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15845F), Color(0xFF21AC75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Work Overview",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Team Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.groups_2_outlined,
                  size: 23,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _summaryValue('Members', '$memberCount'),
              _summaryValue('Total Tasks', '$total'),
              _summaryValue('Completed', '$completed'),
              _summaryValue('Progress', '$percent%'),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: total == 0 ? 0 : completed / total,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(TeamWorkModel member) {
    final progress = member.progress;

    final progressColor = member.attendance == AttendanceStatus.absent
        ? const Color(0xFFEF5350)
        : primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeamWorkDetailPage(member: member),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDF0F3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _avatar(member),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: dark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          member.role,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(member.attendance),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _taskCount(
                    Icons.assignment_outlined,
                    '${member.total} Total',
                  ),
                  const SizedBox(width: 12),
                  _taskCount(
                    Icons.check_circle_outline_rounded,
                    '${member.completed} Done',
                  ),
                  const SizedBox(width: 12),
                  _taskCount(
                    Icons.schedule_rounded,
                    '${member.pending} Pending',
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFEDF0F2),
                        valueColor: AlwaysStoppedAnimation(progressColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  SizedBox(
                    width: 35,
                    child: Text(
                      '${member.percentage}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: progressColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(TeamWorkModel member) {
    const colors = [
      Color(0xFFDCF4E7),
      Color(0xFFEDE5FA),
      Color(0xFFE4ECFF),
      Color(0xFFFFEAD9),
      Color(0xFFDFF3F4),
      Color(0xFFFFE3EC),
    ];

    final color = colors[(member.id - 1) % colors.length];

    final parts = member.name.trim().split(' ');
    final initials = '${parts.first[0]}${parts.length > 1 ? parts.last[0] : ''}'
        .toUpperCase();

    return CircleAvatar(
      radius: 23,
      backgroundColor: color,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: dark,
        ),
      ),
    );
  }

  Widget _taskCount(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(AttendanceStatus status) {
    final (label, foreground, backgroundColor) = switch (status) {
      AttendanceStatus.present => (
          'Present',
          const Color(0xFF168454),
          const Color(0xFFE5F7ED),
        ),
      AttendanceStatus.absent => (
          'Absent',
          const Color(0xFFD43F46),
          const Color(0xFFFFE9E9),
        ),
      AttendanceStatus.holiday => (
          'Holiday',
          const Color(0xFFD48122),
          const Color(0xFFFFF2DF),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 10),
            const Text(
              'No members found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Try another search or filter',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
