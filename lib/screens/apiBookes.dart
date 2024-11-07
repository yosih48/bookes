import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MainDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BookedUp'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search books near you',
                prefixIcon: Icon(LucideIcons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Nearby Books
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Books',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to map view
                  },
                  icon: Icon(LucideIcons.map),
                  label: Text('View on Map'),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (context, index) => SizedBox(height: 16.0),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          // child: Image.network(
                          //   '/api/placeholder/80/120',
                          //   width: 80,
                          //   height: 120,
                          // ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Great Gatsby',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text('by F. Scott Fitzgerald'),
                              SizedBox(height: 4.0),
                              Text('0.5 mi away'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle book request
                          },
                          child: Text('Request to Borrow'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),

            // User Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32.0,
                    // backgroundImage: NetworkImage('/api/placeholder/80/80'),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.user, size: 16.0, color: Colors.grey),
                      SizedBox(width: 4.0),
                      Text('15 books shared'),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.messageCircle,
                          size: 16.0, color: Colors.grey),
                      SizedBox(width: 4.0),
                      Text('8 conversations'),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  TextButton(
                    onPressed: () {
                      // Navigate to user profile
                    },
                    child: Text('View Profile'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
