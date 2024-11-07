import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_api_headers/google_api_headers.dart';



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
void _selectLocation() async {
    // Replace 'YOUR_GOOGLE_MAPS_API_KEY' with your actual API key
    final predictionResult = await PlacesAutocomplete.show(
      context: context,
      apiKey: 'YOUR_GOOGLE_MAPS_API_KEY',
      mode: Mode.overlay,
      language: 'en',
      // countriesFilter: ['us'],
      strictbounds: false,
      onError: (response) {
        print(response.errorMessage);
      },
    );

    if (predictionResult != null) {
      setState(() {
        // Only store the city/neighborhood name, not the full address
        _selectedLocation = predictionResult.description!;
      });
    }
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
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
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
