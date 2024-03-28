import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rehab Centers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RehabCentersPage(),
    );
  }
}

class RehabCentersPage extends StatefulWidget {
  @override
  _RehabCentersPageState createState() => _RehabCentersPageState();
}

class _RehabCentersPageState extends State<RehabCentersPage> {
  Position? _currentPosition;
  bool _locationServiceEnabled = false;
  LocationPermission _locationPermissionStatus = LocationPermission.denied;
  List<Map<String, dynamic>> nearestRehabCenters = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    _locationPermissionStatus = await Geolocator.checkPermission();
    if (_locationServiceEnabled && _locationPermissionStatus == LocationPermission.always) {
      await _getCurrentLocation();
    } else {
      await _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    if (_locationPermissionStatus != LocationPermission.always) {
      _locationPermissionStatus = await Geolocator.requestPermission();
      if (_locationPermissionStatus == LocationPermission.always) {
        await _getCurrentLocation();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _calculateNearestRehabCenters();
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _calculateNearestRehabCenters() {
    if (_currentPosition != null) {
      nearestRehabCenters = rehabCenters
          .where((center) =>
      Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        center['latitude'] as double,
        center['longitude'] as double,
      ) <= 100000) // 100 km in meters
          .map((center) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          center['latitude'] as double,
          center['longitude'] as double,
        );
        return {
          'name': center['name'],
          'address': center['address'],
          'phone': center['phone'],
          'distance': distance,
        };
      }).toList();
      nearestRehabCenters.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    }
  }

  final List<Map<String, dynamic>> rehabCenters = [
    {
      'name': 'Recovery House',
      'address': '123 Main St, City, State',
      'phone': '123-456-7890',
      'latitude': 40.7128,
      'longitude': -74.0060,
    },
    {
      'name': 'Hope Haven',
      'address': '456 Elm St, City, State',
      'phone': '456-789-0123',
      'latitude': 41.8781,
      'longitude': -87.6298,
    },
    // Add more rehab centers as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Rehab Centers'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: nearestRehabCenters.length,
        itemBuilder: (context, index) {
          final center = nearestRehabCenters[index];
          return ListTile(
            title: Text(center['name'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(center['address'] as String),
                Text(center['phone'] as String),
                Text('Distance: ${(center['distance'] as double).round()} meters'),
              ],
            ),
            onTap: () {
              // Add action when tapping on a rehab center
              // For example, open details page or call the center
            },
          );
        },
      ),
    );
  }
}
