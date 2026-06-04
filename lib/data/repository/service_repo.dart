import 'package:http/http.dart' as http;
import '../api/api_client.dart';
import '../../utils/api_constants.dart';

class ServiceRepo {
  final ApiClient apiClient;

  ServiceRepo({required this.apiClient});

  Future<http.Response> getExploreServices() async {
    return await apiClient.getData(ApiConstants.exploreServices);
  }

  Future<http.Response> getDestinations() async {
    return await apiClient.getData(ApiConstants.destinations);
  }

  Future<http.Response> getServiceDetailsList() async {
    return await apiClient.getData(ApiConstants.serviceDetails);
  }

  Future<http.Response> getServiceDetails(String slug) async {
    return await apiClient.getData("${ApiConstants.serviceDetails}?slug=$slug");
  }

  Future<http.Response> submitServiceEnquiry(dynamic data) async {
    return await apiClient.postData(ApiConstants.serviceEnquiries, data);
  }

  Future<http.Response> submitDestinationEnquiry(dynamic data) async {
    return await apiClient.postData(ApiConstants.enquiries, data);
  }

  Future<http.Response> submitGeneralEnquiry(dynamic data) async {
    return await apiClient.postData(ApiConstants.holidayLeads, data);
  }

  Future<http.Response> sendMobileOtp(String mobile) async {
    return await apiClient.postData("${ApiConstants.holidayLeads}/mobile/send-otp", {"mobile": mobile});
  }

  Future<http.Response> verifyMobileOtp(String mobile, String otp) async {
    return await apiClient.postData("${ApiConstants.holidayLeads}/mobile/verify-otp", {"mobile": mobile, "otp": otp});
  }

  Future<http.Response> sendEmailOtp(String email) async {
    return await apiClient.postData("${ApiConstants.holidayLeads}/email/send-otp", {"email": email});
  }

  Future<http.Response> verifyEmailOtp(String email, String otp) async {
    return await apiClient.postData("${ApiConstants.holidayLeads}/email/verify-otp", {"email": email, "otp": otp});
  }

  Future<http.Response> getFaqs() async {
    return await apiClient.getData("${ApiConstants.faq}/membership");
  }

  Future<http.Response> getCmsPages() async {
    return await apiClient.getData("https://api.ownholidayclub.com/api/cms/pages");
  }

  Future<http.Response> getHeroSlides() async {
    return await apiClient.getData(ApiConstants.heroSlides);
  }
}
