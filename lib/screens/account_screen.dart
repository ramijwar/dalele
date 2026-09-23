import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../widgets/widgets.dart';
import 'login_screen.dart';
import 'owner_dashboard_screen.dart';
import 'request_service_screen.dart';
import 'service_detail_screen.dart';

/// ══════════════════════════════════════════════════════════════
/// شاشة الحساب — الملف الشخصي ولوحة المالك والمحفوظات
/// ══════════════════════════════════════════════════════════════
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<Service> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await DatabaseService.instance.getFavorites();
    final list = <Service>[];
    for (final id in ids) {
      final s = await DatabaseService.instance.getService(id);
      if (s != null) list.add(s);
    }
    if (mounted) setState(() => _favorites = list);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();

    if (!auth.isLoggedIn) return _buildGuest(auth);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () async => _loadFavorites(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ─── رأس الحساب ───
              _buildHeader(auth.user!),
              const SizedBox(height: 14),

              // ─── الإجراءات السريعة ───
              _buildQuickActions(),
              const SizedBox(height: 16),

              // ─── المحفوظات ───
              _buildFavorites(),

              const SizedBox(height: 16),

              // ─── معلومات التطبيق ───
              _buildAppInfo(app),

              const SizedBox(height: 16),

              // ─── تسجيل الخروج ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(auth),
                  icon: const Icon(LucideIcons.logOut, size: 17),
                  label: const Text('تسجيل الخروج'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: BorderSide(color: AppTheme.danger.withOpacity(0.4)),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════ زائر ═══════════════
  Widget _buildGuest(AuthProvider auth) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.userCircle,
                    size: 44, color: AppTheme.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                'مرحباً بك',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'سجّل الدخول لإدارة خدماتك ومتابعة طلباتك',
                style: TextStyle(
                    fontSize: 13.5, color: AppTheme.textMuted, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(LucideIcons.logIn, size: 18),
                  label: const Text('تسجيل الدخول'),
                ),
              ),
              const SizedBox(height: 22),

              // محفوظات الزائر
              if (_favorites.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'المحفوظات',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ..._favorites.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: ServiceListTile(
                        service: s,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(service: s)),
                        ),
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════ رأس الحساب ═══════════════
  Widget _buildHeader(User u) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      u.initial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.fullName.isNotEmpty ? u.fullName : 'مستخدم',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        u.phoneIntl.isNotEmpty ? u.phoneIntl : u.phone,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                if (u.isAdmin)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'مدير',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════ الإجراءات السريعة ═══════════════
  Widget _buildQuickActions() {
    final items = [
      (
        icon: LucideIcons.briefcase,
        label: 'خدماتي',
        sub: 'تبديل الحالة والدوام',
        color: const Color(0xFF0EA5E9),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
            ),
      ),
      (
        icon: LucideIcons.inbox,
        label: 'طلباتي',
        sub: 'متابعة حالة الطلبات',
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const OwnerDashboardScreen(initialTab: 1)),
            ),
      ),
      (
        icon: LucideIcons.plusCircle,
        label: 'أضف خدمة',
        sub: 'أرسل طلب إضافة',
        color: const Color(0xFF10B981),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RequestServiceScreen()),
            ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items
            .map((it) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _QuickCard(
                      icon: it.icon,
                      label: it.label,
                      sub: it.sub,
                      color: it.color,
                      onTap: it.onTap,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ═══════════════ المحفوظات ═══════════════
  Widget _buildFavorites() {
    if (_favorites.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(LucideIcons.bookmark,
                  size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 7),
              Text(
                'المحفوظات (${_favorites.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _favorites.map((s) {
              return Dismissible(
                key: Key('fav-${s.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsetsDirectional.only(start: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                  ),
                  child: const Icon(LucideIcons.trash2,
                      color: AppTheme.danger, size: 20),
                ),
                onDismissed: (_) async {
                  await DatabaseService.instance.toggleFavorite(s.id);
                  _loadFavorites();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أُزيلت من المحفوظات')),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: ServiceListTile(
                    service: s,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ServiceDetailScreen(service: s)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ═══════════════ معلومات التطبيق ═══════════════
  Widget _buildAppInfo(AppProvider app) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _InfoLine(
            icon: LucideIcons.database,
            label: 'الخدمات المحفوظة محلياً',
            value: () => Future.value(app.totalServices),
          ),
          const Divider(height: 18),
          _InfoLine(
            icon: LucideIcons.refreshCw,
            label: 'آخر مزامنة',
            isSync: true,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(AuthProvider auth) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.danger, minimumSize: Size.zero),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) await auth.logout();
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style:
                    const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<int> Function()? value;
  final bool isSync;

  const _InfoLine({
    required this.icon,
    required this.label,
    this.value,
    this.isSync = false,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style:
                const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
          ),
        ),
        if (isSync)
          Text(
            app.lastSync == null
                ? 'لم تتم بعد'
                : '${app.lastSync!.hour.toString().padLeft(2, '0')}:${app.lastSync!.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          )
        else if (value != null)
          FutureBuilder<int>(
            future: value!(),
            builder: (_, snap) => Text(
              snap.data?.toString() ?? '—',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}
