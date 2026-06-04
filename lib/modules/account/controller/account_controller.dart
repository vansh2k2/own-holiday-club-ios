import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:own_holiday_app/modules/auth/login/model/user_model.dart';
import 'package:own_holiday_app/data/repository/auth_repo.dart';
import 'dart:convert';

class AccountController extends GetxController {
  final AuthRepo authRepo = Get.find();
  final GetStorage storage = Get.find();
  
  var isLoggedIn = false.obs;
  final Rxn<UserModel> userData = Rxn<UserModel>();
  var isLoading = false.obs;

  static const String USER_KEY = 'user_data';

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    final savedUser = storage.read(USER_KEY);
    if (savedUser != null) {
      userData.value = UserModel.fromJson(savedUser is String ? jsonDecode(savedUser) : savedUser);
      isLoggedIn.value = true;
      fetchProfile(); // Update data from server
    }
  }

  Future<void> fetchProfile() async {
    if (userData.value?.id == null) return;
    
    final url = 'https://api.ownholidayclub.com/api/profile/${userData.value!.id!}';
    print('\n--- 🚀 [API REQUEST] GET PROFILE ---');
    print('🔗 URL: $url');

    isLoading.value = true;
    try {
      final response = await authRepo.getProfile(userData.value!.id!);
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('------------------------------------\n');
      final data = jsonDecode(response.body);
      
      // Handle different API response formats (with success key or just user key)
      if (response.statusCode == 200 && (data['user'] != null)) {
        userData.value = UserModel.fromJson(data['user']);
        saveUser(userData.value!); // Update saved data
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Alias for convenience
  Future<void> refreshProfile() => fetchProfile();

  void saveUser(UserModel user) {
    userData.value = user;
    isLoggedIn.value = true;
    storage.write(USER_KEY, user.toJson());
  }

  Future<bool> updateMemberProfile(dynamic updateData) async {
    if (userData.value?.id == null) return false;
    
    isLoading.value = true;
    try {
      final response = await authRepo.updateProfile("", updateData); 
      
      if (response.statusCode == 200) {
        await fetchProfile(); // Refresh
        return true;
      }
    } catch (e) {
      print('Error updating profile: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  void logout() {
    isLoggedIn.value = false;
    userData.value = null;
    storage.remove(USER_KEY);
  }
}
