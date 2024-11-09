import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BookRequestScreen extends StatefulWidget {
  @override
  _BookRequestScreenState createState() => _BookRequestScreenState();
}

class _BookRequestScreenState extends State<BookRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _conditionController = TextEditingController();
  String _selectedLocation = '';
  Position? _currentPosition;

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission, e.g., save the request to a database
      print('Book Request Submitted:');
      print('Title: ${_titleController.text}');
      print('Author: ${_authorController.text}');
      print('Condition: ${_conditionController.text}');
        print('Location: $_selectedLocation');

      // Clear the form fields
      _titleController.clear();
      _authorController.clear();
      _conditionController.clear();
          setState(() {
        _selectedLocation = '';
      });
    }
  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentPosition = position;
          // Only store city and neighborhood for privacy
          _selectedLocation = '${place.locality ?? ''}, ${place.subLocality ?? ''}';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _selectLocation() async {
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request a Book'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title',
                  prefixIcon: Icon(LucideIcons.book),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the book title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the author';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _conditionController,
                decoration: InputDecoration(
                  labelText: 'Book Condition',
                  prefixIcon: Icon(LucideIcons.book),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the book condition';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              InkWell(
      onTap: _selectLocation,
      child: AbsorbPointer(
        child: TextFormField(
          initialValue: _selectedLocation,
          decoration: InputDecoration(
            labelText: 'General Location',
            prefixIcon: Icon(LucideIcons.mapPin),
            suffixIcon: IconButton(
              icon: Icon(LucideIcons.locate),
              onPressed: _getCurrentLocation,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please select a location';
            }
            return null;
          },
        ),
      ),
    ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _submitRequest,
                child: Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
