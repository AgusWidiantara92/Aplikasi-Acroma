import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/router_provider.dart';
import '../models/router_profile.dart';
import '../utils/theme.dart';
import '../widgets/status_badge.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddRouterDialog(BuildContext context) {
    final nicknameController = TextEditingController();
    final hostController = TextEditingController(text: '192.168.88.1');
    final portController = TextEditingController(text: '8728');
    final usernameController = TextEditingController(text: 'admin');
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('ADD ROUTER', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nicknameController, decoration: const InputDecoration(labelText: 'Router Nickname')),
              const SizedBox(height: 10),
              TextField(controller: hostController, decoration: const InputDecoration(labelText: 'IP / Host Address')),
              const SizedBox(height: 10),
              TextField(controller: portController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Port (8728)')),
              const SizedBox(height: 10),
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 10),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (nicknameController.text.isEmpty || hostController.text.isEmpty) return;
              Provider.of<RouterProvider>(context, listen: false).addRouter(
                nicknameController.text.trim(),
                hostController.text.trim(),
                int.tryParse(portController.text) ?? 8728,
                usernameController.text.trim(),
                passwordController.text,
              );
              Navigator.pop(dialogCtx);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _showEditRouterDialog(BuildContext context, RouterProfile router, RouterProvider provider) {
    final nicknameController = TextEditingController(text: router.nickname);
    final hostController = TextEditingController(text: router.host);
    final portController = TextEditingController(text: router.port.toString());
    final usernameController = TextEditingController(text: router.username);
    final passwordController = TextEditingController(text: router.password);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('EDIT ROUTER CONFIG', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nicknameController, decoration: const InputDecoration(labelText: 'Nickname')),
              const SizedBox(height: 10),
              TextField(controller: hostController, decoration: const InputDecoration(labelText: 'IP / Host')),
              const SizedBox(height: 10),
              TextField(controller: portController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Port')),
              const SizedBox(height: 10),
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 10),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (nicknameController.text.isEmpty || hostController.text.isEmpty) return;
              final updatedProfile = router.copyWith(
                nickname: nicknameController.text.trim(),
                host: hostController.text.trim(),
                port: int.tryParse(portController.text) ?? 8728,
                username: usernameController.text.trim(),
                password: passwordController.text,
              );
              provider.addRouter(
                updatedProfile.nickname,
                updatedProfile.host,
                updatedProfile.port,
                updatedProfile.username,
                updatedProfile.password,
              );
              provider.selectRouter(updatedProfile);
              Navigator.pop(dialogCtx);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RouterProvider>(context);
    final selected = provider.selectedRouter;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('ACROMA'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddRouterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await provider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: selected == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.router, size: 64, color: AppTheme.primary),
                  const SizedBox(height: 16),
                  const Text('No router registered.', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddRouterDialog(context),
                    child: const Text('ADD ROUTER'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Top Router Status Card
                _buildTopRouterCard(provider, selected),
                
                // Tab Selection Bar (Overview, Rekomendasi AI, Pelanggan, Log, Settings)
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Kecerdasan Artifisial'),
                      Tab(text: 'Pelanggan'),
                      Tab(text: 'Log'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                ),

                // Content Views
                Expanded(
                  child: provider.isRebooting
                      ? const Center(
                          child: CircularProgressIndicator(color: AppTheme.warning),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(provider),
                            _buildAITab(provider),
                            _buildPelangganTab(provider),
                            _buildLogTab(provider),
                            _buildSettingsTab(provider, selected),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTopRouterCard(RouterProvider provider, RouterProfile selected) {
    final metric = provider.currentMetric;
    return Container(
      width: double.infinity,
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppTheme.primaryLight,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected.nickname,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'IP: ${selected.host}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            const Text('Online', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Text(
                          'WiFi Active',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCardMetricItem('CPU', '${metric?.cpuUsage.toStringAsFixed(0) ?? "0"}%'),
                  _buildCardMetricItem('Memory', '${metric?.ramUsage.toStringAsFixed(0) ?? "0"}%'),
                  _buildCardMetricItem('Temp', '${metric?.temperature.toStringAsFixed(0) ?? "0"}°C'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardMetricItem(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  // --- TAB 1: OVERVIEW ---
  Widget _buildOverviewTab(RouterProvider provider) {
    final metric = provider.currentMetric;
    if (metric == null) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildOverviewItem(
              title: 'WiFi Terhubung',
              val: '${provider.connectedDevices.length}',
              subtitle: '192.168.88.0/24',
              icon: Icons.wifi,
              color: AppTheme.primary,
            ),
            _buildOverviewItem(
              title: 'Bandwidth',
              val: '${(metric.downloadSpeed / 1024).toStringAsFixed(1)} Mbps',
              subtitle: 'Download Speed',
              icon: Icons.speed,
              color: AppTheme.primaryLight,
            ),
            _buildOverviewItem(
              title: 'Total Data Terpakai',
              val: '${metric.totalData.toStringAsFixed(1)} GB',
              subtitle: 'Quota Usage',
              icon: Icons.data_usage,
              color: AppTheme.accent,
            ),
            _buildOverviewItem(
              title: 'Kualitas Sinyal',
              val: metric.signalQuality > 80 ? 'Bagus' : 'Cukup',
              subtitle: 'Signal Strength',
              icon: Icons.signal_cellular_alt,
              color: AppTheme.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewItem({
    required String title,
    required String val,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(val, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: AI RECOMMENDATIONS ---
  Widget _buildAITab(RouterProvider provider) {
    final recs = provider.recommendations;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Purple header card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: AppTheme.accent, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Rekomendasi AI', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 2),
                    Text(
                      'Rekomendasi aktivitas dan tindakan yang perlu dilakukan berdasarkan kondisi router.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (recs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('Kondisi jaringan optimal. Tidak ada rekomendasi saat ini.', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ),
          )
        else
          ...recs.map((rec) {
            final isCritical = rec.severity == 'critical';
            final tagColor = isCritical ? AppTheme.error : AppTheme.primary;
            final labelText = isCritical ? 'Prioritas Tinggi' : 'Medium';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: tagColor.withOpacity(0.3), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(isCritical ? Icons.warning_amber_rounded : Icons.security, color: tagColor, size: 20),
                            const SizedBox(width: 8),
                            Text(rec.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: tagColor)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            labelText,
                            style: TextStyle(color: tagColor, fontWeight: FontWeight.bold, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(rec.description, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(isCritical ? 'Tingkatkan' : 'Review', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  // --- TAB 3: CONNECTED DEVICES (PELANGGAN) ---
  Widget _buildPelangganTab(RouterProvider provider) {
    final devices = provider.connectedDevices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Perangkat terhubung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('Total: ${devices.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: devices.length,
            itemBuilder: (ctx, idx) {
              final d = devices[idx];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.hostname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          Text('IP: ${d.ipAddress}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('MAC: ${d.macAddress}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Batasi', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => provider.toggleBlockDevice(d.macAddress, !d.isBlocked),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: d.isBlocked ? AppTheme.success : AppTheme.error),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              d.isBlocked ? 'Unblock' : 'Block',
                              style: TextStyle(color: d.isBlocked ? AppTheme.success : AppTheme.error, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- TAB 4: LOGS TAB ---
  Widget _buildLogTab(RouterProvider provider) {
    final logs = provider.logs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Green header banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.success,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Aktivitas Log',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: logs.length,
            itemBuilder: (ctx, idx) {
              final log = logs[idx];
              
              IconData icon = Icons.info;
              Color color = AppTheme.success;
              if (log.severity == 'warning') {
                icon = Icons.lock;
                color = AppTheme.accent;
              } else if (log.severity == 'error') {
                icon = Icons.warning;
                color = AppTheme.warning;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(log.message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(log.topic.toUpperCase(), style: const TextStyle(fontSize: 10)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- TAB 5: SETTINGS TAB ---
  Widget _buildSettingsTab(RouterProvider provider, RouterProfile selected) {
    final metric = provider.currentMetric;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informasi Router', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Divider(height: 24),
                _buildSettingsRow('Nama Router MikroTik', selected.nickname),
                _buildSettingsRow('Model', 'RouterBoard hexS'),
                _buildSettingsRow('IP Address', selected.host),
                _buildSettingsRow('Sistem', 'RouterOS v7.1.1'),
                _buildSettingsRow('Uptime', metric?.uptime ?? '00:00:00'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showEditRouterDialog(context, selected, provider),
          child: const Text('Edit Router'),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
