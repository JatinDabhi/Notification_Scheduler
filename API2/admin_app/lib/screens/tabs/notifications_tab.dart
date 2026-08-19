import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api_service.dart';
import '../../app_controller.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({Key? key}) : super(key: key);

  @override
  State<NotificationsTab> createState() => NotificationsTabState();
}

class NotificationsTabState extends State<NotificationsTab> {
  final AppController appController = Get.find();
  List<dynamic> notifications = [];
  bool isLoading = true;

  // Default values for the Fixed Update Card
  String updateTitle = "🚀 New Update Available";
  String updateDesc =
      "Please update your app to the latest version to enjoy new features.";

  // Default values for the Fixed Collection Card
  String collectionTitle = "🎉 New Photos Added!";
  String collectionDesc =
      "Check out the latest photos added to our collection today.";

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
      if (!mounted) return;
      setState(() {
        notifications = response['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to fetch: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await ApiService.deleteTitle(appController.currentAppId.value, id);
      Get.snackbar(
        'Deleted',
        'Notification removed successfully',
        backgroundColor: Colors.green.shade100,
      );
      fetchNotifications();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  Future<void> triggerNotification(String id) async {
    try {
      await ApiService.triggerTitle(appController.currentAppId.value, id);
      Get.snackbar(
        'Sent',
        'Notification sent instantly!',
        backgroundColor: Colors.green.shade100,
      );
      fetchNotifications();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to trigger: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  Future<void> triggerInstantUpdate() async {
    try {
      await ApiService.triggerInstant(
        appController.currentAppId.value,
        updateTitle,
        updateDesc,
      );
      Get.snackbar(
        'Sent',
        'Update Notification sent instantly!',
        backgroundColor: Colors.green.shade100,
      );
      fetchNotifications();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to trigger: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final titleCtrl = TextEditingController(text: item['title']);
    final descCtrl = TextEditingController(text: item['description']);

    Get.defaultDialog(
      title: 'Edit Notification',
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: Column(
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      textConfirm: 'Update',
      textCancel: 'Cancel',
      onConfirm: () async {
        Get.back();
        try {
          await ApiService.updateTitle(
            appController.currentAppId.value,
            item['_id'],
            titleCtrl.text.trim(),
            descCtrl.text.trim(),
          );
          fetchNotifications();
          Get.snackbar(
            'Success',
            'Updated successfully',
            backgroundColor: Colors.green.shade100,
          );
        } catch (e) {
          Get.snackbar('Error', 'Update failed: $e');
        }
      },
    );
  }

  void _showEditUpdateDialog() {
    final titleCtrl = TextEditingController(text: updateTitle);
    final descCtrl = TextEditingController(text: updateDesc);

    Get.defaultDialog(
      title: 'Edit Update Message',
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: Column(
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      onConfirm: () {
        setState(() {
          updateTitle = titleCtrl.text.trim();
          updateDesc = descCtrl.text.trim();
        });
        Get.back();
      },
    );
  }

  Widget _buildUpdateCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              'PINNED: INSTANT APP UPDATE',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              updateTitle,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                updateDesc,
                style: GoogleFonts.inter(color: Colors.grey.shade800),
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _showEditUpdateDialog();
                if (val == 'trigger') triggerInstantUpdate();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'trigger',
                  child: Row(
                    children: [
                      Icon(Icons.rocket_launch, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Trigger Now'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.black54, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Text'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> triggerInstantCollection() async {
    try {
      await ApiService.triggerInstant(
        appController.currentAppId.value,
        collectionTitle,
        collectionDesc,
      );
      Get.snackbar(
        'Sent',
        'Collection Notification sent instantly!',
        backgroundColor: Colors.green.shade100,
      );
      fetchNotifications();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to trigger: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  void _showEditCollectionDialog() {
    final titleCtrl = TextEditingController(text: collectionTitle);
    final descCtrl = TextEditingController(text: collectionDesc);

    Get.defaultDialog(
      title: 'Edit Collection Message',
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: Column(
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      onConfirm: () {
        setState(() {
          collectionTitle = titleCtrl.text.trim();
          collectionDesc = descCtrl.text.trim();
        });
        Get.back();
      },
    );
  }

  Widget _buildCollectionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.purple.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              'PINNED: NEW COLLECTION',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              collectionTitle,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                collectionDesc,
                style: GoogleFonts.inter(color: Colors.grey.shade800),
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _showEditCollectionDialog();
                if (val == 'trigger') triggerInstantCollection();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'trigger',
                  child: Row(
                    children: [
                      Icon(Icons.rocket_launch, color: Colors.purple, size: 20),
                      SizedBox(width: 8),
                      Text('Trigger Now'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.black54, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Text'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: fetchNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length + 2, // +2 for the Fixed Cards
        itemBuilder: (context, index) {
          if (index == 0) return _buildUpdateCard();
          if (index == 1) return _buildCollectionCard();

          final item = notifications[index - 2];
          final bool isSent = item['status'] == 'sent';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSent ? Colors.green.shade200 : Colors.orange.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                item['title'] ?? '',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  item['description'] ?? '',
                  style: GoogleFonts.inter(color: Colors.grey.shade700),
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'trigger') triggerNotification(item['_id']);
                  if (val == 'edit') _showEditDialog(item);
                  if (val == 'delete') deleteNotification(item['_id']);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'trigger',
                    child: Row(
                      children: [
                        Icon(
                          Icons.rocket_launch,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text('Send Instantly'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
