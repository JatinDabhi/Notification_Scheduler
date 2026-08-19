import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api_service.dart';
import '../../app_controller.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({Key? key}) : super(key: key);

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
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
      if (!mounted) return;
      setState(() {
        if (response['data'] != null && response['data']['notificationTimes'] != null) {
          notificationTimes = List<String>.from(response['data']['notificationTimes']);
          notificationTimes.sort(); // Sort chronologically
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to fetch settings: $e');
    }
  }

  Future<void> saveSettings() async {
    setState(() => isLoading = true);
    try {
      await ApiService.updateSettings(appController.currentAppId.value, notificationTimes);
      Get.snackbar('Success', 'Schedule updated', backgroundColor: Colors.green.shade100);
      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to update: $e', backgroundColor: Colors.red.shade100);
    }
  }

  void _showAddTimeDialog() {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((pickedTime) {
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
        } else {
          Get.snackbar('Notice', 'Time already exists');
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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Schedule', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _showAddTimeDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Time'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade50,
                  foregroundColor: Colors.deepPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will be sent in FIFO order at these times everyday.',
            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: notificationTimes.isEmpty
                ? Center(child: Text('No schedule configured', style: GoogleFonts.inter(color: Colors.grey)))
                : ListView.builder(
                    itemCount: notificationTimes.length,
                    itemBuilder: (context, index) {
                      final time = notificationTimes[index];
                      // Simple timeline visualization
                      return Row(
                        children: [
                          Column(
                            children: [
                              Container(width: 2, height: 20, color: index == 0 ? Colors.transparent : Colors.deepPurple.shade100),
                              Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.deepPurple.shade100, width: 4)
                                ),
                              ),
                              Container(width: 2, height: 20, color: index == notificationTimes.length - 1 ? Colors.transparent : Colors.deepPurple.shade100),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 0,
                              color: Colors.deepPurple.shade50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(time, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                  onPressed: () => _removeTime(time),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
