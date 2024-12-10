import 'dart:io';

import 'package:bookes/models/BookRequest.dart';
import 'package:bookes/models/bookOffer.dart';
import 'package:bookes/models/bookUpload.dart';
import 'package:bookes/resources/BookRequest.dart';
import 'package:bookes/resources/StorageService.dart';
import 'package:bookes/resources/bookOffer.dart';
import 'package:bookes/resources/bookUpload.dart';
import 'package:bookes/resources/locationService.dart';
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
  final TextEditingController _genreController = TextEditingController();
  String _selectedLocation = '';
  Position? _currentPosition;
  bool _isLoading = false;
  File? _selectedImage;
  final _storageService = StorageService();
  bool _isUpload = false;

  final LocationService _locationService = LocationService();
  String _location = 'Unknown';
  String? _selectedGenre;

  final List<String> _genres = [
    'Fiction',
    'Non-Fiction',
    'Science Fiction',
    'Fantasy',
    'Mystery',
    'Romance',
    'Thriller',
    'Horror',
    'Biography',
    'History',
    'Science',
    'Poetry',
    'Drama',
    'Children',
    'Young Adult',
  ];

  void _fetchLocation() async {
    String? location = await _locationService.getCurrentLocation(context);
    if (location != null) {
      setState(() {
        _location = location;
           _locationController.text = location;
      });

    } else {
      print('Failed to fetch location');
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
      _genreController.dispose();
    super.dispose();
  }

  void _submitRequest(bool isUpload) async {
    if (_selectedImage == null && isUpload) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.imageRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await StorageService().uploadImage(
            imageFile: _selectedImage!,
            path: isUpload ? 'book_images/uploads' : 'book_images/requests',
          );
        }

        final location = _selectedLocation;
        final coordinates = _currentPosition != null
            ? GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude)
            : const GeoPoint(0, 0);

        if (isUpload) {
          if (imageUrl == null) {
            throw Exception('Image is required for book uploads');
          }

        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
       final docRef = _firestore.collection('available_books').doc();
          final bookUpload = BookUpload(
            userId: userId,
            title: _titleController.text,
            genre: _genreController.text,
            author: _authorController.text,
            condition: _conditionController.text,
            location: _locationController.text,
            imageUrl: imageUrl,
            coordinates: coordinates,
            createdAt: DateTime.now(),
            status: 'Available',
             availableBookId: docRef.id 
          );
          final bookOffer = BookOffer(
            requestId: docRef.id, // Assuming you have this from auth
            offererId: userId,
            requesterId: "pending",
            status: "pending",
            offerType: 'AvailableOffer',
            createdAt: DateTime.now(),
          );

         
          await BookUploadService().createBookUpload(bookUpload);
          await BookOfferService().createBookOffer(bookOffer);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.bookUploadedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        } else {
           final bool isDirect = false;
          final bookRequest = BookRequest(
            userId: userId,
            title: _titleController.text,
            genre: _genreController.text,
            author: _authorController.text,
            condition: _conditionController.text,
            location: _locationController.text,
            imageUrl: imageUrl,
            requestType: 'GeneralRequest',
            coordinates: coordinates,
            createdAt: DateTime.now(),
            status: 'Active',
          );

          await BookRequestService().createBookRequest(bookRequest, isDirect);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.bookRequestSubmitted),
              backgroundColor: Colors.green,
            ),
          );
        }

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        print(e);
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

  // Future<bool> _handleLocationPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content:
  //               Text('Location services are disabled. Please enable them.')),
  //     );
  //     return false;
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Location permissions are denied.')),
  //       );
  //       return false;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Location permissions are permanently denied.'),
  //       ),
  //     );
  //     return false;
  //   }

  //   return true;
  // }

  // Future<void> getCurrentLocation() async {
  //   print('_getCurrentLocation');
  //   final hasPermission = await _handleLocationPermission();

  //   if (!hasPermission) return;

  //   try {
  //     print('hasPermission');
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );

  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );

  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks[0];
  //       setState(() {
  //         _currentPosition = position;
  //         print('_currentPosition: ${_currentPosition}');
  //         // Only store city and neighborhood for privacy
  //         _selectedLocation =
  //             '${place.locality ?? ''}, ${place.subLocality ?? ''}';
  //         _locationController.text = _selectedLocation;
  //         print('_selectedLocation: ${_selectedLocation}');
  //         print('_locationController.text: ${_locationController.text}');
  //       });
  //     } else {
  //       print('placemarks is emptey');
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // void _selectLocation() async {
  //   await _fetchLocation();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isUpload
              ? AppLocalizations.of(context)!.uploadabook
              : AppLocalizations.of(context)!.requestabook,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isUpload ? LucideIcons.download : LucideIcons.upload),
            onPressed: () {
              setState(() {
                _isUpload = !_isUpload;
                _clearForm();
              });
            },
            tooltip: _isUpload
                ? AppLocalizations.of(context)!.switchToRequest
                : AppLocalizations.of(context)!.switchToUpload,
          ),
        ],
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
                              return AppLocalizations.of(context)!
                                  .pleaseentertheauthor;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
                          value: _selectedGenre,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.genre,
                            prefixIcon: const Icon(LucideIcons.bookOpen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: _genres.map((String genre) {
                            return DropdownMenuItem<String>(
                              value: genre,
                              child: Text(genre),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .pleaseSelectGenre;
                            }
                            return null;
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGenre = newValue;
                              _genreController.text = newValue ?? '';
                            });
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
                            labelText:
                                AppLocalizations.of(context)!.bookcondition,
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
                          onTap: _fetchLocation,
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .generallocation,
                                prefixIcon: const Icon(LucideIcons.mapPin),
                                suffixIcon: IconButton(
                                  icon: const Icon(LucideIcons.locate),
                                  onPressed: _fetchLocation,
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
                      placeholder:
                          AppLocalizations.of(context)!.taptoaddbookimage,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                if (_isUpload)
                  Text(
                    AppLocalizations.of(context)!.imageRequired,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => _submitRequest(_isUpload),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          _isUpload
                              ? AppLocalizations.of(context)!.uploadBook
                              : AppLocalizations.of(context)!.submitRequest,
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
