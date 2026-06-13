import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/router_provider.dart';
import '../utils/theme.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RouterProvider>(context);
    final selected = provider.selectedRouter;
    final devices = provider.connectedDevices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEVICES LIST'),
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
                // Top Status Overview Card
                Container(
                  margin: const EdgeInsets.all(16),
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
                          const Text('CONNECTED DEVICES', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('${devices.where((d) => !d.isBlocked).length} Devices Active', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('FIREWALL BLOCKS', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('${devices.where((d) => d.isBlocked).length} Devices Blocked', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.error)),
                        ],
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'ACTIVE DHCP LEASE CLIENTS',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),

                Expanded(
                  child: devices.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Status Circle Indicator
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: device.isBlocked ? AppTheme.error : AppTheme.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Content Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            device.hostname,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.link, size: 14, color: AppTheme.primary),
                                              const SizedBox(width: 4),
                                              Text('IP: ${device.ipAddress}', style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.fingerprint, size: 14, color: AppTheme.textSecondary),
                                              const SizedBox(width: 4),
                                              Text('MAC: ${device.macAddress}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Firewall Block Action
                                    Column(
                                      children: [
                                        Text(
                                          device.isBlocked ? 'BLOCKED' : 'BLOCK',
                                          style: TextStyle(
                                            color: device.isBlocked ? AppTheme.error : AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                        Switch(
                                          value: device.isBlocked,
                                          activeColor: AppTheme.error,
                                          inactiveThumbColor: AppTheme.primary,
                                          onChanged: (val) {
                                            provider.toggleBlockDevice(device.macAddress, val);
                                          },
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
            ),
    );
  }
}
