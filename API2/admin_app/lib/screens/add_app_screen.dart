import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_controller.dart';
import '../api_service.dart';

class AddAppScreen extends StatefulWidget {
  const AddAppScreen({Key? key}) : super(key: key);

  @override
  State<AddAppScreen> createState() => _AddAppScreenState();
}

class _AddAppScreenState extends State<AddAppScreen> {
  final AppController appController = Get.find();
  
  final TextEditingController appIdController = TextEditingController();
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController firebaseJsonController = TextEditingController();

  bool isRegistering = false;

  Future<void> registerNewApp() async {
    final appId = appIdController.text.trim();
    final appName = appNameController.text.trim();
    final firebaseJson = firebaseJsonController.text.trim();

    if (appId.isEmpty || firebaseJson.isEmpty) {
      Get.snackbar('Error', 'App ID and Firebase JSON are required.', backgroundColor: Colors.red.shade100);
      return;
    }

    setState(() => isRegistering = true);

    try {
      final response = await ApiService.registerApp(appId, appName, firebaseJson);
      
      if (response['success'] == true) {
        appController.addApp(appId);
        if (!mounted) return;
        Get.back(); // Go back to Apps Grid
        Get.snackbar('Success', response['message'] ?? 'App registered successfully!', backgroundColor: Colors.green.shade100);
      } else {
        throw Exception(response['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', 'Failed to register app: $e', backgroundColor: Colors.red.shade100);
    } finally {
      if (mounted) setState(() => isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register New App', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200)
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Registering a new app creates a completely separate database table for it, ensuring 100% data isolation.',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.deepPurple.shade900),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text('App Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: appIdController,
              decoration: const InputDecoration(
                labelText: 'App ID (e.g. newapp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fingerprint),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: appNameController,
              decoration: const InputDecoration(
                labelText: 'App Name (Optional, e.g. My New App)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            
            const SizedBox(height: 32),
            Text('Firebase Configuration', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Paste the exact contents of your Firebase Service Account JSON file here.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: firebaseJsonController,
              maxLines: 12,
              decoration: const InputDecoration(
                hintText: '{\n  "type": "service_account",\n  "project_id": "...",\n  "private_key": "...",\n  ...\n}',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isRegistering ? null : registerNewApp,
                icon: isRegistering ? const SizedBox.shrink() : const Icon(Icons.cloud_upload),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: isRegistering
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Register & Setup App', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
