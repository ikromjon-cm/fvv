import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../shared/widgets/app_icon.dart';

class ConnectivityService {
  factory ConnectivityService() => _instance;
  ConnectivityService._();
  static final ConnectivityService _instance = ConnectivityService._();

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void init() {
    _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(online);
      }
    });
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    _controller.add(_isOnline);
  }

  void dispose() => _controller.close();
}

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key, required this.child});
  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _isOnline = true;
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _isOnline = true; // optimistic — don't flash offline on first load
    bool seenFirst = false;

    _sub = ConnectivityService().onConnectivityChanged.listen((online) {
      if (!seenFirst) {
        seenFirst = true;
        if (mounted) setState(() => _isOnline = online);
        return; // don't animate on first check
      }
      if (online == _isOnline) return;
      if (mounted) setState(() => _isOnline = online);
      if (!online) {
        _animCtrl.forward();
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _animCtrl.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut)),
            child: SafeArea(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: _isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      _isOnline ? 'wifi' : 'wifi_off',
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? "Internet tiklandi" : "Internet aloqasi yo'q",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
