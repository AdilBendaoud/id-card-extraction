import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:file_picker/file_picker.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultScreen({super.key, required this.data});

  // Save data as a text file
  Future<void> _saveAsText(BuildContext context) async {
    try {
      // Let the user choose a directory
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filePath = '$directoryPath/id_card_data_$formattedDate.txt';
      final file = File(filePath);

      // Write data to the file
      final content = data.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join('\n');
      await file.writeAsString(content);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved as text: $filePath')),
      );
    } catch (e) {
      print('Error : ' + e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save as text')),
      );
    }
  }

  // Save data as a PDF file
  Future<void> _saveAsPDF(BuildContext context) async {
    try {
      // Let the user choose a directory
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        // User canceled the picker
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filePath = '$directoryPath/id_card_data_$formattedDate.pdf';
      final file = File(filePath);

      // Create a PDF document
      final pdf = pdfWidgets.Document();
      pdf.addPage(
        pdfWidgets.Page(
          build: (context) {
            return pdfWidgets.Column(
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: data.entries.map((entry) {
                return pdfWidgets.Text(
                  '${entry.key}: ${entry.value}',
                  style: const pdfWidgets.TextStyle(fontSize: 14),
                );
              }).toList(),
            );
          },
        ),
      );

      // Write the PDF to the file
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved as PDF: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save as PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Card Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: data.isNotEmpty
            ? Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var entry in data.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  entry.value is List ? (entry.value as List).join(' ') :entry.value.toString(),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : const Center(child: Text('No data available')),
      ),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'pdf') {
            _saveAsPDF(context);
          } else if (value == 'text') {
            _saveAsText(context);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'pdf',
            child: Text('Save as PDF'),
          ),
          const PopupMenuItem(
            value: 'text',
            child: Text('Save as Text'),
          ),
        ],
        child: const FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.save),
        ),
      ),
    );
  }
}
