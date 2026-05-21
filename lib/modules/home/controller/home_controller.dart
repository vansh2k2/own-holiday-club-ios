import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repository/service_repo.dart';
import '../../../utils/api_constants.dart';
import '../../../routes/app_pages.dart';
import 'dart:convert';

class HomeController extends GetxController {
  final ServiceRepo serviceRepo = Get.find();
  
  var isLoading = true.obs;

  final banners = [
    'assets/images/santorini_experience.png',
    'assets/images/maldives_private_shore.png',
  ].obs;

  final allPortfolioImages = <Map<String, dynamic>>[].obs;
  final allServicesWithGallery = <Map<String, dynamic>>[].obs;
  final services = <Map<String, dynamic>>[].obs;
  final destinations = <Map<String, dynamic>>[].obs;
  final featuredExperiences = <Map<String, dynamic>>[].obs;

  final featuredPageController = PageController(viewportFraction: 0.88);
  var currentFeaturedPage = 0.obs;

  final faqs = <Map<String, dynamic>>[].obs;
  final heroSlides = <Map<String, dynamic>>[].obs;
  final heroPageController = PageController();
  var currentHeroPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    _startHeroAutoPlay();
  }



  void _startHeroAutoPlay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (heroSlides.isNotEmpty) {
        int next = (currentHeroPage.value + 1) % heroSlides.length;
        if (heroPageController.hasClients) {
          heroPageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutQuart,
          );
        }
      }
      _startHeroAutoPlay();
    });
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    try {
      // Fetch Hero Slides
      fetchHeroSlides();

      // Fetch FAQ
      fetchFaqs();

      // Fetch Services Categories
      var serviceResponse = await serviceRepo.getExploreServices();
      if (serviceResponse.statusCode == 200) {
        var body = jsonDecode(serviceResponse.body);
        if (body['success'] == true) {
          services.value = List<Map<String, dynamic>>.from(body['data']['services']);
        }
      }

      // Fetch Service Details for Portfolio/Gallery
      var sdResponse = await serviceRepo.getServiceDetailsList();
      if (sdResponse.statusCode == 200) {
        var body = jsonDecode(sdResponse.body);
        if (body['success'] == true) {
          var fetchedServices = List<Map<String, dynamic>>.from(body['data']);
          allServicesWithGallery.value = fetchedServices;
          
          List<Map<String, dynamic>> mixedImages = [];
          for (var svc in fetchedServices) {
            if (svc['gallery'] != null && svc['gallery'] is List) {
              for (var imgUrl in svc['gallery']) {
                mixedImages.add({
                  'image': imgUrl,
                  'title': svc['serviceTitle'] ?? 'Luxury Experience',
                  'description': svc['shortDescription'] ?? 'Discover our premium offerings.',
                  'badge': 'PORTFOLIO',
                  'serviceSlug': svc['slug']
                });
              }
            }
          }
          // Shuffle images
          mixedImages.shuffle();
          allPortfolioImages.value = mixedImages;
          
          // Map categories with their galleries for featured experiences
          featuredExperiences.value = fetchedServices.where((svc) => svc['gallery'] != null && (svc['gallery'] as List).isNotEmpty).toList();
        }
      }

      // Fetch Destinations
      var destResponse = await serviceRepo.getDestinations();
      if (destResponse.statusCode == 200) {
        var body = jsonDecode(destResponse.body);
        if (body['success'] == true) {
          destinations.value = List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      print('Error fetching home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHeroSlides() async {
    try {
      print('--- 🚀 API REQUEST [GET] ---');
      print('🔗 URL: ${ApiConstants.heroSlides}');
      
      var response = await serviceRepo.getHeroSlides();
      
      print('✅ STATUS CODE: ${response.statusCode}');
      // print('📦 RESPONSE: ${response.body}');
      print('----------------------------');

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          heroSlides.value = List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      print('Error fetching Hero Slides: $e');
    }
  }

  Future<void> fetchFaqs() async {
    try {
      var response = await serviceRepo.getFaqs();
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          faqs.value = List<Map<String, dynamic>>.from(body['data']['faqs']);
        }
      }
    } catch (e) {
      print('Error fetching FAQs: $e');
    }
  }

  @override
  void onClose() {
    featuredPageController.dispose();
    heroPageController.dispose();
    super.onClose();
  }

  Future<bool> submitEnquiry(Map<String, dynamic> data) async {
    try {
      print('--- 🚀 API REQUEST [POST] ---');
      print('🔗 URL: ${ApiConstants.enquiries}');
      print('📦 PAYLOAD: $data');
      
      var response = await serviceRepo.submitDestinationEnquiry(data);
      
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE: ${response.body}');
      print('----------------------------');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ API ERROR: $e');
      return false;
    }
  }

  Future<bool> submitServiceEnquiry(Map<String, dynamic> data) async {
    try {
      print('--- 🚀 API REQUEST [POST] ---');
      print('🔗 URL: ${ApiConstants.serviceEnquiries}');
      print('📦 PAYLOAD: $data');
      
      var response = await serviceRepo.submitServiceEnquiry(data);
      
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE: ${response.body}');
      print('----------------------------');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ API ERROR: $e');
      return false;
    }
  }

  void goToDestinationDetails(Map<String, dynamic> destination) {
    Get.toNamed(Routes.DESTINATION_DETAILS, arguments: destination);
  }

  void goToServiceDetails(Map<String, dynamic> serviceCard) {
    // Navigate with the card data as arguments
    // ServiceDetailsView will use this to show initial info and fetch more if needed
    Get.toNamed(Routes.SERVICE_DETAILS, arguments: serviceCard);
  }
}
