import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AppController extends GetxController {
  RxString currentAppId = ''.obs;
  RxList<Map<String, dynamic>> apps = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    currentAppId.value = prefs.getString('currentAppId') ?? '';
    await fetchApps();
  }

  Future<void> fetchApps() async {
    isLoading.value = true;
    try {
      final response = await ApiService.getAllApps();
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        apps.assignAll(data.map((e) => e as Map<String, dynamic>).toList());
      }
    } catch (e) {
      print('Error fetching apps: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setAppId(String appId) async {
    currentAppId.value = appId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentAppId', appId);
  }


}
