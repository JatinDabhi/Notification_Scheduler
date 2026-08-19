import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  RxString currentAppId = ''.obs;
  RxList<String> savedApps = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    currentAppId.value = prefs.getString('currentAppId') ?? '';
    
    List<String> saved = prefs.getStringList('savedApps') ?? [];
    if (saved.isEmpty) {
      saved = ['dwarkadhish'];
      await prefs.setStringList('savedApps', saved);
    }
    savedApps.value = saved;
  }

  Future<void> setAppId(String appId) async {
    currentAppId.value = appId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentAppId', appId);
  }

  Future<void> addApp(String appId) async {
    if (!savedApps.contains(appId)) {
      savedApps.add(appId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('savedApps', savedApps.toList());
    }
  }

  Future<void> removeApp(String appId) async {
    savedApps.remove(appId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedApps', savedApps.toList());
    if (currentAppId.value == appId) {
      currentAppId.value = '';
      await prefs.remove('currentAppId');
    }
  }
}
