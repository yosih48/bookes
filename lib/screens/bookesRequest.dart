import 'dart:io';

import 'package:bookes/models/BookRequest.dart';
import 'package:bookes/resources/BookRequest.dart';
import 'package:bookes/resources/StorageService.dart';
import 'package:bookes/widgets/ImagePicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
class BookRequestScreen extends StatefulWidget {
  @override
  _BookRequestScreenState createState() => _BookRequestScreenState();
}

class _BookRequestScreenState extends State<BookRequestScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _conditionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedLocation = '';
  Position? _currentPosition;
  bool _isLoading = false;
  File? _selectedImage;
  final _storageService = StorageService();

  
  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }



  void _submitRequest() async {
  
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {

     String? imageUrl;
          if (_selectedImage != null) {
          imageUrl = await StorageService().uploadImage(
            imageFile: _selectedImage!,
            path: 'book_images', // Folder in Firebase Storage
          );
        }

        // Create book request object
        final bookRequest = BookRequest(
        
          userId: userId, // Assuming you have this from auth
          title: _titleController.text,
          author: _authorController.text,
          condition: _conditionController.text,
          location: _selectedLocation,
           imageUrl: imageUrl, 
          coordinates: _currentPosition != null
              ? GeoPoint(
                  _currentPosition!.latitude, _currentPosition!.longitude)
              : const GeoPoint(0, 0),
          createdAt: DateTime.now(),
          status: 'Active'
        );

        // Save to Firestore
         final createdRequest=  BookRequestService().createBookRequest(bookRequest);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _clearForm();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _authorController.clear();
    _conditionController.clear();
    _locationController.clear();
    setState(() {
      _selectedLocation = '';
      _currentPosition = null;
       _selectedImage = null;
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Location services are disabled. Please enable them.')),
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
    print('_getCurrentLocation');
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;

    try {
      print('hasPermission');
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
          print('_currentPosition: ${_currentPosition}');
          // Only store city and neighborhood for privacy
          _selectedLocation =
              '${place.locality ?? ''}, ${place.subLocality ?? ''}';
          _locationController.text = _selectedLocation;
          print('_selectedLocation: ${_selectedLocation}');
          print('_locationController.text: ${_locationController.text}');
        });
      } else {
        print('placemarks is emptey');
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
              // buildLocationField(),
              InkWell(
                onTap: _selectLocation,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _locationController,
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
                SizedBox(height: 16.0),
     ImagePickerWidget(
            selectedImage: _selectedImage,
            onImageSelected: (File? file) {
              setState(() {
                _selectedImage = file;
              });
            },
            placeholder: 'Tap to add book image', // Optional custom placeholder
            height: 200, // Optional custom height
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

  // Widget buildLocationField() {
  //   return InkWell(
  //     onTap: _selectLocation,
  //     child: AbsorbPointer(
  //       child: TextFormField(
  //         initialValue: _locationController,
  //         decoration: InputDecoration(
  //           labelText: 'General Location',
  //           prefixIcon: Icon(LucideIcons.mapPin),
  //           suffixIcon: IconButton(
  //             icon: Icon(LucideIcons.locate),
  //             onPressed: _getCurrentLocation,
  //           ),
  //         ),
  //         validator: (value) {
  //           if (value?.isEmpty ?? true) {
  //             return 'Please select a location';
  //           }
  //           return null;
  //         },
  //       ),
  //     ),
  //   );
}
