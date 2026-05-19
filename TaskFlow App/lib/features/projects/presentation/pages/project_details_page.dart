import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:intl/intl.dart';
import '../bloc/projects_bloc.dart';
import '../../data/models/project_models.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';

class ProjectDetailsPage extends StatelessWidget {
  final String projectId;
  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProjectsBloc>()..add(LoadProjectDetailRequested(projectId)),
      child: const _ProjectDetailsView(),
    );
  }
}

class _ProjectDetailsView extends StatefulWidget {
  const _ProjectDetailsView();

  @override
  State<_ProjectDetailsView> createState() => _ProjectDetailsViewState();
}

class _ProjectDetailsViewState extends State<_ProjectDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        final isLoading = state is ProjectDetailLoading;
        final isError = state is ProjectDetailFailure;
        final isLoaded = state is ProjectDetailLoaded;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFF),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              isLoaded ? state.project.name : 'Project Details',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [],
          ),
          floatingActionButton: isLoaded
              ? FloatingActionButton(
                  onPressed: () {
                    context
                        .push('/create-task',
                            extra: {'projectId': state.project.id})
                        .then((_) {
                      // Nothing needed; tasks_page handles its own reload
                    });
                  },
                  backgroundColor: AppColors.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                )
              : null,
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : isError
                  ? _buildError(context, state.message)
                  : isLoaded
                      ? _buildContent(context, state)
                      : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context
                .read<ProjectsBloc>()
                .add(LoadProjectDetailRequested(
                    (context.read<ProjectsBloc>().state as ProjectDetailFailure)
                        .message)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProjectDetailLoaded state) {
    final project = state.project;
    final stats = state.stats;
    final progress = (project.completionPercentage / 100).clamp(0.0, 1.0);
    final members = project.members ?? [];
    final colorLabel =
        project.colorLabel != null && project.colorLabel!.startsWith('#')
            ? Color(int.parse(project.colorLabel!.replaceFirst('#', '0xFF')))
            : AppColors.primary;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header card
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Status + updated
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statusBadge(project.status ?? 'Active', colorLabel),
                            if (project.dueDate != null)
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 12, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Due ${DateFormat('MMM d').format(project.dueDate!)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            height: 1.2,
                          ),
                        ),
                        if (project.description != null &&
                            project.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            project.description!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Stats row
                        if (stats != null)
                          Row(
                            children: [
                              _statChip(
                                  '${stats.totalTasks}', 'Total', Colors.indigo),
                              const SizedBox(width: 8),
                              _statChip('${stats.inProgressTasks}', 'Active',
                                  Colors.amber.shade700),
                              const SizedBox(width: 8),
                              _statChip('${stats.completedTasks}', 'Done',
                                  AppColors.success),
                            ],
                          ),
                        if (stats != null) const SizedBox(height: 20),

                        // Progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B))),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colorLabel),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: colorLabel.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(colorLabel),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Members row
                        Row(
                          children: [
                            ...members.take(4).map((m) => Align(
                                  widthFactor: 0.75,
                                  alignment: Alignment.centerLeft,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        colorLabel.withValues(alpha: 0.15),
                                    backgroundImage: m.avatarUrl != null
                                        ? NetworkImage(m.avatarUrl!)
                                        : null,
                                    child: m.avatarUrl == null
                                        ? Text(
                                            m.fullName.isNotEmpty
                                                ? m.fullName[0].toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: colorLabel),
                                          )
                                        : null,
                                  ),
                                )),
                            if (members.length > 4)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFEBEFF5),
                                child: Text('+${members.length - 4}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B))),
                              ),
                            const SizedBox(width: 12),
                            Text(
                              '${members.length} member${members.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),

                        ElevatedButton.icon(
                          onPressed: () => context.push('/invite-member',
                              extra: {'projectId': project.id}),
                          icon: const Icon(Icons.person_add_outlined, size: 20),
                          label: const Text('Invite Members',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8)
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Tasks'),
                  Tab(text: 'Members'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tasks tab — reuse TasksPage with projectId filter
          TasksPage(projectId: project.id),

          // Members tab
          _buildMembersTab(members, colorLabel),
        ],
      ),
    );
  }

  Widget _buildMembersTab(
      List<ProjectMemberResponse> members, Color colorLabel) {
    if (members.isEmpty) {
      return const Center(
        child: Text('No members yet.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final m = members[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorLabel.withValues(alpha: 0.15),
                backgroundImage: m.avatarUrl != null
                    ? NetworkImage(m.avatarUrl!)
                    : null,
                child: m.avatarUrl == null
                    ? Text(
                        m.fullName.isNotEmpty
                            ? m.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: colorLabel),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.fullName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B))),
                    if (m.role != null)
                      Text(m.role!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorLabel.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  m.role ?? 'Member',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorLabel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8FAFF), // Match background color
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
