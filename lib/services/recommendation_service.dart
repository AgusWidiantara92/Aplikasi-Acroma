import '../models/recommendation.dart';
import '../models/router_metric.dart';
import '../models/router_device.dart';

class RecommendationService {
  List<Recommendation> analyzeRouterState({
    required String routerId,
    required RouterMetric metric,
    required List<RouterDevice> devices,
  }) {
    final List<Recommendation> recommendations = [];
    final now = DateTime.now();

    // 1. CPU Rule
    if (metric.cpuUsage > 80.0) {
      recommendations.add(
        Recommendation(
          id: '${routerId}_cpu_${now.millisecondsSinceEpoch}',
          title: 'High CPU Utilization Detected',
          description: 'CPU is at ${metric.cpuUsage.toStringAsFixed(1)}%. This can cause packet drops. Recommend inspecting IP -> Firewall -> Connections for DDoS, disabling unnecessary queues, or rescheduling backup tasks.',
          severity: 'critical',
          category: 'performance',
          timestamp: now,
        ),
      );
    } else if (metric.cpuUsage > 60.0) {
      recommendations.add(
        Recommendation(
          id: '${routerId}_cpu_${now.millisecondsSinceEpoch}',
          title: 'Moderate CPU Activity',
          description: 'CPU is hovering at ${metric.cpuUsage.toStringAsFixed(1)}%. Keep an eye on system resources.',
          severity: 'info',
          category: 'performance',
          timestamp: now,
        ),
      );
    }

    // 2. Memory Rule
    if (metric.ramUsage > 85.0) {
      recommendations.add(
        Recommendation(
          id: '${routerId}_ram_${now.millisecondsSinceEpoch}',
          title: 'Critical Memory Shortage',
          description: 'Only ${metric.freeRam.toStringAsFixed(1)} MB of RAM remains. Disable unused system packages or limit DNS cache size to prevent router crash.',
          severity: 'critical',
          category: 'performance',
          timestamp: now,
        ),
      );
    }

    // 3. Unauthorized Client Check
    for (var device in devices) {
      // Check if device hostname is empty or looks suspicious, or if download speed is exceptionally high
      if (device.downloadUsage > 5000.0 && !device.isBlocked) { // > 5 MB/s
        recommendations.add(
          Recommendation(
            id: '${routerId}_heavy_user_${device.macAddress}',
            title: 'Abnormal Traffic from ${device.hostname}',
            description: 'Device with IP ${device.ipAddress} (${device.hostname}) is consuming ${ (device.downloadUsage / 1024).toStringAsFixed(1) } MB/s. Recommend applying a Simple Queue bandwidth limit (e.g., 5M/5M) or blocking the device.',
            severity: 'warning',
            category: 'performance',
            timestamp: now,
            targetDeviceMac: device.macAddress,
          ),
        );
      }

      // Flag unrecognized device signatures
      if (device.hostname.toLowerCase().contains('unrecognized') || 
          device.hostname.toLowerCase().contains('unknown')) {
        recommendations.add(
          Recommendation(
            id: '${routerId}_unrecognized_${device.macAddress}',
            title: 'Unrecognized Client Active',
            description: 'A client with MAC ${device.macAddress} has connected without a valid lease hostname. Ensure this is a recognized user or block MAC.',
            severity: 'warning',
            category: 'security',
            timestamp: now,
            targetDeviceMac: device.macAddress,
          ),
        );
      }
    }

    // 4. Bandwidth saturation rule
    final totalTraffic = metric.downloadSpeed + metric.uploadSpeed;
    if (totalTraffic > 90000.0) { // ~90 Mbps
      recommendations.add(
        Recommendation(
          id: '${routerId}_bandwidth_${now.millisecondsSinceEpoch}',
          title: 'WAN Interface Saturation',
          description: 'Internet traffic is peaking at ${(totalTraffic / 1024).toStringAsFixed(1)} Mbps. Consider enabling FastTrack rules under Firewall to bypass unnecessary connection tracking.',
          severity: 'warning',
          category: 'performance',
          timestamp: now,
        ),
      );
    }

    return recommendations;
  }
}
