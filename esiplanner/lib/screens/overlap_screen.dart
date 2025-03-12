import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OverlapScreen extends StatefulWidget {
  const OverlapScreen({super.key});

  @override
  State<OverlapScreen> createState() => _OverlapScreenState();
}

class _OverlapScreenState extends State<OverlapScreen> {
  List<Map<String, dynamic>> overlappingClasses = [];

  @override
  void initState() {
    super.initState();
    _loadOverlappingClasses();
  }

  Future<void> _loadOverlappingClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('overlapping_classes');

    if (encodedData != null) {
      setState(() {
        overlappingClasses = List<Map<String, dynamic>>.from(jsonDecode(encodedData));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clases Solapadas')),
      body: overlappingClasses.isEmpty
          ? const Center(child: Text('No hay clases solapadas'))
          : ListView.builder(
              itemCount: overlappingClasses.length,
              itemBuilder: (context, index) {
                final overlap = overlappingClasses[index];
                return ListTile(
                  title: Text('${overlap['subjectName']} - ${overlap['classType']}'),
                  subtitle: Text(
                      '${overlap['event']['date']} | ${overlap['event']['start_hour']} - ${overlap['event']['end_hour']}'),
                  leading: const Icon(Icons.warning, color: Colors.red),
                );
              },
            ),
    );
  }
}
