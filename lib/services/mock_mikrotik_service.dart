import 'dart:async';
import 'dart:math';
import '../models/router_metric.dart';
import '../models/router_device.dart';
import '../models/activity_log.dart';

class MockMikroTikService {
  final _random = Random();
  
  // Internal States
  double _currentCpu = 12.0;
  double _currentRam = 45.0;
  double _totalRam = 1024.0; // 1GB RouterBoard
  double _downSpeed = 4500.0; // Kbps
  double _upSpeed = 1200.0;   // Kbps
  int _uptimeSeconds = 34500;
  double _totalData = 14.2; // GB
  int _signalQuality = 92; // %
  double _temperature = 41.5; // °C

  final List<RouterDevice> _devices = [
    RouterDevice(macAddress: 'BC:D0:74:11:AB:23', ipAddress: '192.168.88.10', hostname: 'Admin-MacBook-Pro', downloadUsage: 450.0, uploadUsage: 80.0),
    RouterDevice(macAddress: 'D4:A3:3D:55:01:FF', ipAddress: '192.168.88.15', hostname: 'SmartTV-4K', downloadUsage: 12000.0, uploadUsage: 120.0), // high usage
    RouterDevice(macAddress: 'AA:11:BB:22:CC:33', ipAddress: '192.168.88.22', hostname: 'iPhone-Admin', downloadUsage: 25.0, uploadUsage: 10.0),
    RouterDevice(macAddress: '3E:D2:C1:F4:55:6A', ipAddress: '192.168.88.99', hostname: 'Unrecognized-IoT-Device', downloadUsage: 2.0, uploadUsage: 1.5),
    RouterDevice(macAddress: 'F8:E9:D0:C1:B2:A3', ipAddress: '192.168.88.104', hostname: 'Guest-Android-Phone', downloadUsage: 120.0, uploadUsage: 35.0),
  ];

  final List<ActivityLog> _logs = [
    ActivityLog(id: '1', timestamp: DateTime.now().subtract(const Duration(minutes: 15)), topic: 'system', message: 'router rebooted by admin', severity: 'info'),
    ActivityLog(id: '2', timestamp: DateTime.now().subtract(const Duration(minutes: 14)), topic: 'interface', message: 'ether1-wan link up (1Gbps)', severity: 'info'),
    ActivityLog(id: '3', timestamp: DateTime.now().subtract(const Duration(minutes: 12)), topic: 'dhcp', message: 'DHCP lease assigned to 192.168.88.10 (BC:D0:74:11:AB:23)', severity: 'info'),
    ActivityLog(id: '4', timestamp: DateTime.now().subtract(const Duration(minutes: 8)), topic: 'firewall', message: 'unauthorized ssh login attempt from 185.220.101.5 blocked', severity: 'warning'),
    ActivityLog(id: '5', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), topic: 'dhcp', message: 'DHCP lease assigned to 192.168.88.15 (D4:A3:3D:55:01:FF)', severity: 'info'),
  ];

  // Generate new metrics with small fluctuations
  RouterMetric generateNextMetric({bool simulateHighLoad = false}) {
    _uptimeSeconds += 2;
    _totalData += 0.0005; // Increment data consumed
    
    if (simulateHighLoad) {
      _currentCpu = 85.0 + _random.nextDouble() * 10;
      _currentRam = 90.0 + _random.nextDouble() * 5;
      _downSpeed = 95000.0 + _random.nextDouble() * 4000;
      _upSpeed = 25000.0 + _random.nextDouble() * 2000;
      _signalQuality = 75 + _random.nextInt(10);
      _temperature = 54.5 + _random.nextDouble() * 2.0; // Higher temp under high load
    } else {
      // Normal variation
      _currentCpu = max(5.0, min(95.0, _currentCpu + (_random.nextDouble() * 10 - 5)));
      _currentRam = max(30.0, min(95.0, _currentRam + (_random.nextDouble() * 2 - 1)));
      _downSpeed = max(50.0, _downSpeed + (_random.nextDouble() * 1000 - 500));
      _upSpeed = max(10.0, _upSpeed + (_random.nextDouble() * 400 - 200));
      _signalQuality = max(60, min(100, _signalQuality + (_random.nextInt(3) - 1)));
      _temperature = max(38.0, min(48.0, _temperature + (_random.nextDouble() * 0.4 - 0.2)));
    }

    final freeRam = _totalRam * (1.0 - (_currentRam / 100));

    return RouterMetric(
      cpuUsage: _currentCpu,
      ramUsage: _currentRam,
      totalRam: _totalRam,
      freeRam: freeRam,
      downloadSpeed: _downSpeed,
      uploadSpeed: _upSpeed,
      uptime: _formatUptime(_uptimeSeconds),
      timestamp: DateTime.now(),
      totalData: _totalData,
      signalQuality: _signalQuality,
      temperature: _temperature,
    );
  }

  // Get active leases / connected clients
  List<RouterDevice> getConnectedDevices() {
    return _devices.map((device) {
      if (device.isBlocked) {
        return device.copyWith(downloadUsage: 0.0, uploadUsage: 0.0, isOnline: false);
      }
      final downloadDiff = _random.nextDouble() * 100 - 50;
      final uploadDiff = _random.nextDouble() * 20 - 10;
      return device.copyWith(
        downloadUsage: max(0.0, device.downloadUsage + downloadDiff),
        uploadUsage: max(0.0, device.uploadUsage + uploadDiff),
        isOnline: true,
      );
    }).toList();
  }

  // Block/Unblock device toggle
  void toggleBlockDevice(String macAddress, bool block) {
    final idx = _devices.indexWhere((d) => d.macAddress == macAddress);
    if (idx >= 0) {
      _devices[idx] = _devices[idx].copyWith(isBlocked: block);
      
      final logMsg = block 
        ? 'interface: blocked client MAC $macAddress by admin' 
        : 'interface: unblocked client MAC $macAddress by admin';
        
      _logs.insert(0, ActivityLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        topic: 'firewall',
        message: logMsg,
        severity: block ? 'warning' : 'info',
      ));
    }
  }

  // Get live logs
  List<ActivityLog> getLogs() {
    return List.from(_logs);
  }

  // Add custom manual log entry
  void addLogEntry(String topic, String message, String severity) {
    _logs.insert(0, ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      topic: topic,
      message: message,
      severity: severity,
    ));
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    String daysStr = days > 0 ? '${days}d ' : '';
    return '$daysStr${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(secs)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
