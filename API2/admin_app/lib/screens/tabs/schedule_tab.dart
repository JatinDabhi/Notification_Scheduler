import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
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
      Get.snackbar('Error', 'Failed to fetch settings: $e', backgroundColor: Colors.red.shade100);
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
    showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Color(0xFF1F2937), // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
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
        } else {
          Get.snackbar('Notice', 'Time already exists', backgroundColor: Colors.orange.shade100);
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

  String formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final hr12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '${hr12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm';
    } catch (e) {
      return timeStr;
    }
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 30,
              width: 150,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildShimmerLoading();

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Schedule', 
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF111827))
              ),
              InkWell(
                onTap: _showAddTimeDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: Color(0xFF8B5CF6), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Add Time',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B5CF6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Notifications will be sent in FIFO order at these times everyday.',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 13),
          ),
          Expanded(
            child: notificationTimes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 24,right: 24,bottom: 24,top: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.schedule_rounded, size: 64, color: Color(0xFF8B5CF6)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No schedule configured',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF374151)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a time to start sending notifications',
                          style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notificationTimes.length,
                    itemBuilder: (context, index) {
                      final time = notificationTimes[index];
                      final isFirst = index == 0;
                      final isLast = index == notificationTimes.length - 1;
                      
                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: IntrinsicHeight(
                            child: Row(
                            children: [
                              // Beautiful Timeline Component
                              SizedBox(
                                width: 30,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: 2, 
                                        color: isFirst && isLast 
                                            ? Colors.transparent 
                                            : isFirst 
                                                ? Colors.transparent 
                                                : const Color(0xFFC4B5FD)
                                      ),
                                    ),
                                    Container(
                                      width: 12, 
                                      height: 12,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF8B5CF6), width: 2.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF8B5CF6).withOpacity(0.4),
                                            blurRadius: 4,
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: 2, 
                                        color: isFirst && isLast 
                                            ? Colors.transparent 
                                            : isLast 
                                                ? Colors.transparent 
                                                : const Color(0xFFC4B5FD)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Modern Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F3FF),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.access_time_rounded, color: Color(0xFF6366F1), size: 18),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            formatTime(time),
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700, 
                                              fontSize: 16, 
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.defaultDialog(
                                            title: 'Remove Time',
                                            middleText: 'Are you sure you want to remove this time from the schedule?',
                                            textConfirm: 'Remove',
                                            textCancel: 'Cancel',
                                            confirmTextColor: Colors.white,
                                            buttonColor: const Color(0xFFEF4444),
                                            onConfirm: () {
                                              _removeTime(time);
                                              Get.back();
                                            },
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
