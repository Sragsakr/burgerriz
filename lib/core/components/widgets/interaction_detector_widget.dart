import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';

/// Global interaction detector manager to prevent multiple instances
class InteractionDetectorManager {
  static final InteractionDetectorManager _instance =
      InteractionDetectorManager._internal();
  factory InteractionDetectorManager() => _instance;
  InteractionDetectorManager._internal();

  Timer? _globalInactivityTimer;
  Timer? _globalWarningTimer;
  bool _isActive = true;
  bool _showWarning = false;
  bool _isAppInBackground = false;
  DateTime? _lastInteractionTime;
  DateTime? _timerStartTime;
  String? _currentInstanceId;
  VoidCallback? _onInactivityCallback;
  Duration _timeoutDuration = const Duration(seconds: 60);
  Duration _warningDuration = const Duration(seconds: 10);
  bool _showWarningEnabled = true;

  // Execution flags to prevent callbacks from running after cancellation
  bool _allowWarningCallback = false;
  bool _allowInactivityCallback = false;

  void registerInstance(
    String instanceId, {
    required VoidCallback onInactivity,
    required Duration timeoutDuration,
    required Duration warningDuration,
    required bool showWarning,
  }) {
    dPrint("Registering InteractionDetector instance: $instanceId");

    // If there's already an active instance, cancel it
    if (_currentInstanceId != null && _currentInstanceId != instanceId) {
      dPrint("Cancelling previous instance: $_currentInstanceId");
      _cancelAllTimers();
    }

    _currentInstanceId = instanceId;
    _onInactivityCallback = onInactivity;
    _timeoutDuration = timeoutDuration;
    _warningDuration = warningDuration;
    _showWarningEnabled = showWarning;

    _startGlobalTimer();
  }

  void unregisterInstance(String instanceId) {
    if (_currentInstanceId == instanceId) {
      dPrint("Unregistering InteractionDetector instance: $instanceId");
      _cancelAllTimers();
      _currentInstanceId = null;
      _onInactivityCallback = null;
    }
  }

  void resetTimer(String instanceId) {
    if (_currentInstanceId == instanceId) {
      dPrint(
          "[$instanceId] Resetting global timer due to user interaction - current state: active=$_isActive, warning=$_showWarning");
      _lastInteractionTime = DateTime.now();
      _isActive = true;
      _showWarning = false;
      _notifyWarningStateChange();
      _startGlobalTimer();
    } else {
      dPrint(
          "[$instanceId] Reset timer ignored - not current instance. Current: $_currentInstanceId");
    }
  }

  void pauseTimers() {
    dPrint("Pausing global timers - app going to background");
    _isAppInBackground = true;
    _cancelAllTimers();
  }

  void resumeTimers() {
    dPrint("Resuming global timers - app coming to foreground");
    _isAppInBackground = false;
    if (_isActive &&
        _lastInteractionTime != null &&
        _currentInstanceId != null) {
      _startGlobalTimer();
    }
  }

