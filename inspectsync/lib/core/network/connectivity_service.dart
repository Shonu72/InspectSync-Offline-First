import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Provides real connectivity status by combining [Connectivity] (network interface)
/// with an actual HTTP reachability check (DNS lookup).
///
/// Usage:
///   final service = ConnectivityService();
///   service.statusStream.listen((status) => print(status));
///   final isOnline = await service.checkNow();
///   service.dispose();
class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  Timer? _periodicCheck;

  ConnectivityStatus _status = ConnectivityStatus.unknown;
  ConnectivityStatus get status => _status;

  bool get isOnline => _status == ConnectivityStatus.online;
  bool get isOffline => _status == ConnectivityStatus.offline;

  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    // Listen for network interface changes (wifi on/off, mobile data toggle)
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _onConnectivityChanged(results);
    });

    // Periodic reachability check every 30 seconds
    _periodicCheck = Timer.periodic(const Duration(seconds: 30), (_) {
      checkNow();
    });

    // Initial check
    await checkNow();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      // No network interface at all — immediately go offline
      _updateStatus(ConnectivityStatus.offline);
    } else {
      // Network interface is available, but verify actual internet
      checkNow();
    }
  }

  /// Performs an actual reachability check by doing a DNS lookup.
  /// Returns `true` if the device can reach the internet.
  Future<bool> checkNow() async {
    try {
      // First check: does the OS report any network interface?
      final connectivityResults = await _connectivity.checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        _updateStatus(ConnectivityStatus.offline);
        return false;
      }

      // Second check: actual DNS lookup to verify internet reachability
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateStatus(ConnectivityStatus.online);
        return true;
      } else {
        _updateStatus(ConnectivityStatus.offline);
        return false;
      }
    } on SocketException catch (_) {
      _updateStatus(ConnectivityStatus.offline);
      return false;
    } on TimeoutException catch (_) {
      _updateStatus(ConnectivityStatus.offline);
      return false;
    } catch (e) {
      debugPrint('ConnectivityService: unexpected error: $e');
      _updateStatus(ConnectivityStatus.offline);
      return false;
    }
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      notifyListeners();
      debugPrint('ConnectivityService: status changed → $newStatus');
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _periodicCheck?.cancel();
    _statusController.close();
    super.dispose();
  }
}

enum ConnectivityStatus {
  online,
  offline,
  unknown,
}
