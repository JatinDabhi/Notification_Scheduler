import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      Get.snackbar('Error', 'Please fill all fields', backgroundColor: Colors.red.shade100);
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
      Get.back(result: true);
      Get.snackbar('Success', 'Notification queued successfully', backgroundColor: Colors.green.shade100);
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      Get.snackbar('Error', 'Failed to save: $e', backgroundColor: Colors.red.shade100);
    }
  }

  Future<void> saveBulk() async {
    final text = bulkJsonController.text.trim();
    if (text.isEmpty) {
      Get.snackbar('Error', 'Please paste the JSON data', backgroundColor: Colors.red.shade100);
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
      Get.back(result: true);
      Get.snackbar(
        'Success',
        '${formattedList.length} notifications queued successfully',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      Get.snackbar('Invalid JSON', e.toString(), backgroundColor: Colors.red.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: DefaultTabController(
        length: 2,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F7FC),
            body: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSingleAddTab(),
                      _buildBulkAddTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Add Notification',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
              unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Single Add'),
                Tab(text: 'Bulk Paste (JSON)'),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.notifications_active_rounded,
            title: 'Notification Details',
            subtitle: 'Enter the title and message body',
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: titleController,
            hint: 'Title (e.g. 50% Off Today!)',
            icon: Icons.title_rounded,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: descController,
            hint: 'Description / Message Body',
            icon: Icons.notes_rounded,
            maxLines: 5,
          ),
          const SizedBox(height: 40),
          _buildSaveButton(onPressed: saveSingle),
        ],
      ),
    );
  }

  Widget _buildBulkAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.data_array_rounded,
            title: 'Bulk Import JSON',
            subtitle: 'Paste an array of notifications',
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'JSON Format',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6B7280)),
                      ),
                      Icon(Icons.paste_rounded, size: 16, color: Colors.grey.shade400),
                    ],
                  ),
                ),
                TextField(
                  controller: bulkJsonController,
                  maxLines: 12,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: '[\n  {\n    "title": "...",\n    "body": "..."\n  }\n]',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSaveButton(onPressed: saveBulk, label: 'Queue Bulk Notifications'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(color: const Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon: maxLines == 1 
              ? Icon(icon, color: const Color(0xFF8B5CF6))
              : Padding(
                  padding: const EdgeInsets.only(bottom: 80), // Align icon to top for multiline
                  child: Icon(icon, color: const Color(0xFF8B5CF6)),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSaveButton({required VoidCallback onPressed, String label = 'Save to Queue'}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? const SizedBox.shrink()
            : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
        label: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
