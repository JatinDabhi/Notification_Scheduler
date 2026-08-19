import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_controller.dart';
import '../api_service.dart';

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final AppController appController = Get.find();

  // Single Tab
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // Bulk Tab
  final TextEditingController bulkJsonController = TextEditingController();

  bool isSaving = false;

  Future<void> saveSingle() async {
    final title = titleController.text.trim();
    final desc = descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    setState(() => isSaving = true);
    try {
      await ApiService.createTitle(
        appController.currentAppId.value,
        title,
        desc,
      );
      if (!mounted) return;
      Get.back();
      Get.snackbar('Success', 'Notification queued successfully');
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      Get.snackbar('Error', 'Failed to save: $e');
    }
  }

  Future<void> saveBulk() async {
    final text = bulkJsonController.text.trim();
    if (text.isEmpty) {
      Get.snackbar('Error', 'Please paste the JSON data');
      return;
    }

    setState(() => isSaving = true);
    try {
      // 1. Parse the JSON
      final dynamic parsed = jsonDecode(text);
      if (parsed is! List) {
        throw Exception(
          'JSON must be a list/array of objects starting with [ and ending with ]',
        );
      }

      // 2. Map 'body' to 'description'
      List<Map<String, String>> formattedList = [];
      for (var item in parsed) {
        if (item is Map) {
          final title = item['title']?.toString() ?? '';
          // the user JSON uses "body", our DB uses "description"
          final desc = (item['body'] ?? item['description'])?.toString() ?? '';

          if (title.isNotEmpty && desc.isNotEmpty) {
            formattedList.add({'title': title, 'description': desc});
          }
        }
      }

      if (formattedList.isEmpty) {
        throw Exception('No valid notifications found in JSON');
      }

      // 3. Send to API
      await ApiService.createMultipleTitles(
        appController.currentAppId.value,
        formattedList,
      );

      if (!mounted) return;
      Get.back();
      Get.snackbar(
        'Success',
        '${formattedList.length} notifications queued successfully',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      Get.snackbar('Invalid JSON', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add Notification',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Single Add'),
              Tab(text: 'Bulk Paste (JSON)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // SINGLE ADD TAB
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description / Body',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveSingle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Save to Queue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // BULK JSON TAB
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Paste your JSON array here. It must contain "title" and "body".\nExample:\n[{"title":"A", "body":"B"}]',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: bulkJsonController,
                      maxLines: 100, // Makes it expand fully
                      decoration: const InputDecoration(
                        hintText:
                            '[\n  {\n    "title": "...",\n    "body": "..."\n  }\n]',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : saveBulk,
                      icon: isSaving
                          ? const SizedBox.shrink()
                          : const Icon(Icons.save_alt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      label: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Save Bulk to Queue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
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
