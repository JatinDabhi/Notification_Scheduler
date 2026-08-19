import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_controller.dart';
import '../api_service.dart';
import 'add_notification_screen.dart';
import 'settings_screen.dart';
import 'app_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppController appController = Get.find();
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getTitles(
        appController.currentAppId.value,
      );
      setState(() {
        notifications = response['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to fetch notifications: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await ApiService.deleteTitle(appController.currentAppId.value, id);
      Get.snackbar('Success', 'Notification deleted');
      fetchNotifications();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${appController.currentAppId.value} - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              appController.setAppId('');
              Get.offAll(() => const AppSelectionScreen());
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text('No notifications found.'))
          : RefreshIndicator(
              onRefresh: fetchNotifications,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  final isSent = item['status'] == 'sent';
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(item['title'] ?? ''),
                      subtitle: Text(item['description'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              item['status'] ?? 'unknown',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: isSent
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteNotification(item['_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const AddNotificationScreen());
          fetchNotifications(); // Refresh after adding
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
