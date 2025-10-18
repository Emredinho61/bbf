import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bbf_app/screens/nav_pages/qiblah/location_error_widget.dart';
import 'package:bbf_app/screens/nav_pages/qiblah/loading_indicator.dart';

class QiblahCompass extends StatefulWidget {
  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController = StreamController<LocationStatus>.broadcast();

  bool? _cachedEnabled;
  LocationPermission? _cachedPermission;
  Map<String, double>? _cachedQiblahData;
  bool _hasCachedData = false;

  Stream<LocationStatus> get stream => _locationStreamController.stream;

  @override
  void initState() {
    super.initState();
    _loadAllCachedData();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _loadAllCachedData() async {
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool('location_enabled');
    final statusIndex = prefs.getInt('location_permission_status');

    final cachedDirection = prefs.getDouble('cached_direction');
    final cachedQiblah = prefs.getDouble('cached_qiblah');
    final cachedOffset = prefs.getDouble('cached_offset');

    if (cachedDirection != null && cachedQiblah != null) {
      _cachedQiblahData = {
        'direction': cachedDirection,
        'qiblah': cachedQiblah,
        'offset': cachedOffset ?? 0.0,
      };
      _hasCachedData = true;
    }

    setState(() {
      _cachedEnabled = enabled;
      _cachedPermission = statusIndex != null ? LocationPermission.values[statusIndex] : null;
    });

    _checkLocationStatus();
  }

  Future<void> _saveCachedStatus(LocationStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_enabled', status.enabled);
    await prefs.setInt('location_permission_status', status.status.index);
  }

  Future<void> _saveQiblahData(Map<String, double> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cached_direction', data['direction']!);
    await prefs.setDouble('cached_qiblah', data['qiblah']!);
    await prefs.setDouble('cached_offset', data['offset']!);
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    await _saveCachedStatus(locationStatus);

    if (locationStatus.enabled && locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      await _saveCachedStatus(s);
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<LocationStatus>(
        stream: stream,
        builder: (context, snapshot) {
          final status = snapshot.data;
          final enabled = status?.enabled ?? _cachedEnabled ?? false;
          final permission = status?.status ?? _cachedPermission;

          if (status == null && _cachedPermission == null && !_hasCachedData) {
            return LoadingIndicator();
          }

          if (enabled) {
            switch (permission) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Qiblah – Kompass",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: CachedQiblahCompassWidget(
                        cachedData: _cachedQiblahData,
                        onDirectionUpdate: _saveQiblahData,
                      ),
                    ),
                  ],
                );

              case LocationPermission.denied:
                return LocationErrorWidget(
                  error: "Location service permission denied",
                  callback: _checkLocationStatus,
                );
              case LocationPermission.deniedForever:
                return LocationErrorWidget(
                  error: "Location service Denied Forever!",
                  callback: _checkLocationStatus,
                );
              default:
                return const SizedBox();
            }
          } else {
            return LocationErrorWidget(
              error: "Bitte aktivieren Sie den Standortdienst",
              callback: _checkLocationStatus,
            );
          }
        },
      ),
    );
  }
}

class CachedQiblahCompassWidget extends StatefulWidget {
  final Map<String, double>? cachedData;
  final Function(Map<String, double>) onDirectionUpdate;

  const CachedQiblahCompassWidget({
    super.key,
    this.cachedData,
    required this.onDirectionUpdate,
  });

  @override
  State<CachedQiblahCompassWidget> createState() => _CachedQiblahCompassWidgetState();
}

class _CachedQiblahCompassWidgetState extends State<CachedQiblahCompassWidget> {
  final _compassSvg = SvgPicture.asset('assets/images/qiblah_compass/compass.svg');
  final _needleSvg = SvgPicture.asset(
    'assets/images/qiblah_compass/needle.svg',
    width: 300,
    height: 300,
  );
  Map<String, double>? _currentData;
  bool _usingCachedData = false;
  bool _shouldUpdateState = false;

  @override
  void initState() {
    super.initState();
    if (widget.cachedData != null) {
      _currentData = Map<String, double>.from(widget.cachedData!);
      _usingCachedData = true;
    }
  }

  void _updateData(Map<String, double> newData) {
    widget.onDirectionUpdate(newData);

    if (_usingCachedData) {
      _shouldUpdateState = true;
      _currentData = newData;
      _usingCachedData = false;

      Future.microtask(() {
        if (mounted && _shouldUpdateState) {
          setState(() {
            _shouldUpdateState = false;
          });
        }
      });
    } else {
      _currentData = newData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
          final qiblahDirection = snapshot.data!;

          double direction;
          double qiblah;
          double offset;

          try {
            direction = qiblahDirection.direction;
            qiblah = qiblahDirection.qiblah;
            offset = qiblahDirection.offset;
          } catch (e) {
            direction = 0.0;
            qiblah = 0.0;
            offset = 0.0;
          }

          final newData = {
            'direction': direction,
            'qiblah': qiblah,
            'offset': offset,
          };

          _updateData(newData);
        }

        final displayData = _currentData ?? widget.cachedData;

        if (displayData == null) {
          return LoadingIndicator();
        }

        final direction = displayData['direction'] ?? 0.0;
        final qiblah = displayData['qiblah'] ?? 0.0;
        final offset = displayData['offset'] ?? 0.0;

        Widget cacheIndicator = const SizedBox.shrink();
        if (_usingCachedData && snapshot.connectionState != ConnectionState.waiting) {
          cacheIndicator = Positioned(
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "Gecachte Daten - Aktualisiere...",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.rotate(
              angle: (direction * (pi / 180) * -1),
              child: _compassSvg,
            ),
            Transform.rotate(
              angle: (qiblah * (pi / 180) * -1),
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(3, -5),
                child: _needleSvg,
              ),
            ),
            cacheIndicator,
            Positioned(
              bottom: 8,
              child: Text(
                "${offset.toStringAsFixed(2)}°",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}