  void _startGlobalTimer() {
    dPrint(
        "[$_currentInstanceId] Starting global inactivity timer - Timeout: ${_timeoutDuration.inSeconds}s, Warning: ${_warningDuration.inSeconds}s");
    dPrint(
        "[$_currentInstanceId] Pre-start state: active=$_isActive, warning=$_showWarning, background=$_isAppInBackground");

    _cancelAllTimers();
    _isActive = true; // Ensure we're active when starting new timer
    _timerStartTime = DateTime.now();
    _lastInteractionTime = _timerStartTime;

    dPrint(
        "[$_currentInstanceId] Post-start state: active=$_isActive, warning=$_showWarning, background=$_isAppInBackground");

    if (_showWarningEnabled && _warningDuration < _timeoutDuration) {
      final warningTime = _timeoutDuration - _warningDuration;
      dPrint(
          "[$_currentInstanceId] Setting global warning timer for ${warningTime.inSeconds} seconds");

      _allowWarningCallback = true;
      _globalWarningTimer = Timer(warningTime, () {
        dPrint(
            "[$_currentInstanceId] Warning timer callback executing - allow: $_allowWarningCallback, active: $_isActive, background: $_isAppInBackground");
        if (_allowWarningCallback && _isActive && !_isAppInBackground) {
          dPrint(
              "[$_currentInstanceId] Global warning timer triggered - showing warning");
          _showWarning = true;
          _notifyWarningStateChange();
        } else {
          dPrint(
              "Global warning timer callback ignored - allow: $_allowWarningCallback, active: $_isActive, background: $_isAppInBackground");
        }
      });
    }

    _allowInactivityCallback = true;
    _globalInactivityTimer = Timer(_timeoutDuration, () {
      dPrint(
          "[$_currentInstanceId] Inactivity timer callback executing - allow: $_allowInactivityCallback, active: $_isActive, background: $_isAppInBackground");
      if (_allowInactivityCallback && _isActive && !_isAppInBackground) {
        dPrint(
            "[$_currentInstanceId] Global inactivity timer triggered - calling onInactivity");
        _isActive = false;
        _showWarning = false;
        _notifyWarningStateChange();
        _onInactivityCallback?.call();
      } else {
        dPrint(
            "Global inactivity timer callback ignored - allow: $_allowInactivityCallback, active: $_isActive, background: $_isAppInBackground");
      }
    });
  }

  void _cancelAllTimers() {
    dPrint(
        "[$_currentInstanceId] Cancelling all timers and disabling callbacks");
    _allowWarningCallback = false;
    _allowInactivityCallback = false;
    _globalInactivityTimer?.cancel();
    _globalWarningTimer?.cancel();
    _globalInactivityTimer = null;
    _globalWarningTimer = null;
  }

  bool get showWarning => _showWarning;
  bool get isActive => _isActive;

  // Stream controller for state changes
  final StreamController<bool> _warningStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get warningStateStream => _warningStateController.stream;

  void _notifyWarningStateChange() {
    _warningStateController.add(_showWarning);
  }
}

/// A more advanced version that provides additional features
/// like visual feedback and customizable behavior
class InteractionDetectorWidget extends StatefulWidget {
  /// The child widget to wrap
  final Widget child;

  /// Callback function to execute when user is inactive
  final VoidCallback onInactivity;

  /// Duration of inactivity before triggering the callback
  final Duration timeoutDuration;

  /// Whether to show a warning before timeout (default: true)
  final bool showWarning;

  /// Duration before timeout to show warning (default: 5 seconds)
  final Duration warningDuration;

  /// Custom warning widget
  final Widget? warningWidget;

  /// Whether to pause timer when app goes to background (default: true)
  final bool pauseOnBackground;

  /// Whether to detect mouse/touch interactions
  final bool detectPointer;

  /// Whether to detect keyboard interactions
  final bool detectKeyboard;

  /// Whether to detect scroll interactions
  final bool detectScroll;

  const InteractionDetectorWidget({
    super.key,
    required this.child,
    required this.onInactivity,
    this.timeoutDuration = const Duration(seconds: 60),
    this.showWarning = true,
    this.warningDuration = const Duration(seconds: 10),
    this.warningWidget,
    this.pauseOnBackground = true,
    this.detectPointer = true,
    this.detectKeyboard = true,
    this.detectScroll = true,
  });

  @override
  State<InteractionDetectorWidget> createState() =>
      _InteractionDetectorWidgetState();
}

