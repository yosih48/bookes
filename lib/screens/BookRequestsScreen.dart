import 'dart:typed_data';

import 'package:bookes/models/BookRequest.dart';
import 'package:bookes/resources/BookRequest.dart';
import 'package:bookes/widgets/BookRequestCard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
class BookRequestsScreen extends StatefulWidget {
  @override
  _BookRequestsScreenState createState() => _BookRequestsScreenState();
}

class _BookRequestsScreenState extends State<BookRequestsScreen> {
  final BookRequestService _bookRequestService = BookRequestService();
  bool _showNearbyOnly = false;
  bool _isLoading = false;
  Position? _currentPosition;
  List<BookRequest> _requests = [];
  final double _nearbyRadiusKm = 10.0; // Adjust radius as needed
  Uint8List? _file;
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_showNearbyOnly) {
        // Get current location if not already available
        if (_currentPosition == null) {
          final hasPermission = await _handleLocationPermission();
          if (!hasPermission) {
            throw 'Location permission denied';
          }
          _currentPosition = await Geolocator.getCurrentPosition();
        }

        // Get nearby requests
        _requests = await _bookRequestService.getNearbyRequests(
          GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
          _nearbyRadiusKm,
        );
      } else {
        // Get all requests
        _requests = await _bookRequestService.getBookRequests();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading requests: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied.'),
          ),
        );
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Requests'),
        actions: [
          // Toggle button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('All'),
                  icon: Icon(LucideIcons.list),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Nearby'),
                  icon: Icon(LucideIcons.mapPin),
                ),
              ],
              selected: {_showNearbyOnly},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _showNearbyOnly = newSelection.first;
                });
                _loadRequests();
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Text(
                    _showNearbyOnly
                        ? 'No nearby book requests found'
                        : 'No book requests found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      print(request);
                      return BookRequestCard(
                        request: request,
                        distance: _showNearbyOnly && _currentPosition != null
                            ? _calculateDistance(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                                request.coordinates.latitude,
                                request.coordinates.longitude,
                              )
                            : null,
                      );
                    },
                  ),
                ),
    );
  }

  double _calculateDistance(
    double startLat,
    double startLong,
    double endLat,
    double endLong,
  ) {
    return Geolocator.distanceBetween(
          startLat,
          startLong,
          endLat,
          endLong,
        ) /
        1000; // Convert to kilometers
  }
}
