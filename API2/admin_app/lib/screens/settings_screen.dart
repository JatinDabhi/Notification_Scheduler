import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_controller.dart';
import '../api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppController appController = Get.find();
  List<String> notificationTimes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getSettings(appController.currentAppId.value);
      setState(() {
        if (response['data'] != null && response['data']['notificationTimes'] != null) {
          notificationTimes = List<String>.from(response['data']['notificationTimes']);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to fetch settings: $e');
    }
  }

  Future<void> saveSettings() async {
    setState(() => isLoading = true);
    try {
      await ApiService.updateSettings(appController.currentAppId.value, notificationTimes);
      Get.snackbar('Success', 'Schedule updated successfully');
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to update settings: $e');
    }
  }

  void _showAddTimeDialog() {
    TimeOfDay selectedTime = TimeOfDay.now();
    showTimePicker(
      context: context,
      initialTime: selectedTime,
    ).then((pickedTime) {
      if (pickedTime != null) {
        final String hour = pickedTime.hour.toString().padLeft(2, '0');
        final String minute = pickedTime.minute.toString().padLeft(2, '0');
        final timeStr = '$hour:$minute';
        if (!notificationTimes.contains(timeStr)) {
          setState(() {
            notificationTimes.add(timeStr);
            notificationTimes.sort();
          });
          saveSettings();
        }
      }
    });
  }

  void _removeTime(String time) {
    setState(() {
      notificationTimes.remove(time);
    });
    saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Schedule Times')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configure when notifications should be sent daily. Times are in 24-hour format (HH:mm).',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: notificationTimes.isEmpty
                        ? const Center(child: Text('No times configured yet.'))
                        : ListView.builder(
                            itemCount: notificationTimes.length,
                            itemBuilder: (context, index) {
                              final time = notificationTimes[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.access_time),
                                  title: Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeTime(time),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimeDialog,
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}
