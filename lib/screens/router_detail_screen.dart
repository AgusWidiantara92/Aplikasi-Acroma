import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/router_provider.dart';
import '../utils/theme.dart';
import '../widgets/metric_chart.dart';

class RouterDetailScreen extends StatefulWidget {
  const RouterDetailScreen({Key? key}) : super(key: key);

  @override
  State<RouterDetailScreen> createState() => _RouterDetailScreenState();
}

class _RouterDetailScreenState extends State<RouterDetailScreen> {
  bool _testingPing = false;

  void _runPingTest(BuildContext context) async {
    setState(() {
      _testingPing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _testingPing = false;
    });

    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (sheetCtx) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.network_check, color: AppTheme.primary),
                  SizedBox(width: 10),
                  Text('ICMP PING RESPONSE', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: const Text(
                  'ping 8.8.8.8 count=4...\n'
                  'reply from 8.8.8.8: time=12ms ttl=56\n'
                  'reply from 8.8.8.8: time=10ms ttl=56\n'
                  'reply from 8.8.8.8: time=15ms ttl=56\n'
                  'reply from 8.8.8.8: time=11ms ttl=56\n'
                  'packet sent=4 received=4 lost=0 (0% loss)\n'
                  'rtt min/avg/max = 10/12/15 ms',
                  style: TextStyle(fontFamily: 'Courier', fontSize: 13, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetCtx),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showRebootConfirm(BuildContext context, RouterProvider provider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('REBOOT ROUTER', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to reboot this router? This will temporarily interrupt network services.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              provider.rebootRouter();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            child: const Text('REBOOT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RouterProvider>(context);
    final selected = provider.selectedRouter;
    final metricHistory = provider.metricHistory;
    final activeRecommendations = provider.recommendations;

    return Scaffold(
      appBar: AppBar(
        title: Text(selected?.nickname.toUpperCase() ?? 'ROUTER DETAILS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: selected == null
          ? const Center(child: Text('No router selected'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick Info Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ROUTER BOARD IP', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            Text(selected.host, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('API PORT', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            Text('${selected.port}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Real-time Traffic graph
                  const Text('WAN INTERFACE LIVE TRAFFIC', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 12),
                          child: Text(
                            'Incoming Traffic (Mbps)',
                            style: TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        MetricChart(history: metricHistory, type: ChartType.traffic),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CPU graph
                  const Text('CPU RESOURCE ACTIVITY', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12, top: 12),
                          child: Text(
                            'Processor Usage (%)',
                            style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        MetricChart(history: metricHistory, type: ChartType.cpu),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Controls
                  const Text('UTILITY QUICK ACTIONS', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _testingPing ? null : () => _runPingTest(context),
                          icon: const Icon(Icons.network_check, size: 20),
                          label: _testingPing ? const Text('PINGING...') : const Text('PING GOOGLE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showRebootConfirm(context, provider),
                          icon: const Icon(Icons.restart_alt, size: 20),
                          label: const Text('REBOOT BOARD'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warning,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // AI Recommendations
                  const Text('AI RECOMMENDATIONS & DIAGNOSTICS', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  if (activeRecommendations.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: AppTheme.success),
                          SizedBox(width: 12),
                          Text('Network status is normal. No recommendations.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    ...activeRecommendations.map((rec) {
                      // Determine priority tags
                      String priorityLabel = 'LOW';
                      Color priorityColor = AppTheme.primary;
                      if (rec.severity == 'critical') {
                        priorityLabel = 'CRITICAL';
                        priorityColor = AppTheme.error;
                      } else if (rec.severity == 'warning') {
                        priorityLabel = 'HIGH';
                        priorityColor = AppTheme.warning;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)), // Purple highlights
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.04),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.psychology, color: AppTheme.accent, size: 22),
                                    SizedBox(width: 8),
                                    Text('AI RECOM', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: priorityColor.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    priorityLabel,
                                    style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(rec.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text(rec.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
