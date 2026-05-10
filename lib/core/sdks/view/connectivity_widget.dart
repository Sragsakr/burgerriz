import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../helpers/app_dialogs.dart';
import '../../services/sync_services/connectivity_service.dart';

/// A widget that monitors connectivity status and shows notifications
/// when the internet connection status changes
class ConnectivityWidget extends StatefulWidget {
  final Widget child;
  final bool showSnackbar;
  final bool showDialog;
  final Duration snackbarDuration;
  final String? connectedMessage;
  final String? disconnectedMessage;
  final Color? connectedColor;
  final Color? disconnectedColor;
  final bool enableDebugLogs;

  const ConnectivityWidget({
    Key? key,
    required this.child,
    this.showSnackbar = true,
    this.showDialog = false,
    this.snackbarDuration = const Duration(seconds: 3),
    this.connectedMessage,
    this.disconnectedMessage,
    this.connectedColor,
    this.disconnectedColor,
    this.enableDebugLogs = true,
  }) : super(key: key);

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult>? _lastStatus;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableDebugLogs) {
      print('🎯 ConnectivityWidget: initState() called');
    }
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    if (widget.enableDebugLogs) {
      print('🔧 ConnectivityWidget: Initializing connectivity...');
    }
    
    // Initialize the connectivity service
    _connectivityService.initialize();
    
    // Get initial status
    try {
      final initialStatus = await _connectivityService.getCurrentStatus();
      _lastStatus = initialStatus;
      if (widget.enableDebugLogs) {
        print('📊 ConnectivityWidget: Initial status: $initialStatus');
      }
    } catch (e) {
      if (widget.enableDebugLogs) {
        print('❌ ConnectivityWidget: Error getting initial status: $e');
      }
    }
    
    // Listen to connectivity changes
    _subscription = _connectivityService.connectivityStream.listen(
      _onConnectivityChanged,
      onError: (error) {
        if (widget.enableDebugLogs) {
          print('❌ ConnectivityWidget: Stream error: $error');
        }
      },
    );
    
    setState(() {
      _isInitialized = true;
    });
    
    if (widget.enableDebugLogs) {
      print('✅ ConnectivityWidget: Initialization complete');
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (widget.enableDebugLogs) {
      print('📡 ConnectivityWidget: Connectivity changed to: $results');
      print('📋 ConnectivityWidget: Previous status: $_lastStatus');
    }
    
    // Only show notification if status actually changed
    if (_lastStatus == null || !_listEquals(_lastStatus!, results)) {
      _lastStatus = results;
      
      if (widget.enableDebugLogs) {
        print('🔄 ConnectivityWidget: Status changed, showing notification...');
      }
      
      // Use post frame callback to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showConnectivityNotification(results);
        } else {
          if (widget.enableDebugLogs) {
            print('⚠️ ConnectivityWidget: Widget not mounted, skipping notification');
          }
        }
      });
    } else {
      if (widget.enableDebugLogs) {
        print('⏭️ ConnectivityWidget: Status unchanged, skipping notification');
      }
    }
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _showConnectivityNotification(List<ConnectivityResult> results) {
    final isConnected = !results.contains(ConnectivityResult.none);
    
    if (widget.enableDebugLogs) {
      print('🔔 ConnectivityWidget: Showing notification - Connected: $isConnected');
    }
    
    if (widget.showSnackbar) {
      _showSnackbar(isConnected);
    }
    
    if (widget.showDialog) {
      _showDialog(isConnected);
    }
  }

  void _showSnackbar(bool isConnected) {
    final message = isConnected 
        ? (widget.connectedMessage ?? 'Connected to internet')
        : (widget.disconnectedMessage ?? 'No internet connection');
    
    final color = isConnected 
        ? (widget.connectedColor ?? Colors.green)
        : (widget.disconnectedColor ?? Colors.red);

    if (widget.enableDebugLogs) {
      print('🍞 ConnectivityWidget: Showing SnackBar - Message: $message, Color: $color');
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          duration: widget.snackbarDuration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      if (widget.enableDebugLogs) {
        print('✅ ConnectivityWidget: SnackBar shown successfully');
      }
    } catch (e) {
      if (widget.enableDebugLogs) {
        print('❌ ConnectivityWidget: Error showing SnackBar: $e');
      }
    }
  }

  void _showDialog(bool isConnected) {
    final title = isConnected ? 'Connected' : 'Disconnected';
    final message = isConnected 
        ? (widget.connectedMessage ?? 'You are now connected to the internet')
        : (widget.disconnectedMessage ?? 'You have lost internet connection');
    
    final icon = isConnected ? Icons.wifi : Icons.wifi_off;
    final color = isConnected 
        ? (widget.connectedColor ?? Colors.green)
        : (widget.disconnectedColor ?? Colors.red);

    if (widget.enableDebugLogs) {
      print('💬 ConnectivityWidget: Showing Dialog - Title: $title, Message: $message');
    }

    try {
      showAppDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      
      if (widget.enableDebugLogs) {
        print('✅ ConnectivityWidget: Dialog shown successfully');
      }
    } catch (e) {
      if (widget.enableDebugLogs) {
        print('❌ ConnectivityWidget: Error showing Dialog: $e');
      }
    }
  }

  @override
  void dispose() {
    if (widget.enableDebugLogs) {
      print('🧹 ConnectivityWidget: dispose() called');
    }
    
    _subscription?.cancel();
    _subscription = null;
    
    if (widget.enableDebugLogs) {
      print('✅ ConnectivityWidget: Disposed successfully');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      if (widget.enableDebugLogs) {
        print('⏳ ConnectivityWidget: Building loading state');
      }
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.enableDebugLogs) {
      print('🏗️ ConnectivityWidget: Building main content');
    }

    return widget.child;
  }
}

/// A simpler widget that just shows connectivity status without notifications
class ConnectivityStatusWidget extends StatelessWidget {
  final Widget Function(bool isConnected) builder;
  final bool enableDebugLogs;

  const ConnectivityStatusWidget({
    Key? key,
    required this.builder,
    this.enableDebugLogs = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (enableDebugLogs) {
      print('🎯 ConnectivityStatusWidget: Building status widget');
    }
    
    final connectivityService = ConnectivityService();
    connectivityService.initialize();

    return StreamBuilder<List<ConnectivityResult>>(
      stream: connectivityService.connectivityStream,
      initialData: connectivityService.lastResult,
      builder: (context, snapshot) {
        final isConnected = snapshot.data != null && 
            !snapshot.data!.contains(ConnectivityResult.none);
        
        if (enableDebugLogs) {
          print('📊 ConnectivityStatusWidget: Status - Connected: $isConnected, Data: ${snapshot.data}');
        }
        
        return builder(isConnected);
      },
    );
  }
}
