import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
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
    // Optimistic UI update
    setState(() {
      notifications.removeWhere((item) => item['_id'] == id);
    });

    try {
      await ApiService.deleteTitle(appController.currentAppId.value, id);
      Get.snackbar(
        'Deleted',
        'Notification removed successfully',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        backgroundColor: Colors.red.shade100,
      );
      fetchNotifications(); // Revert on failure
    }
  }

  Future<void> triggerNotification(String id) async {
    // Optimistic UI update
    setState(() {
      final index = notifications.indexWhere((item) => item['_id'] == id);
      if (index != -1) {
        notifications[index]['status'] = 'sent';
      }
    });

    try {
      await ApiService.triggerTitle(appController.currentAppId.value, id);
      Get.snackbar(
        'Sent',
        'Notification sent instantly!',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to trigger: $e',
        backgroundColor: Colors.red.shade100,
      );
      fetchNotifications(); // Revert on failure
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to trigger: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to trigger: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  void _showCustomDialog({
    required String title,
    required TextEditingController titleCtrl,
    required TextEditingController descCtrl,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: titleCtrl,
                  style: GoogleFonts.inter(color: const Color(0xFF1F2937), fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: descCtrl,
                  maxLines: 4,
                  style: GoogleFonts.inter(color: const Color(0xFF1F2937)),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(confirmText, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final titleCtrl = TextEditingController(text: item['title']);
    final descCtrl = TextEditingController(text: item['description']);

    _showCustomDialog(
      title: 'Edit Notification',
      titleCtrl: titleCtrl,
      descCtrl: descCtrl,
      confirmText: 'Update',
      onConfirm: () async {
        Get.back();
        final newTitle = titleCtrl.text.trim();
        final newDesc = descCtrl.text.trim();

        // Optimistic UI update
        setState(() {
          final index = notifications.indexWhere((n) => n['_id'] == item['_id']);
          if (index != -1) {
            notifications[index]['title'] = newTitle;
            notifications[index]['description'] = newDesc;
          }
        });

        try {
          await ApiService.updateTitle(
            appController.currentAppId.value,
            item['_id'],
            newTitle,
            newDesc,
          );
          Get.snackbar(
            'Success',
            'Updated successfully',
            backgroundColor: Colors.green.shade100,
          );
        } catch (e) {
          Get.snackbar('Error', 'Update failed: $e');
          fetchNotifications(); // Revert on failure
        }
      },
    );
  }

  void _showEditUpdateDialog() {
    final titleCtrl = TextEditingController(text: updateTitle);
    final descCtrl = TextEditingController(text: updateDesc);

    _showCustomDialog(
      title: 'Edit Update Message',
      titleCtrl: titleCtrl,
      descCtrl: descCtrl,
      confirmText: 'Save',
      onConfirm: () {
        setState(() {
          updateTitle = titleCtrl.text.trim();
          updateDesc = descCtrl.text.trim();
        });
        Get.back();
      },
    );
  }

  void _showEditCollectionDialog() {
    final titleCtrl = TextEditingController(text: collectionTitle);
    final descCtrl = TextEditingController(text: collectionDesc);

    _showCustomDialog(
      title: 'Edit Collection Message',
      titleCtrl: titleCtrl,
      descCtrl: descCtrl,
      confirmText: 'Save',
      onConfirm: () {
        setState(() {
          collectionTitle = titleCtrl.text.trim();
          collectionDesc = descCtrl.text.trim();
        });
        Get.back();
      },
    );
  }

  Widget _buildSpecialCard({
    required String headerText,
    required Color color,
    required String title,
    required String desc,
    required VoidCallback onEdit,
    required VoidCallback onTrigger,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              headerText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFF1F2937),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                desc,
                style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 13),
              ),
            ),
            trailing: _buildPopupMenu(
              onEdit: onEdit,
              onTrigger: onTrigger,
              triggerColor: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu({
    VoidCallback? onEdit,
    VoidCallback? onTrigger,
    VoidCallback? onDelete,
    Color triggerColor = const Color(0xFF6366F1),
  }) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF9CA3AF)),
      onSelected: (val) {
        if (val == 'trigger' && onTrigger != null) onTrigger();
        if (val == 'edit' && onEdit != null) onEdit();
        if (val == 'delete' && onDelete != null) onDelete();
      },
      itemBuilder: (context) => [
        if (onTrigger != null)
          PopupMenuItem(
            value: 'trigger',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: triggerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.rocket_launch_rounded, color: triggerColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text('Send Instantly', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.blue, size: 18),
                ),
                const SizedBox(width: 12),
                Text('Edit Message', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                ),
                const SizedBox(width: 12),
                Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildShimmerLoading();

    return RefreshIndicator(
      onRefresh: fetchNotifications,
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: notifications.length + 2, // +2 for the Fixed Cards
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSpecialCard(
              headerText: 'PINNED: INSTANT APP UPDATE',
              color: const Color(0xFF3B82F6), // Blue
              title: updateTitle,
              desc: updateDesc,
              onEdit: _showEditUpdateDialog,
              onTrigger: triggerInstantUpdate,
            );
          }
          if (index == 1) {
            return _buildSpecialCard(
              headerText: 'PINNED: NEW COLLECTION',
              color: const Color(0xFF8B5CF6), // Purple
              title: collectionTitle,
              desc: collectionDesc,
              onEdit: _showEditCollectionDialog,
              onTrigger: triggerInstantCollection,
            );
          }

          final item = notifications[index - 2];
          final bool isSent = item['status'] == 'sent';
          final statusColor = isSent ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + ((index - 2) * 50).clamp(0, 500)),
            curve: Curves.easeOutCubic,
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status indicator line on the left
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            if (isSent)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'SENT',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            item['description'] ?? '',
                            style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 13),
                          ),
                        ),
                        trailing: _buildPopupMenu(
                          onTrigger: () => triggerNotification(item['_id']),
                          onEdit: () => _showEditDialog(item),
                          onDelete: () => deleteNotification(item['_id']),
                          triggerColor: const Color(0xFF6366F1), // Indigo
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
