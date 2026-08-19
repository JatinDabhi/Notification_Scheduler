import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_controller.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/schedule_tab.dart';
import 'add_notification_screen.dart';

class AppDashboardScreen extends StatefulWidget {
  const AppDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AppDashboardScreen> createState() => _AppDashboardScreenState();
}

class _AppDashboardScreenState extends State<AppDashboardScreen> {
  final AppController appController = Get.find();
  final GlobalKey<NotificationsTabState> _notificationsTabKey = GlobalKey<NotificationsTabState>();
  int _selectedIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      NotificationsTab(key: _notificationsTabKey),
      const ScheduleTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appController.currentAppId.value.toUpperCase(), 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _tabs[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => const AddNotificationScreen())?.then((_) {
                  // Automatically refresh notifications when coming back
                  _notificationsTabKey.currentState?.fetchNotifications();
                });
              },
              icon: const Icon(Icons.add),
              label: Text('New Notification', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
