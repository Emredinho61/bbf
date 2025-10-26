import 'package:bbf_app/screens/nav_pages/qiblah/loading_indicator.dart';
import 'package:bbf_app/screens/nav_pages/qiblah/qiblah_compass.dart';
import 'package:bbf_app/screens/nav_pages/qiblah/qiblah_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompassWithQiblah extends StatefulWidget {
  const CompassWithQiblah({super.key});

  @override
  State<CompassWithQiblah> createState() => _CompassWithQiblahState();
}

class _CompassWithQiblahState extends State<CompassWithQiblah> {
  bool? _deviceSupported;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
  }

  Future<void> _checkDeviceSupport() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedSupport = prefs.getBool('device_sensor_support');

    if (cachedSupport != null) {
      setState(() {
        _deviceSupported = cachedSupport;
        _isChecking = false;
      });
    } else {
      // 🔍 Nur beim ersten Mal prüfen
      final supported = await FlutterQiblah.androidDeviceSensorSupport();
      await prefs.setBool('device_sensor_support', supported ?? false);

      setState(() {
        _deviceSupported = supported ?? false;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.green.shade900, Colors.grey.shade700]
                : [Colors.grey.shade300, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: _isChecking
              ? LoadingIndicator()
              : (_deviceSupported == true ? QiblahCompass() : QiblahMaps()),
        ),
      ),
    );
  }
}
