import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';

class ControlSwitchWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String preferenceKey;
  final Function(bool) onToggle;

  const ControlSwitchWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.preferenceKey,
    required this.onToggle,
  });

  @override
  State<ControlSwitchWidget> createState() => _ControlSwitchWidgetState();
}

class _ControlSwitchWidgetState extends State<ControlSwitchWidget> {
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final value = await AppPreferences().getBool(widget.preferenceKey);
      if (mounted) {
        setState(() {
          _isEnabled = value;
        });
      }
    } catch (e) {
      dPrint('Failed to load preference ${widget.preferenceKey}: $e');
    }
  }

  Future<void> _onSwitchChanged(bool value) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save preference
      await AppPreferences().setBool(widget.preferenceKey, value);

      // Call the toggle callback
      await widget.onToggle(value);

      if (mounted) {
        setState(() {
          _isEnabled = value;
        });
      }
    } catch (e) {
      dPrint('Failed to update preference ${widget.preferenceKey}: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update ${widget.title}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isEnabled
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isEnabled ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isEnabled ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Switch
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Switch(
              value: _isEnabled,
              onChanged: _onSwitchChanged,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            ),
        ],
      ),
    );
  }
}
