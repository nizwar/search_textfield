# Search TextField Examples

This document contains various examples of how to use the SearchTextfield widget in different scenarios.

## Table of Contents

1. [Basic String Search](#basic-string-search)
2. [User Search with Custom Objects](#user-search-with-custom-objects) 

## Basic String Search

The simplest implementation for searching through a list of strings:

```dart
import 'package:flutter/material.dart';
import 'package:search_textfield/search_textfield.dart';

class BasicSearchExample extends StatelessWidget {
  final List<String> fruits = [
    'Apple', 'Banana', 'Cherry', 'Date', 'Elderberry', 
    'Fig', 'Grape', 'Honeydew', 'Kiwi', 'Lemon'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Basic Search Example')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SearchTextfield<String>(
          future: (context, query) async {
            // Simulate network delay
            await Future.delayed(Duration(milliseconds: 300));
            
            if (query.isEmpty) return [];
            
            return fruits
                .where((fruit) => 
                    fruit.toLowerCase().contains(query.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, fruit) {
            return ListTile(
              title: Text(fruit),
              leading: Icon(Icons.local_grocery_store),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
          menuConstraints: BoxConstraints(maxHeight: 200),
          decoration: InputDecoration(
            hintText: 'Search fruits...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSelected: (context, fruit) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: $fruit')),
            );
            return fruit;
          },
        ),
      ),
    );
  }
}
```

## User Search with Custom Objects

Example showing how to work with custom objects:

```dart
import 'package:flutter/material.dart';
import 'package:search_textfield/search_textfield.dart';

class User {
  final String name;
  final String email;
  final String department;
  final String avatarUrl;
  
  User({
    required this.name,
    required this.email,
    required this.department,
    required this.avatarUrl,
  });
}

class UserSearchExample extends StatelessWidget {
  final List<User> users = [
    User(
      name: 'John Doe',
      email: 'john@example.com',
      department: 'Engineering',
      avatarUrl: 'https://via.placeholder.com/50',
    ),
    User(
      name: 'Jane Smith',
      email: 'jane@example.com',
      department: 'Design',
      avatarUrl: 'https://via.placeholder.com/50',
    ),
    // Add more users...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Search Example')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SearchTextfield<User>(
          future: (context, query) async {
            await Future.delayed(Duration(milliseconds: 500));
            
            if (query.isEmpty) return [];
            
            return users.where((user) {
              return user.name.toLowerCase().contains(query.toLowerCase()) ||
                     user.email.toLowerCase().contains(query.toLowerCase()) ||
                     user.department.toLowerCase().contains(query.toLowerCase());
            }).toList();
          },
          itemBuilder: (context, user) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 2),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                  onBackgroundImageError: (_, __) {},
                  child: Text(user.name[0]),
                ),
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    Text(
                      user.department,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(Icons.person_add),
              ),
            );
          },
          menuConstraints: BoxConstraints(maxHeight: 400),
          decoration: InputDecoration(
            hintText: 'Search users by name, email, or department...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.person_search),
          ),
          onSelected: (context, user) {
            // Handle user selection
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Selected User'),
                content: Text('${user.name} (${user.email})'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
            return user.name;
          },
          onLoading: (context) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Searching users...'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

 
## Running the Examples

To run any of these examples:

1. Create a new Flutter project or use an existing one
2. Add the search_textfield dependency to your pubspec.yaml
3. Copy the example code into your project
4. Import the necessary packages
5. Run the app

## Need Help?

If you encounter any issues with these examples or have questions about implementation, please:

1. Check the main README.md for additional information
2. Review the API documentation
3. Submit an issue on the project repository

Happy coding! 🚀