class _InteractionDetectorWidgetState extends State<InteractionDetectorWidget>
    with WidgetsBindingObserver {
  late final String _instanceId;
  final InteractionDetectorManager _manager = InteractionDetectorManager();
  StreamSubscription<bool>? _warningStateSubscription;

  @override
  void initState() {
    super.initState();
    _instanceId = DateTime.now().millisecondsSinceEpoch.toString();
    dPrint("Initializing InteractionDetectorWidget instance: $_instanceId");

    // Register with global manager
    _manager.registerInstance(
      _instanceId,
      onInactivity: widget.onInactivity,
      timeoutDuration: widget.timeoutDuration,
      warningDuration: widget.warningDuration,
      showWarning: widget.showWarning,
    );

    // Listen to warning state changes
    _warningStateSubscription =
        _manager.warningStateStream.listen((showWarning) {
      if (mounted) {
        setState(() {
          // State will be updated by the stream
        });
      }
    });

    if (widget.pauseOnBackground) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    dPrint("Disposing InteractionDetectorWidget instance: $_instanceId");
    _warningStateSubscription?.cancel();
    _manager.unregisterInstance(_instanceId);
    if (widget.pauseOnBackground) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (widget.pauseOnBackground) {
      final isAppInBackground = state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive;

      if (isAppInBackground) {
        _manager.pauseTimers();
      } else {
        _manager.resumeTimers();
      }
    }
  }

  void _resetTimer() {
    _manager.resetTimer(_instanceId);
  }

  void _handlePointerEvent(int interactionType) {
    if (widget.detectPointer) {
      dPrint("Handling pointer event: $interactionType");
      _resetTimer();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (widget.detectKeyboard) {
      _resetTimer();
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (widget.detectScroll) {
      _resetTimer();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _handlePointerEvent(1),
          onTapDown: (details) => _handlePointerEvent(2),
          onTapUp: (details) => _handlePointerEvent(3),
          onTapCancel: () => _handlePointerEvent(4),
          onVerticalDragStart: (details) => _handlePointerEvent(5),
          onVerticalDragUpdate: (details) => _handlePointerEvent(6),
          onVerticalDragEnd: (details) => _handlePointerEvent(7),
          onVerticalDragCancel: () => _handlePointerEvent(8),
          onHorizontalDragStart: (details) => _handlePointerEvent(9),
          onHorizontalDragUpdate: (details) => _handlePointerEvent(10),
          onHorizontalDragEnd: (details) => _handlePointerEvent(11),
          onHorizontalDragCancel: () => _handlePointerEvent(12),
          onDoubleTap: () => _handlePointerEvent(20),
          onLongPress: () => _handlePointerEvent(21),
          onLongPressStart: (details) => _handlePointerEvent(22),
          onLongPressMoveUpdate: (details) => _handlePointerEvent(23),
          onLongPressUp: () => _handlePointerEvent(24),
          onLongPressEnd: (details) => _handlePointerEvent(25),
          onForcePressStart: (details) => _handlePointerEvent(26),
          onForcePressEnd: (details) => _handlePointerEvent(27),
          onForcePressUpdate: (details) => _handlePointerEvent(29),
          onForcePressPeak: (details) => _handlePointerEvent(31),
          child: widget.child,
        ),
        if (_manager.showWarning)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  // Don't reset timer when clicking outside the dialog
                  dPrint("Warning overlay tapped - not resetting timer");
                },
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: widget.warningWidget ??
                        GestureDetector(
                          onTap: () {
                            // Prevent dialog from being dismissed by clicking on it
                            dPrint("Warning dialog tapped - not dismissing");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 48,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  translator(
                                    arText: 'تنبيه وقت انتهاء الجلسة',
                                    enText: 'Session Timeout Warning',
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  translator(
                                    arText:
                                        'سيتم تحويلك في ${widget.warningDuration.inSeconds} ثانية بسبب الغياب.',
                                    enText:
                                        'You will be redirected in ${widget.warningDuration.inSeconds} seconds due to inactivity.',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    dPrint(
                                        "[$_instanceId] Continue session button pressed");
                                    _resetTimer();
                                  },
                                  child: Text(
                                    translator(
                                      arText: 'استمرار الجلسة',
                                      enText: 'Continue Session',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
