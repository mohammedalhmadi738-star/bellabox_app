import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();
  final connectivity = Connectivity();

  // Initial value
  connectivity.checkConnectivity().then((results) {
    controller.add(_hasConnection(results));
  });

  final sub = connectivity.onConnectivityChanged.listen((results) {
    controller.add(_hasConnection(results));
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

bool _hasConnection(List<ConnectivityResult> results) {
  return results.any((r) =>
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet);
}
