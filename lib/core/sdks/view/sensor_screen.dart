import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/led_status_manager.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/usb_plugin.dart';
import 'package:kiosk_point_of_sale/core/sdks/view/connectivity_widget.dart';

class SensorScreen extends StatefulWidget {
  final Widget child;
  final Function(bool) onChangeShow;
  final bool resetSensorsOnInit;

  const SensorScreen({
    super.key,
    required this.child,
    required this.onChangeShow,
    this.resetSensorsOnInit = false,
  });

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen>
    with AutomaticKeepAliveClientMixin {
  String? _suPort;
  String? _siPort;
  int sensorValue = 0;
  SensorStatus sensorStatus = SensorStatus.UNKNOWN;
  List<String> availablePorts = [];
  bool isStarted = false;
  int selectedIrLevel = 1;
  int sensorThreshold = 15;
  Timer? _sensorTimer;
  StreamSubscription<LEDStatus>? _ledStatusSubscription;
  StreamSubscription<SensorUpdate>? _suSensorSubscription;

  // Add sensor state tracking variables
  bool _isInitialized = false;
  bool _sensorsRunning = false;
  bool _isDisposing = false;

  @override
  bool get wantKeepAlive => true;

  String? route;

  @override
  void initState() {
    super.initState();

    // Reset sensor state if requested
    initScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload threshold in case it was changed from settings
    _loadSensorThreshold();
  }

  Future<void> initScreen() async {
    // Load sensor threshold from shared preferences
    await _loadSensorThreshold();

    // Check if motion sensor is enabled
    final motionSensorEnabled =
        await AppPreferences().getBool('motion_sensor_enabled');
    // Check if RGB LED is enabled
    final rgbLedEnabled = await AppPreferences().getBool('rgb_led_enabled');
    if (!motionSensorEnabled && !rgbLedEnabled) {
      dPrint(
          "SensorScreen: Motion sensor and RGB LED are disabled, skipping initialization");
      return;
    }
    // Reset sensor state if requested
    if (widget.resetSensorsOnInit) {
      dPrint("SensorScreen: Resetting sensors on init as requested");
      resetSensorState();
    }

    if (!_isInitialized) {
      dPrint("SensorScreen: Initializing sensors for the first time");
      _initializeUsbPlugin();
      sensorValueTimer();
      _initializeLEDManager();
      _isInitialized = true;
    } else {
      dPrint("SensorScreen: Already initialized, skipping re-initialization");
    }
  }

  /// sesorvalueTime
  sensorValueTimer() async {
    _sensorTimer = Timer.periodic(Duration(seconds: 10), (x) async {
      dPrint("sensorValueTimer");
      if (!mounted || _isDisposing) return;

      // Check if any sensors are enabled before updating
      final motionSensorEnabled =
          await AppPreferences().getBool('motion_sensor_enabled');
      final rgbLedEnabled = await AppPreferences().getBool('rgb_led_enabled');

      if ((motionSensorEnabled || rgbLedEnabled) && !_sensorsRunning) {
        dPrint("SensorScreen: Timer detected sensors need to be started");
        await _ensureSensorsRunning();
      }
    });
  }

  /// Ensure sensors are running if they should be
  Future<void> _ensureSensorsRunning() async {
    if (_sensorsRunning || _isDisposing) {
      dPrint("SensorScreen: Sensors already running or disposing, skipping");
      return;
    }

    final motionSensorEnabled =
        await AppPreferences().getBool('motion_sensor_enabled');
    final rgbLedEnabled = await AppPreferences().getBool('rgb_led_enabled');

    if (motionSensorEnabled || rgbLedEnabled) {
      dPrint("SensorScreen: Ensuring sensors are running");
      await getPortsAndStartDevices();
    }
  }

  Future<void> _initializeUsbPlugin() async {
    try {
      await UsbPlugin.initialize();

      await _ensureSensorsRunning();

      // Cancel any existing subscription first
      _suSensorSubscription?.cancel();

      // Check if motion sensor is enabled before setting up listener
      final motionSensorEnabled =
          await AppPreferences().getBool('motion_sensor_enabled');

      if (motionSensorEnabled) {
        _suSensorSubscription = UsbPlugin.suSensorUpdates.listen(
          (data) {
            if (!mounted) return; // Safety check
            setState(() {
              sensorValue = data.value;
              sensorStatus = data.status;
              bool show = getStatusValue() != 3;
              dPrint('show: $show');
              widget.onChangeShow(show);
            });
          },
          onError: (error) {
            dPrint('SU Sensor stream error: $error');
          },
          onDone: () {
            dPrint('SU Sensor stream closed');
          },
        );
      } else {
        dPrint('Motion sensor is disabled, not setting up SU sensor listener');
        // Set default values when motion sensor is disabled
        setState(() {
          sensorValue = 0;
          sensorStatus = SensorStatus.UNKNOWN;
          widget
              .onChangeShow(true); // Always show when motion sensor is disabled
        });
      }
      final rgbLedEnabled = await AppPreferences().getBool('rgb_led_enabled');
      // Update LED status manager with show status only if RGB LED is enabled
      if (rgbLedEnabled) {
        dPrint(
            "SensorScreen: RGB LED is enabled, updating show status to false");
        try {
          LEDStatusManager.instance.updateShowStatus(false);
          LEDStatusManager.instance.updateShowStatus(false);
        } catch (e, st) {
          dPrint("SensorScreen: Failed to update show status: $e");
          dPrint("SensorScreen: Stack trace: $st");
        }
      }
    } catch (e, st) {
      dPrint("Initialization failed: $e");
      dPrint("Initialization failed: $st");
    }
  }

  Future<void> getPortsAndStartDevices() async {
    if (_sensorsRunning || _isDisposing) {
      dPrint(
          "SensorScreen: Sensors already running or disposing, skipping getPortsAndStartDevices");
      return;
    }

    dPrint("SensorScreen: Starting getPortsAndStartDevices");

    // Check if motion sensor is enabled
    final motionSensorEnabled =
        await AppPreferences().getBool('motion_sensor_enabled');
    // Check if RGB LED is enabled
    final rgbLedEnabled = await AppPreferences().getBool('rgb_led_enabled');

    final suPorts = await UsbPlugin.getPorts(DeviceType.SU);
    final siPorts = await UsbPlugin.getPorts(DeviceType.SI);

    if (mounted) {
      setState(() {
        _suPort = suPorts.isNotEmpty ? suPorts.first : null;
        _siPort = siPorts.isNotEmpty ? siPorts.first : null;
      });
    }

    // Update LED manager with SI port only if RGB LED is enabled
    if (rgbLedEnabled) {
      LEDStatusManager.instance.updateShowStatus(false);
      LEDStatusManager.instance.updateShowStatus(false);
      LEDStatusManager.instance.updateSIPort(_siPort);
    } else {
      LEDStatusManager.instance.updateSIPort(null);
    }

    // Start SI sensor only if RGB LED is enabled and port is available
    if (rgbLedEnabled && _siPort != null) {
      await _stopSI();
      await _startSI();
    } else if (!rgbLedEnabled) {
      // Stop SI sensor if RGB LED is disabled
      await _stopSI();
    }

    // Start SU sensor only if motion sensor is enabled
    if (motionSensorEnabled) {
      await _stopSU();
      await _startSU();
    } else {
      // Stop SU sensor if motion sensor is disabled
      await _stopSU();
    }

    // Mark sensors as running
    _sensorsRunning = true;
    dPrint("SensorScreen: Sensors started successfully");
  }

  Future<void> _startSU() async {
    try {
      if (_suPort == null) {
        dPrint('SensorScreen: No SU port available');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No SU port available')),
          );
        }
        return;
      }

      dPrint(
          'SensorScreen: Starting SU sensor on $_suPort with IR level $selectedIrLevel');
      await UsbPlugin.startSensor(DeviceType.SU, _suPort!,
          irLevel: selectedIrLevel.toInt());
      dPrint('SensorScreen: SU sensor started successfully');

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content: Text(
      //           'Started SU sensor on $_suPort with IR level $selectedIrLevel')),
      // );
    } catch (e, st) {
      dPrint('SensorScreen: Failed to start SU sensor: $e');
      dPrint('SensorScreen: Stack trace: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start SU: $e')),
        );
      }
    }
  }

  Future<void> _startSI() async {
    try {
      if (_siPort == null) {
        dPrint('SensorScreen: No SI port available');
        return;
      }

      dPrint('SensorScreen: Starting SI sensor on $_siPort');
      await UsbPlugin.startSensor(DeviceType.SI, _siPort!);
      dPrint('SensorScreen: SI sensor started successfully');
    } catch (e, st) {
      dPrint('SensorScreen: Failed to start SI sensor: $e');
      dPrint('SensorScreen: Stack trace: $st');
    }
  }

  Future<void> _stopSI() async {
    try {
      dPrint('SensorScreen: Stopping SI sensor');
      await UsbPlugin.stopSensor(DeviceType.SI);
      dPrint('SensorScreen: SI sensor stopped successfully');
    } catch (e, st) {
      dPrint('SensorScreen: Failed to stop SI sensor: $e');
      dPrint('SensorScreen: Stack trace: $st');
    }
  }

  Future<void> _stopSU() async {
    try {
      dPrint('SensorScreen: Stopping SU sensor');
      await UsbPlugin.stopSensor(DeviceType.SU);
      dPrint('SensorScreen: SU sensor stopped successfully');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('SU sensor stopped')),
      // );
    } catch (e, st) {
      dPrint('SensorScreen: Failed to stop SU sensor: $e');
      dPrint('SensorScreen: Stack trace: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop SU: $e')),
        );
      }
    }
  }

  /// Reset sensor state when returning to screen
  void resetSensorState() {
    dPrint("SensorScreen: Resetting sensor state");
    _sensorsRunning = false;
    _isInitialized = false;
  }

  /// Initialize LED status manager
  void _initializeLEDManager() async {
    // Cancel any existing subscription first
    _ledStatusSubscription?.cancel();

    // Check if RGB LED is enabled before initializing LED manager
    final rgbLedEnabled = await AppPreferences().getBool('rgb_led_enabled');

    if (!rgbLedEnabled) {
      dPrint('SensorScreen: RGB LED is disabled, not initializing LED manager');
      return;
    }

    try {
      dPrint('SensorScreen: Initializing LED manager');
      // Listen to LED status changes for debugging/logging
      _ledStatusSubscription = LEDStatusManager.instance.statusStream.listen(
        (status) {
          if (mounted && !_isDisposing) {
            dPrint('SensorScreen: LED Status changed to: $status');
          }
        },
        onError: (error) {
          dPrint('SensorScreen: LED Status stream error: $error');
          if (mounted && !_isDisposing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("LED Error: $error")),
            );
          }
        },
        onDone: () {
          dPrint('SensorScreen: LED Status stream closed');
          if (mounted && !_isDisposing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("LED Stream Done")),
            );
          }
        },
      );
      dPrint('SensorScreen: LED manager initialized successfully');
    } catch (e, t) {
      dPrint('SensorScreen: Failed to initialize LED Manager stream: $e');
      dPrint('SensorScreen: Stack trace: $t');
      if (mounted && !_isDisposing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("LED Init Error: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    dPrint("SensorScreen: Starting dispose");
    _isDisposing = true;

    // Cancel timer first
    _sensorTimer?.cancel();
    _sensorTimer = null;

    // Cancel subscriptions
    _ledStatusSubscription?.cancel();
    _ledStatusSubscription = null;
    _suSensorSubscription?.cancel();
    _suSensorSubscription = null;

    // Stop sensors properly
    _stopSU();
    _stopSI();

    // Reset state
    _sensorsRunning = false;
    _isInitialized = false;

    dPrint("SensorScreen: Dispose completed");
    // Don't dispose the singleton LEDStatusManager as it's shared across the app
    // LEDStatusManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final nextDay = DateTime(2025, 9, 25);
    // final nowDay = DateTime.now();
    int status = getStatusValue();

    return ConnectivityWidget(
      showSnackbar: true, // Show snackbar notifications
      showDialog: false, // Show dialog popups
      snackbarDuration: Duration(seconds: 3),
      connectedMessage: 'Connected!',
      disconnectedMessage: 'No internet',
      connectedColor: Colors.green,
      disconnectedColor: Colors.red,
      child: Scaffold(
        body: Stack(
          children: [
            buildScreen(status),
            // if (nowDay.isBefore(nextDay))
            //   PositionedDirectional(
            //       end: 10,
            //       top: 40,
            //       child: Column(
            //         children: [
            //           SizedBox(height: 12),
            //           _buildLEDControlSection(),
            //         ],
            //       )),
          ],
        ),
      ),
    );
  }

  Widget buildScreen(status) {
    return widget.child;
  }

  int getStatusValue() {
    print("sensor value $sensorValue, threshold: $sensorThreshold");
    if (sensorValue == 0) {
      return 0;
    } else if (sensorValue < sensorThreshold) {
      return 3;
    } else if (sensorValue > sensorThreshold) {
      return 2;
    } else if (_suPort == null) {
      return 2;
    } else {
      return 2;
    }
  }

  Future<void> _loadSensorThreshold() async {
    sensorThreshold = await AppPreferences().getSensorThreshold();
    dPrint("Sensor threshold loaded: $sensorThreshold");
  }

  Future<void> updateSensorThreshold(int newThreshold) async {
    setState(() {
      sensorThreshold = newThreshold;
    });
    await AppPreferences().setSensorThreshold(newThreshold);
    dPrint("Sensor threshold updated to: $newThreshold");
  }

  Widget buildSensorMonitor() {
    return Center(
        child: Container(
      height: 30.h,
      width: 60.w,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        children: [
          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Port Information Section
                Container(
                  padding: EdgeInsets.only(top: 5.h),
                  height: 15.h,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'USB Port Info',
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tap ✕ to dismiss forever',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 8,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Available: ${availablePorts.length} ports',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      if (availablePorts.isNotEmpty)
                        Text(
                          'Ports: ${availablePorts.join(", ")}',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _suPort != null ? Icons.usb : Icons.usb_off,
                            color: _suPort != null ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Selected: ${_suPort ?? "None"}',
                            style: TextStyle(
                              color:
                                  _suPort != null ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // LED Control Section
                _buildLEDControlSection(),

                SizedBox(height: 12),

                // Sensor Data Section
                _buildSensorDataDisplay(),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildLEDControlSection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'LED Status Control',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            LEDStatusManager.instance.getStatusDescription(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElevatedButton(
          //       onPressed: () =>
          //           LEDStatusManager.instance.setManualLEDColor(LEDColor.red),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.red,
          //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       ),
          //       child: Text('Red',
          //           style: TextStyle(fontSize: 10, color: Colors.white)),
          //     ),
          //     ElevatedButton(
          //       onPressed: () =>
          //           LEDStatusManager.instance.setManualLEDColor(LEDColor.green),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.green,
          //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       ),
          //       child: Text('Green',
          //           style: TextStyle(fontSize: 10, color: Colors.white)),
          //     ),
          //     ElevatedButton(
          //       onPressed: () => LEDStatusManager.instance
          //           .setManualLEDColor(LEDColor.orange),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.orange,
          //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       ),
          //       child: Text('Orange',
          //           style: TextStyle(fontSize: 10, color: Colors.white)),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 4),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElevatedButton(
          //       onPressed: onNavigateToNextScreen,
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.blue,
          //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       ),
          //       child: Text('Next Screen',
          //           style: TextStyle(fontSize: 10, color: Colors.white)),
          //     ),
          //     ElevatedButton(
          //       onPressed: onReturnToScreen,
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.purple,
          //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       ),
          //       child: Text('Return',
          //           style: TextStyle(fontSize: 10, color: Colors.white)),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSensorDataDisplay() {
    // Determine status color and text based on local sensorStatus variable
    Color statusColor = Colors.grey;
    String statusText = 'UNKNOWN';

    switch (sensorStatus) {
      case SensorStatus.CLOSE:
        statusColor = Colors.red;
        statusText = 'CLOSE';
        break;
      case SensorStatus.FAR:
        statusColor = Colors.green;
        statusText = 'FAR';
        break;
      case SensorStatus.UNKNOWN:
        statusColor = Colors.orange;
        statusText = 'UNKNOWN';
        break;
    }

    return Column(
      children: [
        Text(
          'Sensor Data',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Value: ',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 16,
              ),
            ),
            Text(
              '$sensorValue', // Using local sensorValue variable
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        // Threshold Control Section
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Column(
            children: [
              Text(
                'Threshold: $sensorThreshold',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => updateSensorThreshold(sensorThreshold - 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(30, 25),
                    ),
                    child: Text('-',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => updateSensorThreshold(sensorThreshold + 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(30, 25),
                    ),
                    child: Text('+',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
