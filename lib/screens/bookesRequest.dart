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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        title: Text(
          AppLocalizations.of(context)!.requestabook,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.booktitle,
                            prefixIcon: const Icon(LucideIcons.book),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppLocalizations.of(context)!
                                  .pleaseenterbooktitle;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _authorController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.author,
                            prefixIcon: const Icon(LucideIcons.user),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppLocalizations
                                  .of(context)!
                                  .pleaseentertheauthor;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.bookdetails,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _conditionController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.bookcondition,
                            prefixIcon: const Icon(LucideIcons.book),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppLocalizations.of(context)!
                                  .bookcondition;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        InkWell(
                          onTap: _selectLocation,
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .generallocation,
                                prefixIcon: const Icon(LucideIcons.mapPin),
                                suffixIcon: IconButton(
                                  icon: const Icon(LucideIcons.locate),
                                  onPressed: _getCurrentLocation,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!
                                      .pleaseselectalocation;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ImagePickerWidget(
                      selectedImage: _selectedImage,
                      onImageSelected: (File? file) {
                        setState(() {
                          _selectedImage = file;
                        });
                      },
                      placeholder: AppLocalizations.of(context)!.taptoaddbookimage,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                   AppLocalizations.of(context)!.submitrequest,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
