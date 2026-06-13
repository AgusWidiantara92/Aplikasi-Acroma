import 'dart:async';
import 'package:flutter/material.dart';
import '../models/router_profile.dart';
import '../models/router_metric.dart';
import '../models/router_device.dart';
import '../models/activity_log.dart';
import '../models/recommendation.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'recommendation_service.dart';
import 'mock_mikrotik_service.dart';

class RouterProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final RecommendationService _recommendationService = RecommendationService();
  final MockMikroTikService _mockService = MockMikroTikService();

  // Active User State
  String? _userId;
  bool _isAuthenticated = false;

  // Router Selection
  List<RouterProfile> _routers = [];
  RouterProfile? _selectedRouter;

  // Real-time Dashboard States
  RouterMetric? _currentMetric;
  List<RouterMetric> _metricHistory = []; // to plot chart
  List<RouterDevice> _connectedDevices = [];
  List<ActivityLog> _logs = [];
  List<Recommendation> _recommendations = [];

  // Config Flags
  Timer? _metricTimer;
  bool _simulateHighLoad = false;
  bool _isRebooting = false;

  // Getters
  AuthService get authService => _authService;
  bool get isAuthenticated => _isAuthenticated;
  List<RouterProfile> get routers => _routers;
  RouterProfile? get selectedRouter => _selectedRouter;
  RouterMetric? get currentMetric => _currentMetric;
  List<RouterMetric> get metricHistory => _metricHistory;
  List<RouterDevice> get connectedDevices => _connectedDevices;
  List<ActivityLog> get logs => _logs;
  List<Recommendation> get recommendations => _recommendations;
  bool get simulateHighLoad => _simulateHighLoad;
  bool get isRebooting => _isRebooting;

  RouterProvider() {
    // Listen to user auth state
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _userId = user.uid;
        _isAuthenticated = true;
        _listenToRouterProfiles();
      } else {
        if (_authService.isDemoMode) {
          _userId = 'demo_user_id';
          _isAuthenticated = true;
          _loadDemoRouterProfiles();
        } else {
          _userId = null;
          _isAuthenticated = false;
          _stopMetricsStream();
        }
      }
      notifyListeners();
    });
  }

  // --- AUTHENTICATION FLOWS ---
  Future<bool> login(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      if (_authService.isDemoMode) {
        _userId = 'demo_user_id';
        _isAuthenticated = true;
        _loadDemoRouterProfiles();
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _routers = [];
    _selectedRouter = null;
    _stopMetricsStream();
    notifyListeners();
  }

  // --- ROUTER CONFIGURATION ---
  void _listenToRouterProfiles() {
    if (_userId == null) return;
    _databaseService.getRouterProfiles(_userId!).listen((list) {
      _routers = list;
      if (_selectedRouter != null) {
        // Refresh selected router if in list
        final index = _routers.indexWhere((r) => r.id == _selectedRouter!.id);
        if (index >= 0) {
          _selectedRouter = _routers[index];
        }
      }
      notifyListeners();
    });
  }

  void _loadDemoRouterProfiles() {
    _routers = [
      RouterProfile(id: 'r1', nickname: 'Core-RouterBoard-MikroTik', host: '192.168.88.1', port: 8728, username: 'admin', password: 'password', isOnline: true),
      RouterProfile(id: 'r2', nickname: 'Branch-Office-HexS', host: '10.0.0.1', port: 8728, username: 'admin', password: 'password', isOnline: false),
    ];
    selectRouter(_routers.first);
  }

  Future<void> addRouter(String nickname, String host, int port, String username, String password) async {
    if (_userId == null) return;
    final newRouter = RouterProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nickname: nickname,
      host: host,
      port: port,
      username: username,
      password: password,
      isOnline: true,
    );

    if (_authService.isDemoMode) {
      _routers.add(newRouter);
      notifyListeners();
    } else {
      await _databaseService.saveRouterProfile(_userId!, newRouter);
    }
  }

  Future<void> deleteRouter(String id) async {
    if (_userId == null) return;
    if (_selectedRouter?.id == id) {
      _selectedRouter = null;
      _stopMetricsStream();
    }
    if (_authService.isDemoMode) {
      _routers.removeWhere((r) => r.id == id);
      notifyListeners();
    } else {
      await _databaseService.deleteRouterProfile(_userId!, id);
    }
  }

  void selectRouter(RouterProfile router) {
    _selectedRouter = router;
    _stopMetricsStream();
    if (router.isOnline) {
      _startMetricsStream();
    }
    notifyListeners();
  }

  // --- LIVE MONITORING STREAM (SIMULATION & DATABASE ENGINE) ---
  void _startMetricsStream() {
    _metricHistory = [];
    _currentMetric = null;
    
    // Poll metrics every 2 seconds
    _metricTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_selectedRouter == null || _isRebooting) return;

      // In real setup, we would read from Firebase Realtime Database:
      // _databaseService.getLiveMetrics(_selectedRouter!.id).listen(...)
      // For instant wow visual feedback, we combine it with the Mock Service generator:
      final nextMetric = _mockService.generateNextMetric(simulateHighLoad: _simulateHighLoad);
      _currentMetric = nextMetric;

      // Keep last 15 elements in history for graph plotting
      _metricHistory.add(nextMetric);
      if (_metricHistory.length > 15) {
        _metricHistory.removeAt(0);
      }

      // Sync active leases
      _connectedDevices = _mockService.getConnectedDevices();

      // Sync logs
      _logs = _mockService.getLogs();

      // Run AI/Rule-based Recommendation Engine
      _recommendations = _recommendationService.analyzeRouterState(
        routerId: _selectedRouter!.id,
        metric: _currentMetric!,
        devices: _connectedDevices,
      );

      notifyListeners();
    });
  }

  void _stopMetricsStream() {
    _metricTimer?.cancel();
    _metricTimer = null;
    _currentMetric = null;
    _metricHistory.clear();
    _connectedDevices.clear();
    _recommendations.clear();
    _logs.clear();
  }

  // --- ROUTER CONTROLS ---
  void toggleBlockDevice(String macAddress, bool block) {
    _mockService.toggleBlockDevice(macAddress, block);
    _connectedDevices = _mockService.getConnectedDevices();
    notifyListeners();
  }

  Future<void> rebootRouter() async {
    if (_selectedRouter == null) return;
    _isRebooting = true;
    _stopMetricsStream();
    
    // Add reboot log
    _mockService.addLogEntry('system', 'router reboot initiated via mobile app', 'warning');
    notifyListeners();

    // Simulate reboot delay
    await Future.delayed(const Duration(seconds: 4));
    
    _isRebooting = false;
    _mockService.addLogEntry('system', 'router reboot complete', 'info');
    if (_selectedRouter != null) {
      _startMetricsStream();
    }
    notifyListeners();
  }

  // Debug/Test toggle for AI Rule engine
  void toggleHighLoadSimulation() {
    _simulateHighLoad = !_simulateHighLoad;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopMetricsStream();
    super.dispose();
  }
}
