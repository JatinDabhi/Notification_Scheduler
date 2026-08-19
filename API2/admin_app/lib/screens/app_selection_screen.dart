import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_controller.dart';
import 'dashboard_screen.dart';

class AppSelectionScreen extends StatelessWidget {
  const AppSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();
    final TextEditingController appIdController = TextEditingController();

    // Pre-fill if already saved
    if (appController.currentAppId.value.isNotEmpty) {
      appIdController.text = appController.currentAppId.value;
    } else {
      appIdController.text = 'dwarkadhish'; // Default
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select App')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apps, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text(
              'Enter the App ID you want to manage',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: appIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'App ID (e.g. dwarkadhish)',
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final appId = appIdController.text.trim();
                  if (appId.isNotEmpty) {
                    appController.setAppId(appId);
                    Get.offAll(() => const DashboardScreen());
                  } else {
                    Get.snackbar('Error', 'Please enter a valid App ID');
                  }
                },
                child: const Text('Continue', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
