import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/router_provider.dart';
import '../utils/theme.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  String _searchQuery = '';
  String _selectedTopic = 'All';
  String _selectedSeverity = 'All';

  final List<String> _topics = ['All', 'system', 'firewall', 'dhcp', 'interface'];
  final List<String> _severities = ['All', 'info', 'warning', 'error'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RouterProvider>(context);
    final selected = provider.selectedRouter;
    final logs = provider.logs;

    final filteredLogs = logs.where((log) {
      final matchesSearch = log.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.topic.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTopic = _selectedTopic == 'All' || log.topic.toLowerCase() == _selectedTopic.toLowerCase();
      final matchesSeverity = _selectedSeverity == 'All' || log.severity.toLowerCase() == _selectedSeverity.toLowerCase();

      return matchesSearch && matchesTopic && matchesSeverity;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SYSTEM LOGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: selected == null
          ? const Center(child: Text('No router selected'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search and Filters
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search message logs...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedTopic,
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedTopic = val);
                                  },
                                  items: _topics.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSeverity,
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedSeverity = val);
                                  },
                                  items: _severities.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: filteredLogs.isEmpty
                      ? const Center(child: Text('No logs match query criteria.', style: TextStyle(color: AppTheme.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = filteredLogs[index];

                            // Dynamic icon & color based on severity
                            IconData severityIcon = Icons.info_outline;
                            Color severityColor = AppTheme.success; // Default info
                            if (log.severity == 'warning') {
                              severityIcon = Icons.warning_amber_rounded;
                              severityColor = AppTheme.warning;
                            } else if (log.severity == 'error') {
                              severityIcon = Icons.error_outline_rounded;
                              severityColor = AppTheme.error;
                            }

                            final timeStr = '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: severityColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(severityIcon, color: severityColor, size: 20),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      log.topic.toUpperCase(),
                                      style: TextStyle(color: severityColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    log.message,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.3),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
