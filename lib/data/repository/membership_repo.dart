import 'package:http/http.dart' as http;
import '../api/api_client.dart';
import '../../utils/api_constants.dart';

class MembershipRepo {
  final ApiClient apiClient;

  MembershipRepo({required this.apiClient});

  Future<http.Response> getMembershipPlans() async {
    return await apiClient.getData(ApiConstants.membershipPlans);
  }

  Future<http.Response> purchaseMembership(dynamic data) async {
    return await apiClient.postData(ApiConstants.membershipPurchase, data);
  }

  Future<http.Response> createRazorpayOrder(String tierId, dynamic memberDetails) async {
    return await apiClient.postData(ApiConstants.createOrder, {
      "tierId": tierId,
      "memberDetails": memberDetails,
    });
  }

  Future<http.Response> saveMembership(
    String tierId,
    dynamic memberDetails, {
    String? referralCode,
  }) async {
    return await apiClient.postData(ApiConstants.saveMembership, {
      "tierId": tierId,
      "memberDetails": memberDetails,
      if (referralCode != null && referralCode.trim().isNotEmpty)
        "referralCode": referralCode.trim().toUpperCase(),
    });
  }

  Future<http.Response> verifyPayment(dynamic data) async {
    return await apiClient.postData(ApiConstants.verifyPayment, data);
  }

  Future<http.Response> validateReferralCode(String code) async {
    return await apiClient.postData(ApiConstants.validateReferralCode, {
      "code": code,
    });
  }
}
