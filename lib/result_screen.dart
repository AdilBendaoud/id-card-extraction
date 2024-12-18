import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Card Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: data.isNotEmpty
            ? ListView(
                children: data.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                  );
                }).toList(),
              )
            : const Center(child: Text('No data available')),
      ),
    );
  }
}