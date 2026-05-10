import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_page_with_action_buttons.dart';
import 'package:kiosk_point_of_sale/core/components/widgets/custom_snackbar_widget.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_dialogs.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/core/services/kiosk_mode_services/kiosk_management_service.dart';
import 'package:kiosk_point_of_sale/data/models/kds_device_model.dart';
import 'package:kiosk_point_of_sale/data/models/sync_product/sync_product_model.dart';
import 'package:kiosk_point_of_sale/repository/menu_item_sync_repository.dart';
import 'package:kiosk_point_of_sale/core/sdks/sdk_logic/usb_plugin.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Home/home_widget.dart';
import 'package:kiosk_point_of_sale/features/shared-features/settings/widgets/nfc_test_dialog.dart';
import 'package:kiosk_point_of_sale/features/shared-features/settings/widgets/printer_test_dialog.dart';
import 'package:kiosk_point_of_sale/features/shared-features/settings/widgets/control_switch_widget.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static String routeName = 'Settings';
  static String routePath = '/settings';
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final KioskManagementService _kioskService = KioskManagementService();
  Future<void> showQuantityTypeDialog() async {
    String selectedType = await AppPreferences().getQuantityType();

    return showAppDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(translator(
            arText: 'نوع الكمية',
            enText: 'Quantity Type',
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translator(
                arText: 'اختر نوع الكمية',
                enText: 'Choose quantity type',
              )),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'int',
                    child: Text(translator(
                      arText: 'عدد صحيح',
                      enText: 'Integer',
                    )),
                  ),
                  DropdownMenuItem(
                    value: 'Decimal',
                    child: Text(translator(
                      arText: 'عشري',
                      enText: 'Decimal',
                    )),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value ?? 'int';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translator(
                arText: 'إلغاء',
                enText: 'Cancel',
              )),
            ),
            ElevatedButton(
              onPressed: () async {
                await AppPreferences().setQuantityType(selectedType);
                if (mounted) {
                  Navigator.pop(context);
                  customSnackbar(
                    context,
                    translator(
                      arText: 'تم حفظ نوع الكمية بنجاح',
                      enText: 'Quantity type saved successfully',
                    ),
                    true,
                  );
                }
              },
              child: Text(translator(
                arText: 'حفظ',
                enText: 'Save',
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageWithActionButtons(
      buttons: [
        // ButtonSettings(
        //   onTap: () => _showPrinterSettingsDialog(),
        //   title: translator(
        //     arText: 'إعدادات الطابعة',
        //     enText: 'Printer Settings',
        //   ),
        //   icon: Icons.print,
        // ),
        ButtonSettings(
          onTap: () => showQuantityTypeDialog(),
          title: translator(
            arText: 'نوع الكمية',
            enText: 'Quantity Type',
          ),
          icon: Icons.straighten,
        ),
        ButtonSettings(
          onTap: () => _showKdsSettingsDialog(),
          title: translator(
            arText: 'إعدادات KDS',
            enText: 'KDS Settings',
          ),
          icon: Icons.restaurant,
        ),
        ButtonSettings(
          onTap: () => _showKioskControlDialog(),
          title: translator(
            arText: 'التحكم في الكيوسك',
            enText: 'Kiosk Control',
          ),
          icon: Icons.control_camera,
        ),
        ButtonSettings(
          onTap: () => _showHardwareSettingsDialog(),
          title: translator(
            arText: 'إعدادات الأجهزة',
            enText: 'Hardware Settings',
          ),
          icon: Icons.hardware,
        ),
        ButtonSettings(
          onTap: () => _showTimeoutSettingsDialog(),
          title: translator(
            arText: 'إعدادات المهلة الزمنية',
            enText: 'Timeout Settings',
          ),
          icon: Icons.timer,
        ),
      ],
      actions: [
        IconButton(
          icon: Icon(
            Icons.language,
            size: ResponsiveHelper.getResponsiveSize(context, 24),
          ),
          onPressed: () async {
            await switchAppLanguage(ref, context);
          },
        ),
      ],
      onPressedLeading: () {
        context.go(HomeWidget.routePath);
      },
      pageTitle: 'settings',
    );
  }

  Future<void> _showPrinterSettingsDialog() async {
    final TextEditingController ipController = TextEditingController(
      text: await AppPreferences().getPrinterIp(),
    );

    String selectedMode = await AppPreferences().getPrinterMode();

    return showAppDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(translator(
            arText: 'إعدادات الطابعة',
            enText: 'Printer Settings',
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Printer Mode Selection
              Text(translator(
                arText: 'وضع الطابعة',
                enText: 'Printer Mode',
              )),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedMode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'bluetooth',
                    child: Text(translator(
                      arText: 'بلوتوث',
                      enText: 'Bluetooth',
                    )),
                  ),
                  DropdownMenuItem(
                    value: 'network',
                    child: Text(translator(
                      arText: 'شبكة',
                      enText: 'Network',
                    )),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMode = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // IP Settings (only show for network mode)
              if (selectedMode == 'network') ...[
                Text(translator(
                  arText: 'عنوان IP للطابعة',
                  enText: 'Printer IP Address',
                )),
                const SizedBox(height: 8),
                TextField(
                  controller: ipController,
                  decoration: InputDecoration(
                    hintText: '192.168.1.100',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translator(
                arText: 'إلغاء',
                enText: 'Cancel',
              )),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save printer mode
                await AppPreferences().setPrinterMode(selectedMode);

                // Save IP address only if network mode is selected
                if (selectedMode == 'network') {
                  await AppPreferences().setPrinterIp(ipController.text.trim());
                }

                if (mounted) {
                  Navigator.pop(context);
                  customSnackbar(
                    context,
                    translator(
                      arText: 'تم حفظ إعدادات الطابعة بنجاح',
                      enText: 'Printer settings saved successfully',
                    ),
                    true,
                  );
                }
              },
              child: Text(translator(
                arText: 'حفظ',
                enText: 'Save',
              )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showKdsSettingsDialog() async {
    return showAppDialog(
      context: context,
      builder: (context) => KdsSettingsDialog(),
    );
  }

  Future<void> _showKioskControlDialog() async {
    return showAppDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translator(
          arText: 'التحكم في وضع الكيوسك',
          enText: 'Kiosk Mode Control',
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current Status
            FutureBuilder<KioskMode?>(
              future: getKioskMode(),
              builder: (context, snapshot) {
                final mode = snapshot.data;
                final statusText = mode == null
                    ? translator(
                        arText: 'لا يمكن تحديد الوضع',
                        enText: 'Can\'t determine the mode',
                      )
                    : translator(
                        arText: 'الوضع الحالي: ${mode == KioskMode.enabled ? "مفعل" : "معطل"}',
                        enText:
                            'Current mode: ${mode == KioskMode.enabled ? "Enabled" : "Disabled"}',
                      );

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mode == KioskMode.enabled ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final didStart = await _kioskService.startKiosk();
                    _kioskService.handleKioskStart(didStart, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(translator(
                    arText: 'تفعيل',
                    enText: 'Enable',
                  )),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final didStop = await _kioskService.stopKiosk();
                    _kioskService.handleKioskStop(didStop, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(translator(
                    arText: 'إيقاف',
                    enText: 'Disable',
                  )),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            // // Check Managed Status
            // ElevatedButton(
            //   onPressed: () async {
            //     final isManaged = await _kioskService.isKioskManaged();
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(
            //         content: Text(translator(
            //           arText: 'الكيوسك ${isManaged ? "مدار" : "غير مدار"}',
            //           enText:
            //               'Kiosk is ${isManaged ? "managed" : "not managed"}',
            //         )),
            //       ),
            //     );
            //   },
            //   child: Text(translator(
            //     arText: 'فحص حالة الإدارة',
            //     enText: 'Check Management Status',
            //   )),
            // ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translator(
              arText: 'إغلاق',
              enText: 'Close',
            )),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimeoutSettingsDialog() async {
    return showAppDialog(
      context: context,
      builder: (context) => TimeoutSettingsDialog(),
    );
  }

  Future<void> _showHardwareSettingsDialog() async {
    return showAppDialog(
      context: context,
      builder: (context) => HardwareSettingsDialog(),
    );
  }

  Future<void> _requestMotionSensorPermissions() async {
    try {
      dPrint('Requesting motion sensor permissions...');
      // Add motion sensor permission logic here
      // This would typically involve requesting camera or sensor permissions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Motion sensor permissions granted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      dPrint('Failed to request motion sensor permissions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to grant motion sensor permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _requestRgbPermissions() async {
    try {
      dPrint('Requesting RGB LED permissions...');
      // Add RGB LED permission logic here
      // This would typically involve requesting USB or hardware permissions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RGB LED permissions granted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      dPrint('Failed to request RGB LED permissions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to grant RGB LED permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _requestPrinterPermissions() async {
    try {
      dPrint('Requesting printer permissions...');
      // Add printer permission logic here
      // This would typically involve requesting USB or Bluetooth permissions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer permissions granted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      dPrint('Failed to request printer permissions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to grant printer permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testPrinter() async {
    try {
      dPrint('Opening printer test dialog...');
      await showAppDialog(
        context: context,
        builder: (context) => const PrinterTestDialog(),
      );
    } catch (e) {
      dPrint('Failed to open printer test dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open printer test: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class HardwareSettingsDialog extends StatefulWidget {
  const HardwareSettingsDialog({super.key});

  @override
  _HardwareSettingsDialogState createState() => _HardwareSettingsDialogState();
}

class _HardwareSettingsDialogState extends State<HardwareSettingsDialog> {
  bool isMotionSensorEnabled = false;
  bool isRgbLedEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translator(
                    arText: 'إعدادات الأجهزة',
                    enText: 'Hardware Settings',
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Control Switches
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Motion Sensor Switch
                    ControlSwitchWidget(
                      title: 'Motion Sensor',
                      subtitle: 'Enable motion detection',
                      icon: Icons.sensors,
                      preferenceKey: 'motion_sensor_enabled',
                      onToggle: (enabled) async {
                        setState(() {
                          isMotionSensorEnabled = enabled;
                        });
                        if (enabled) {
                          await _requestMotionSensorPermissions();
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                    if (isMotionSensorEnabled) ...[
                      SensorThresholdControlWidget(),
                    ],
                    // RGB LED Switch
                    ControlSwitchWidget(
                      title: 'RGB LED',
                      subtitle: 'Enable LED control',
                      icon: Icons.lightbulb,
                      preferenceKey: 'rgb_led_enabled',
                      onToggle: (enabled) async {
                        setState(() {
                          isRgbLedEnabled = enabled;
                        });
                        if (enabled) {
                          await _requestRgbPermissions();
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Printer Switch
                    ControlSwitchWidget(
                      title: 'Printer',
                      subtitle: 'Enable thermal printer',
                      icon: Icons.print,
                      preferenceKey: 'printer_enabled',
                      onToggle: (enabled) async {
                        if (enabled) {
                          await _requestPrinterPermissions();
                          await _testPrinter();
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // NFC Switch
                    ControlSwitchWidget(
                      title: 'NFC Payment',
                      subtitle: 'Enable NearPay',
                      icon: Icons.nfc,
                      preferenceKey: 'nfc_enabled',
                      onToggle: (enabled) async {
                        if (enabled) {
                          await _testNfcPayment();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestMotionSensorPermissions() async {
    try {
      dPrint('Requesting motion sensor permissions...');
      await UsbPlugin.initialize();
      final suPorts = await UsbPlugin.getPorts(DeviceType.SU);
      if (suPorts.isNotEmpty) {
        await UsbPlugin.requestPermission(suPorts.first);
      }
      // Add motion sensor permission logic here
      // This would typically involve requesting camera or sensor permissions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Motion sensor permissions granted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      dPrint('Failed to request motion sensor permissions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to grant motion sensor permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _requestRgbPermissions() async {
    try {
      dPrint('Requesting RGB LED permissions...');
      await UsbPlugin.initialize();
      final siPorts = await UsbPlugin.getPorts(DeviceType.SI);
      if (siPorts.isNotEmpty) {
        await UsbPlugin.requestPermission(siPorts.first);
      }
      // Add RGB LED permission logic here
      // This would typically involve requesting USB or hardware permissions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RGB LED permissions granted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      dPrint('Failed to request RGB LED permissions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to grant RGB LED permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _requestPrinterPermissions() async {
    try {
      dPrint('Requesting printer permissions...');
      // Add printer permission logic here
      // This would typically involve requesting USB or Bluetooth permissions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer permissions granted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      dPrint('Failed to request printer permissions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to grant printer permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testPrinter() async {
    try {
      dPrint('Opening printer test dialog...');
      await showAppDialog(
        context: context,
        builder: (context) => const PrinterTestDialog(),
      );
    } catch (e) {
      dPrint('Failed to open printer test dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open printer test: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testNfcPayment() async {
    try {
      dPrint('Opening NFC test dialog...');
      await showAppDialog(
        context: context,
        builder: (context) => const NfcTestDialog(),
      );
    } catch (e) {
      dPrint('Failed to open NFC test dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open NFC test: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class KdsSettingsDialog extends StatefulWidget {
  const KdsSettingsDialog({super.key});

  @override
  _KdsSettingsDialogState createState() => _KdsSettingsDialogState();
}

class _KdsSettingsDialogState extends State<KdsSettingsDialog> {
  List<KdsDevice> _kdsDevices = [];
  List<SyncCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load KDS devices
      final devices = await AppPreferences().getKdsDevices();
      final categories = await MenuItemSyncRepository().getAllCategories();
      dPrint(categories.length.toString());
      dPrint(devices.length.toString());
      setState(() {
        _kdsDevices = devices;
        _categories = categories.toSet().toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading KDS data: $e');
    }
  }

  Future<void> _addNewDevice() async {
    final result = await showAppDialog<KdsDevice>(
      context: context,
      builder: (context) => _AddEditKdsDeviceDialog(
        categories: _categories,
      ),
    );

    if (result != null) {
      setState(() {
        _kdsDevices.add(result);
      });
      await AppPreferences().setKdsDevices(_kdsDevices);
      customSnackbar(
        context,
        translator(
          arText: 'تم إضافة جهاز KDS بنجاح',
          enText: 'KDS device added successfully',
        ),
        true,
      );
    }
  }

  Future<void> _editDevice(KdsDevice device) async {
    final result = await showAppDialog<KdsDevice>(
      context: context,
      builder: (context) => _AddEditKdsDeviceDialog(
        categories: _categories,
        existingDevice: device,
      ),
    );

    if (result != null) {
      setState(() {
        final index = _kdsDevices.indexWhere((d) => d.id == device.id);
        if (index != -1) {
          _kdsDevices[index] = result;
        }
      });
      await AppPreferences().setKdsDevices(_kdsDevices);
      customSnackbar(
        context,
        translator(
          arText: 'تم تحديث جهاز KDS بنجاح',
          enText: 'KDS device updated successfully',
        ),
        true,
      );
    }
  }

  Future<void> _deleteDevice(KdsDevice device) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translator(
          arText: 'تأكيد الحذف',
          enText: 'Confirm Delete',
        )),
        content: Text(translator(
          arText: 'هل أنت متأكد من حذف جهاز "${device.name}"؟',
          enText: 'Are you sure you want to delete device "${device.name}"?',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translator(
              arText: 'إلغاء',
              enText: 'Cancel',
            )),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(translator(
              arText: 'حذف',
              enText: 'Delete',
            )),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _kdsDevices.removeWhere((d) => d.id == device.id);
      });
      await AppPreferences().setKdsDevices(_kdsDevices);
      customSnackbar(
        context,
        translator(
          arText: 'تم حذف جهاز KDS بنجاح',
          enText: 'KDS device deleted successfully',
        ),
        true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translator(
                    arText: 'إعدادات أجهزة KDS',
                    enText: 'KDS Devices Settings',
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add Device Button
            ElevatedButton.icon(
              onPressed: _addNewDevice,
              icon: const Icon(Icons.add),
              label: Text(translator(
                arText: 'إضافة جهاز جديد',
                enText: 'Add New Device',
              )),
            ),
            const SizedBox(height: 16),

            // Devices List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _kdsDevices.isEmpty
                      ? Center(
                          child: Text(
                            translator(
                              arText: 'لا توجد أجهزة KDS',
                              enText: 'No KDS devices found',
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _kdsDevices.length,
                          itemBuilder: (context, index) {
                            final device = _kdsDevices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.restaurant),
                                title: Text(device.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('IP: ${device.ip}'),
                                    Text(
                                      translator(
                                        arText:
                                            'الفئات المحددة: ${device.selectedCategories.length}',
                                        enText:
                                            'Selected Categories: ${device.selectedCategories.length}',
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _editDevice(device),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteDevice(device),
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEditKdsDeviceDialog extends StatefulWidget {
  final List<SyncCategory> categories;
  final KdsDevice? existingDevice;

  const _AddEditKdsDeviceDialog({
    required this.categories,
    this.existingDevice,
  });

  @override
  _AddEditKdsDeviceDialogState createState() => _AddEditKdsDeviceDialogState();
}

class _AddEditKdsDeviceDialogState extends State<_AddEditKdsDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ipController;
  Set<String> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingDevice?.name ?? '');
    _ipController = TextEditingController(text: widget.existingDevice?.ip ?? '');
    _selectedCategories = Set.from(widget.existingDevice?.selectedCategories ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }

  void _selectAllCategories() {
    setState(() {
      _selectedCategories = Set.from(widget.categories.map((c) => c.id.toString()));
    });
  }

  void _clearAllCategories() {
    setState(() {
      _selectedCategories.clear();
    });
  }

  String? _validateDeviceName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return translator(
        arText: 'يرجى إدخال اسم الجهاز',
        enText: 'Please enter device name',
      );
    }
    return null;
  }

  String? _validateIpAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return translator(
        arText: 'يرجى إدخال عنوان IP',
        enText: 'Please enter IP address',
      );
    }

    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(value.trim())) {
      return translator(
        arText: 'يرجى إدخال عنوان IP صحيح (مثال: 192.168.1.100)',
        enText: 'Please enter a valid IP address (e.g., 192.168.1.100)',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                translator(
                  arText: widget.existingDevice == null ? 'إضافة جهاز KDS جديد' : 'تعديل جهاز KDS',
                  enText: widget.existingDevice == null ? 'Add New KDS Device' : 'Edit KDS Device',
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Device Name
              TextFormField(
                controller: _nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: translator(
                    arText: 'اسم الجهاز',
                    enText: 'Device Name',
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: _validateDeviceName,
              ),
              const SizedBox(height: 16),

              // IP Address
              TextFormField(
                controller: _ipController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: translator(
                    arText: 'عنوان IP',
                    enText: 'IP Address',
                  ),
                  hintText: '192.168.1.100',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: _validateIpAddress,
              ),
              const SizedBox(height: 16),

              // Categories Section
              Text(
                translator(
                  arText: 'الفئات',
                  enText: 'Categories',
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_selectedCategories.isEmpty)
                Text(
                  translator(
                    arText: 'يرجى تحديد فئة واحدة على الأقل',
                    enText: 'Please select at least one category',
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                ),
              const SizedBox(height: 4),

              // Select All / Clear All buttons
              Row(
                children: [
                  TextButton(
                    onPressed: _selectAllCategories,
                    child: Text(translator(
                      arText: 'تحديد الكل',
                      enText: 'Select All',
                    )),
                  ),
                  TextButton(
                    onPressed: _clearAllCategories,
                    child: Text(translator(
                      arText: 'إلغاء التحديد',
                      enText: 'Clear All',
                    )),
                  ),
                ],
              ),

              // Categories List
              Expanded(
                child: ListView.builder(
                  itemCount: widget.categories.length,
                  itemBuilder: (context, index) {
                    final category = widget.categories[index];
                    final isSelected = _selectedCategories.contains(category.id.toString());

                    return CheckboxListTile(
                      title: Text(
                        translator(
                          arText: category.nameAr,
                          enText: category.nameEn,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (value) => _toggleCategory(category.id.toString()),
                    );
                  },
                ),
              ),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(translator(
                      arText: 'إلغاء',
                      enText: 'Cancel',
                    )),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Validate form fields
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      // Validate at least one category is selected
                      if (_selectedCategories.isEmpty) {
                        customSnackbar(
                          context,
                          translator(
                            arText: 'يرجى تحديد فئة واحدة على الأقل',
                            enText: 'Please select at least one category',
                          ),
                          false,
                        );
                        return;
                      }

                      final device = KdsDevice(
                        id: widget.existingDevice?.id ?? const Uuid().v4(),
                        name: _nameController.text.trim(),
                        ip: _ipController.text.trim(),
                        selectedCategories: _selectedCategories.toList(),
                      );

                      Navigator.pop(context, device);
                    },
                    child: Text(translator(
                      arText: 'حفظ',
                      enText: 'Save',
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorThresholdControlWidget extends StatefulWidget {
  const SensorThresholdControlWidget({super.key});

  @override
  _SensorThresholdControlWidgetState createState() => _SensorThresholdControlWidgetState();
}

class _SensorThresholdControlWidgetState extends State<SensorThresholdControlWidget> {
  int _currentThreshold = 15;

  @override
  void initState() {
    super.initState();
    _loadThreshold();
  }

  Future<void> _loadThreshold() async {
    final threshold = await AppPreferences().getSensorThreshold();
    setState(() {
      _currentThreshold = threshold;
    });
  }

  Future<void> _updateThreshold(int newThreshold) async {
    setState(() {
      _currentThreshold = newThreshold;
    });
    await AppPreferences().setSensorThreshold(newThreshold);
    dPrint("Sensor threshold updated to: $newThreshold");

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sensor threshold updated to $newThreshold'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.tune,
                color: Colors.blue,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translator(
                        arText: 'حساسية المستشعر',
                        enText: 'Sensor Sensitivity',
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      translator(
                        arText: 'اضبط عتبة اكتشاف الحركة',
                        enText: 'Adjust motion detection threshold',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Current Value Display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translator(
                    arText: 'القيمة الحالية:',
                    enText: 'Current Value:',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  '$_currentThreshold',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Control Buttons
          Row(
            children: [
              // Decrease Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _currentThreshold > 1 ? () => _updateThreshold(_currentThreshold - 1) : null,
                  icon: Icon(Icons.remove, size: 18),
                  label: Text(
                    translator(
                      arText: 'تقليل',
                      enText: 'Decrease',
                    ),
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade700,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),

              // Increase Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _currentThreshold < 50 ? () => _updateThreshold(_currentThreshold + 1) : null,
                  icon: Icon(Icons.add, size: 18),
                  label: Text(
                    translator(
                      arText: 'زيادة',
                      enText: 'Increase',
                    ),
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade700,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Info Text
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade700,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    translator(
                      arText: 'قيم أقل = حساسية أعلى، قيم أعلى = حساسية أقل',
                      enText:
                          'Lower values = higher sensitivity, Higher values = lower sensitivity',
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeoutSettingsDialog extends StatefulWidget {
  const TimeoutSettingsDialog({super.key});

  @override
  _TimeoutSettingsDialogState createState() => _TimeoutSettingsDialogState();
}

class _TimeoutSettingsDialogState extends State<TimeoutSettingsDialog> {
  int _currentTimeout = 60;

  @override
  void initState() {
    super.initState();
    _loadTimeout();
  }

  Future<void> _loadTimeout() async {
    final timeout = await AppPreferences().getTimeoutDuration();
    setState(() {
      _currentTimeout = timeout;
    });
  }

  Future<void> _updateTimeout(int newTimeout) async {
    setState(() {
      _currentTimeout = newTimeout;
    });
    await AppPreferences().setTimeoutDuration(newTimeout);
    dPrint("Timeout duration updated to: $newTimeout seconds");

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translator(
            arText: 'تم تحديث المهلة الزمنية إلى $newTimeout ثانية',
            enText: 'Timeout duration updated to $newTimeout seconds',
          )),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translator(
                    arText: 'إعدادات المهلة الزمنية',
                    enText: 'Timeout Settings',
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      translator(
                        arText:
                            'اضبط المدة الزمنية قبل إعادة توجيه المستخدم إلى الشاشة الرئيسية عند عدم النشاط',
                        enText:
                            'Set the duration before redirecting user to home screen when inactive',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Current Value Display
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translator(
                      arText: 'المدة الحالية:',
                      enText: 'Current Duration:',
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    '$_currentTimeout ${translator(arText: 'ثانية', enText: 'seconds')}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Slider
            Text(
              translator(
                arText: 'اختر المدة الزمنية:',
                enText: 'Select Duration:',
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            Slider(
              value: _currentTimeout.toDouble(),
              min: 10,
              max: 300,
              divisions: 29, // 10-second intervals
              label: '$_currentTimeout ${translator(arText: 'ثانية', enText: 'seconds')}',
              onChanged: (value) {
                _updateTimeout(value.round());
              },
            ),

            const SizedBox(height: 20),

            // Quick Selection Buttons
            Text(
              translator(
                arText: 'اختيار سريع:',
                enText: 'Quick Selection:',
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickButton(30, translator(arText: '30 ثانية', enText: '30 sec')),
                _buildQuickButton(60, translator(arText: '1 دقيقة', enText: '1 min')),
                _buildQuickButton(120, translator(arText: '2 دقيقة', enText: '2 min')),
                _buildQuickButton(180, translator(arText: '3 دقائق', enText: '3 min')),
                _buildQuickButton(300, translator(arText: '5 دقائق', enText: '5 min')),
              ],
            ),

            const Spacer(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(translator(
                    arText: 'إغلاق',
                    enText: 'Close',
                  )),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    customSnackbar(
                      context,
                      translator(
                        arText: 'تم حفظ إعدادات المهلة الزمنية بنجاح',
                        enText: 'Timeout settings saved successfully',
                      ),
                      true,
                    );
                  },
                  child: Text(translator(
                    arText: 'حفظ',
                    enText: 'Save',
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(int seconds, String label) {
    final isSelected = _currentTimeout == seconds;
    return ElevatedButton(
      onPressed: () => _updateTimeout(seconds),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
