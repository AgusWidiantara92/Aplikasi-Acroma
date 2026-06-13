import 'package:flutter_test/flutter_test.dart';
import 'package:acroma/models/router_metric.dart';
import 'package:acroma/models/router_device.dart';
import 'package:acroma/services/recommendation_service.dart';

void main() {
  group('Recommendation Service Tests', () {
    final recommendationService = RecommendationService();

    test('Should trigger high CPU warning when CPU > 80%', () {
      final metric = RouterMetric(
        cpuUsage: 85.0,
        ramUsage: 40.0,
        totalRam: 1024.0,
        freeRam: 600.0,
        downloadSpeed: 1500.0,
        uploadSpeed: 500.0,
        uptime: '05:23:11',
        timestamp: DateTime.now(),
        signalQuality: 90,
        temperature: 42.0,
        totalData: 15.0,
      );

      final recommendations = recommendationService.analyzeRouterState(
        routerId: 'test_router',
        metric: metric,
        devices: [],
      );

      expect(recommendations.length, 1);
      expect(recommendations.first.severity, 'critical');
      expect(recommendations.first.category, 'performance');
      expect(recommendations.first.title.contains('High CPU'), true);
    });

    test('Should flag heavy consumer user', () {
      final metric = RouterMetric(
        cpuUsage: 12.0,
        ramUsage: 40.0,
        totalRam: 1024.0,
        freeRam: 600.0,
        downloadSpeed: 1500.0,
        uploadSpeed: 500.0,
        uptime: '05:23:11',
        timestamp: DateTime.now(),
        signalQuality: 90,
        temperature: 42.0,
        totalData: 15.0,
      );

      final deviceList = [
        RouterDevice(
          macAddress: '11:22:33:44:55:66',
          ipAddress: '192.168.88.20',
          hostname: 'Heavy-Client-PC',
          downloadUsage: 6000.0, // > 5000 limit
          uploadUsage: 200.0,
        ),
      ];

      final recommendations = recommendationService.analyzeRouterState(
        routerId: 'test_router',
        metric: metric,
        devices: deviceList,
      );

      expect(recommendations.length, 1);
      expect(recommendations.first.severity, 'warning');
      expect(recommendations.first.title.contains('Abnormal Traffic'), true);
      expect(recommendations.first.targetDeviceMac, '11:22:33:44:55:66');
    });
  });
}
