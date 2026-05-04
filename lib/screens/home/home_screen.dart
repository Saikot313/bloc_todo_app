
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/todo/todo_bloc.dart';
import '../../blocs/todo/todo_event.dart';
import '../../blocs/todo/todo_state.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../models/todo_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/todo_card.dart';
import '../../widgets/add_todo_sheet.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filter = [TodoFilter.all, TodoFilter.active, TodoFilter.completed][_tabController.index];
        context.read<TodoBloc>().add(TodoFilterChanged(filter));
      }
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TodoBloc>().add(TodosLoaded(authState.user.id));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return authState.user.id;
    return '';
  }

  String _getUserName() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return authState.user.name;
    return '';
  }

  void _openAddSheet({TodoModel? existingTodo}) async {
    final result = await showModalBottomSheet<TodoModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTodoSheet(existingTodo: existingTodo),
    );

    if (result != null && mounted) {
      final userId = _getUserId();
      if (existingTodo != null) {
        context.read<TodoBloc>().add(TodoUpdated(userId: userId, todo: result));
      } else {
        context.read<TodoBloc>().add(TodoAdded(userId: userId, todo: result));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        Text(
                          _getUserName().split(' ').first + '! 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                    Row(
                      children: [
                        // Theme toggle
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            return _HeaderButton(
                              icon: themeMode == ThemeMode.dark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              onTap: () => context.read<ThemeCubit>().toggleTheme(),
                              isDark: isDark,
                            );
                          },
                        ),
                        const Gap(8),
                        // Logout
                        _HeaderButton(
                          icon: Icons.logout_rounded,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text('Logout?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                                content: Text('Leave the Account', style: GoogleFonts.poppins()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('No', style: GoogleFonts.poppins(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<AuthBloc>().add(AuthSignOutRequested());
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                                    child: Text('Yes', style: GoogleFonts.poppins()),
                                  ),
                                ],
                              ),
                            );
                          },
                          isDark: isDark,
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2, end: 0),
                  ],
                ),
              ),

              const Gap(20),

              // Stats Cards
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state is TodoLoaded) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _StatCard(
                            label: 'Total Task',
                            count: state.todos.length,
                            color: AppTheme.primaryColor,
                            icon: Icons.list_alt_rounded,
                            isDark: isDark,
                          ),
                          const Gap(12),
                          _StatCard(
                            label: 'Due Task',
                            count: state.activeCount,
                            color: const Color(0xFFFFA940),
                            icon: Icons.pending_actions_rounded,
                            isDark: isDark,
                          ),
                          const Gap(12),
                          _StatCard(
                            label: 'Completed',
                            count: state.completedCount,
                            color: AppTheme.secondaryColor,
                            icon: Icons.task_alt_rounded,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0);
                  }
                  return const SizedBox.shrink();
                },
              ),

              const Gap(20),

              // Filter Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Running'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const Gap(16),

              // Todo List
              Expanded(
                child: BlocBuilder<TodoBloc, TodoState>(
                  builder: (context, state) {
                    if (state is TodoLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryColor),
                      );
                    }

                    if (state is TodoLoaded) {
                      final todos = state.filteredTodos;

                      if (todos.isEmpty) {
                        return _EmptyState(
                          filter: state.filter,
                          onAdd: _openAddSheet,
                        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
                      }

                      return Column(
                        children: [
                          // Action row
                          if (state.completedCount > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      context.read<TodoBloc>().add(
                                            CompletedTodosDeleted(_getUserId()),
                                          );
                                    },
                                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                                    label: Text('Delete Tasks', style: GoogleFonts.poppins(fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: AppTheme.accentColor),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 300.ms),

                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                              physics: const BouncingScrollPhysics(),
                              itemCount: todos.length,
                              itemBuilder: (context, index) {
                                final todo = todos[index];
                                return TodoCard(
                                  todo: todo,
                                  index: index,
                                  onToggle: () => context.read<TodoBloc>().add(
                                        TodoToggled(userId: _getUserId(), todoId: todo.id),
                                      ),
                                  onDelete: () => context.read<TodoBloc>().add(
                                        TodoDeleted(userId: _getUserId(), todoId: todo.id),
                                      ),
                                  onTap: () => _openAddSheet(existingTodo: todo),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),

        // FAB
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddSheet,
          backgroundColor: AppTheme.primaryColor,
          elevation: 8,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'New Task',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Evening 🌤️';
    if (hour < 20) return 'Good afternoon 🌅';
    return 'Good Night 🌙';
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _HeaderButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const Gap(8),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
              ),
            ),
            const Gap(2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TodoFilter filter;
  final VoidCallback onAdd;

  const _EmptyState({required this.filter, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String emoji, title, subtitle;

    switch (filter) {
      case TodoFilter.completed:
        emoji = '🎯';
        title = "Nothing is over yet.";
        subtitle = 'It will be shown here once the task is completed.';
        break;
      case TodoFilter.active:
        emoji = '🎉';
        title = 'All tasks completed!';
        subtitle = "Awesome! You've completed all tasks.";
        break;
      default:
        emoji = '📝';
        title = 'No tasks available.';
        subtitle = 'Add New Task';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const Gap(16),
          Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          const Gap(8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (filter == TodoFilter.all) ...[
            const Gap(24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text('Added Task', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
