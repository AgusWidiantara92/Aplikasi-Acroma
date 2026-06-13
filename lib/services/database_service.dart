import 'package:firebase_database/firebase_database.dart';
import '../main.dart';
import '../models/router_profile.dart';
import '../models/router_metric.dart';

class DatabaseService {
  FirebaseDatabase? _dbInstance;
  bool _useLocalCache = !isFirebaseInitialized;
  
  final List<RouterProfile> _cachedProfiles = [];

  // Lazily retrieve database instance
  FirebaseDatabase get _db {
    if (_dbInstance == null && isFirebaseInitialized) {
      _dbInstance = FirebaseDatabase.instance;
    }
    return _dbInstance!;
  }

  DatabaseService() {
    if (isFirebaseInitialized) {
      try {
        _db.setPersistenceEnabled(true);
      } catch (e) {
        _useLocalCache = true;
      }
    }
  }

  bool get isOfflineMode => _useLocalCache;

  // Stream of Router Profiles
  Stream<List<RouterProfile>> getRouterProfiles(String userId) {
    if (_useLocalCache || !isFirebaseInitialized) {
      return Stream.value(_cachedProfiles);
    }

    try {
      final ref = _db.ref().child('users').child(userId).child('routers');
      return ref.onValue.map((event) {
        final List<RouterProfile> list = [];
        final Map<dynamic, dynamic>? values = event.snapshot.value as Map<dynamic, dynamic>?;
        if (values != null) {
          values.forEach((key, value) {
            list.add(RouterProfile.fromMap(value));
          });
        }
        return list;
      });
    } catch (e) {
      _useLocalCache = true;
      return Stream.value(_cachedProfiles);
    }
  }

  // Save new Router Profile
  Future<void> saveRouterProfile(String userId, RouterProfile profile) async {
    if (_useLocalCache || !isFirebaseInitialized) {
      final index = _cachedProfiles.indexWhere((p) => p.id == profile.id);
      if (index >= 0) {
        _cachedProfiles[index] = profile;
      } else {
        _cachedProfiles.add(profile);
      }
      return;
    }

    try {
      final ref = _db.ref().child('users').child(userId).child('routers').child(profile.id);
      await ref.set(profile.toMap());
    } catch (e) {
      _useLocalCache = true;
      await saveRouterProfile(userId, profile);
    }
  }

  // Delete Router Profile
  Future<void> deleteRouterProfile(String userId, String routerId) async {
    if (_useLocalCache || !isFirebaseInitialized) {
      _cachedProfiles.removeWhere((p) => p.id == routerId);
      return;
    }
    try {
      final ref = _db.ref().child('users').child(userId).child('routers').child(routerId);
      await ref.remove();
    } catch (e) {
      _useLocalCache = true;
      _cachedProfiles.removeWhere((p) => p.id == routerId);
    }
  }

  // Sync Live Metrics
  Stream<RouterMetric?> getLiveMetrics(String routerId) {
    if (_useLocalCache || !isFirebaseInitialized) {
      return Stream.value(null);
    }
    try {
      final ref = _db.ref().child('routers').child(routerId).child('metrics').limitToLast(1);
      return ref.onValue.map((event) {
        final Map<dynamic, dynamic>? values = event.snapshot.value as Map<dynamic, dynamic>?;
        if (values != null && values.isNotEmpty) {
          final firstKey = values.keys.first;
          return RouterMetric.fromMap(values[firstKey]);
        }
        return null;
      });
    } catch (e) {
      return Stream.value(null);
    }
  }
}
