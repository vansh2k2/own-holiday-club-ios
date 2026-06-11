import 'package:http/http.dart' as http;
import '../api/api_client.dart';
import '../../utils/api_constants.dart';

class AuthRepo {
  final ApiClient apiClient;

  AuthRepo({required this.apiClient});

  Future<http.Response> login(String identifier, String password) async {
    return await apiClient.postData(ApiConstants.login, {
      "identifier": identifier,
      "password": password,
    });
  }

  // OTP Methods
  Future<http.Response> sendMobileOtp(String mobile) async {
    return await apiClient.postData("${ApiConstants.baseUrl}/auth/mobile/send-otp", {"mobile": mobile});
  }

  Future<http.Response> verifyMobileOtp(String mobile, String otp) async {
    return await apiClient.postData("${ApiConstants.baseUrl}/auth/mobile/verify-otp", {"mobile": mobile, "otp": otp});
  }

  Future<http.Response> sendEmailOtp(String email) async {
    return await apiClient.postData("${ApiConstants.baseUrl}/auth/email/send-otp", {"email": email});
  }

  Future<http.Response> verifyEmailOtp(String email, String otp) async {
    return await apiClient.postData("${ApiConstants.baseUrl}/auth/email/verify-otp", {"email": email, "otp": otp});
  }

  Future<http.Response> getProfile(String userId) async {
    // This backend version uses userId in path for profile
    return await apiClient.getData("${ApiConstants.profile}/$userId");
  }

  Future<http.Response> updateProfile(String token, dynamic data) async {
    return await apiClient.putData(ApiConstants.profile, data, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  Future<http.Response> getMembers(String token) async {
    return await apiClient.getData(ApiConstants.members, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  Future<http.Response> bookHoliday(Map<String, dynamic> data) async {
    return await apiClient.postData(ApiConstants.holidayLeads, data);
  }

  Future<http.Response> submitSlotBooking(String userId, Map<String, dynamic> data) async {
    return await apiClient.postData("${ApiConstants.baseUrl}/profile/$userId/holiday-bookings", data);
  }

  // Forgot Password
  Future<http.Response> forgotPasswordSendOtp(String identifier) async {
    return await apiClient.postData("${ApiConstants.baseUrl}/auth/forgot-password/send-otp", {
      "identifier": identifier,
    });
  }

  Future<http.Response> verifyForgotPasswordOtp(String identifier, String otp) async {
    return await apiClient.postData("${ApiConstants.baseUrl}/auth/forgot-password/verify-otp", {
      "identifier": identifier,
      "otp": otp,
    });
  }

  Future<http.Response> resetPassword(String identifier, String otp, String newPassword) async {
    return await apiClient.putData("${ApiConstants.baseUrl}/auth/forgot-password/reset", {
      "identifier": identifier,
      "otp": otp,
      "password": newPassword,
    });
  }
}
