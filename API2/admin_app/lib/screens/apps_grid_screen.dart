import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_controller.dart';
import 'app_dashboard_screen.dart';
import 'add_app_screen.dart';

class AppsGridScreen extends StatelessWidget {
  const AppsGridScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Apps', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.deepPurple,
      ),
      body: Obx(() {
        final apps = appController.savedApps;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: apps.length + 1,
          itemBuilder: (context, index) {
            if (index == apps.length) {
              return _buildAddAppCard(context, appController);
            }
            final appId = apps[index];
            return _buildAppCard(appId, appController);
          },
        );
      }),
    );
  }

  Widget _buildAppCard(String appId, AppController controller) {
    return InkWell(
      onTap: () {
        controller.setAppId(appId);
        Get.to(() => const AppDashboardScreen());
      },
      onLongPress: () {
        // Option to remove app
        Get.defaultDialog(
          title: 'Remove App?',
          middleText: 'Are you sure you want to remove $appId from this list?',
          textConfirm: 'Yes',
          textCancel: 'No',
          confirmTextColor: Colors.white,
          onConfirm: () {
            controller.removeApp(appId);
            Get.back();
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_android, size: 40, color: Colors.deepPurple),
            ),
            const SizedBox(height: 12),
            Text(
              appId,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAppCard(BuildContext context, AppController controller) {
    return InkWell(
      onTap: () => Get.to(() => const AddAppScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade200, width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 12),
            Text(
              'Add New App',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
