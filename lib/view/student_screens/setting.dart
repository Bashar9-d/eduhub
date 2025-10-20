import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ----------------------------------------------------
/// Theme Notifier + Persistence (بنفس الملف)
/// ----------------------------------------------------
class ThemeNotifier extends ChangeNotifier {
  static const _k = 'theme_mode'; // light | dark | system
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  ThemeNotifier() {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k);
    _mode = switch (raw) {
      'light' => ThemeMode.light,
      'dark'  => ThemeMode.dark,
      _       => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> set(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, m == ThemeMode.light ? 'light' : m == ThemeMode.dark ? 'dark' : 'system');
  }

  Future<void> toggleDark(bool isDark) => set(isDark ? ThemeMode.dark : ThemeMode.light);
}

/// ----------------------------------------------------
/// SettingsScreen (بنفس الملف) + نسخة provided()
/// ----------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// استخدمي هاي لو بدك الشاشة تشتغل لحالها بدون ما تلفّيها بـ provider فوق.
  static Widget provided() {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const SettingsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = context.watch<ThemeNotifier>(); // جاي من provider
    final isDarkNow = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), label: 'Your courses'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Setting'),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // هيدر متدرّج
          SliverToBoxAdapter(
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB794F4), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsetsDirectional.only(top: 52, start: 20, end: 20),
              child: const Row(
                children: [
                  Icon(Icons.settings, color: Colors.white, size: 26),
                  SizedBox(width: 10),
                  Text('Settings', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),

          // المحتوى
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Card(
                child: Column(
                  children: [
                    const _ProfileTile(),
                    const _SectionHeader('Account Settings'),
                    _NavTile(
                      title: 'Edit profile',
                      icon: Icons.person_outline,
                      onTap: () => _sheet(context, const _FakeForm(title: 'Edit profile')),
                    ),
                    _NavTile(
                      title: 'Change password',
                      icon: Icons.lock_outline,
                      onTap: () => _sheet(context, const _FakeForm(title: 'Change password')),
                    ),
                    _NavTile(
                      title: 'Add a payment method',
                      icon: Icons.credit_card_outlined,
                      trailing: const Icon(Icons.add),
                      onTap: () => _sheet(context, const _FakeForm(title: 'Add payment method')),
                    ),

                    // Push notifications (محلي حالياً)
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Push notifications'),
                      value: true,
                      onChanged: (v) {},
                    ),

                    // Dark mode (سويتش سريع)
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark mode'),
                      value: notifier.mode == ThemeMode.dark || (notifier.mode == ThemeMode.system && isDarkNow),
                      onChanged: (v) => notifier.toggleDark(v),
                    ),

                    // خيارات ThemeMode في نفس الصفحة
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            title: const Text('Use system theme'),
                            value: ThemeMode.system,
                            groupValue: notifier.mode,
                            onChanged: (m) => notifier.set(m!),
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Light'),
                            value: ThemeMode.light,
                            groupValue: notifier.mode,
                            onChanged: (m) => notifier.set(m!),
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Dark'),
                            value: ThemeMode.dark,
                            groupValue: notifier.mode,
                            onChanged: (m) => notifier.set(m!),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 24, thickness: .8),
                    const _SectionHeader('More'),
                    _NavTile(
                      title: 'About us',
                      icon: Icons.info_outline,
                      onTap: () => _sheet(context, const _AboutSheet()),
                    ),
                    _NavTile(
                      title: 'Privacy policy',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => _sheet(context, const _PrivacySheet()),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------
/// Widgets مساعدة (نفس الملف)
/// ----------------------------------------------------
class _ProfileTile extends StatelessWidget {
  const _ProfileTile();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: const CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
      ),
      title: Text('Yennefer Doe', style: TextStyle(fontWeight: FontWeight.w700, color: onSurface)),
      subtitle: Text('teacher@eduhub.app', style: TextStyle(color: onSurface.withOpacity(.7))),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(title, style: TextStyle(fontSize: 12, letterSpacing: .3, color: c)),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback onTap;
  const _NavTile({super.key, required this.title, required this.icon, this.trailing, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

void _sheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: child,
    ),
  );
}

class _FakeForm extends StatelessWidget {
  final String title;
  const _FakeForm({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'Field 1')),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'Field 2')),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
          ),
        ],
      ),
    );
  }
}

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Text('About us text...'),
    );
  }
}

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Text('Privacy policy text...'),
    );
  }
}
