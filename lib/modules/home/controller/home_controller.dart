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
  final appGalleryImages = <Map<String, dynamic>>[].obs;
  
  final trendingShorts = <Map<String, dynamic>>[].obs;
  var isShortsLoading = true.obs;
  


  final featuredPageController = PageController(viewportFraction: 0.88);
  var currentFeaturedPage = 0.obs;

  final faqs = <Map<String, dynamic>>[].obs;
  final heroSlides = <Map<String, dynamic>>[].obs;
  final heroPageController = PageController();
  var currentHeroPage = 0.obs;

  final privacyPolicyContent = ''.obs;
  final privacyPolicyTitle = ''.obs;
  final termsContent = ''.obs;
  final termsTitle = ''.obs;
  var isCmsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
    fetchAppGallery();
    fetchTrendingShorts();
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

      // Fetch Privacy/Terms CMS Pages
      fetchCmsPages();

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
      print('--- 🚀 [API RESPONSE] SERVICE DETAILS LIST ---');
      print('STATUS CODE: ${sdResponse.statusCode}');
      print('RESPONSE BODY: ${sdResponse.body}');
      print('---------------------------------------------');
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
          // featuredExperiences.value = fetchedServices.where((svc) => svc['gallery'] != null && (svc['gallery'] as List).isNotEmpty).toList();
        }
      }

      // Fetch Destinations
      var destResponse = await serviceRepo.getDestinations();
      print('--- 🚀 [API RESPONSE] DESTINATIONS ---');
      print('STATUS CODE: ${destResponse.statusCode}');
      print('RESPONSE BODY: ${destResponse.body}');
      print('--------------------------------------');
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

  Future<void> fetchAppGallery() async {
    try {
      print('--- 🚀 [API REQUEST] GET APP GALLERY ---');
      print('🔗 URL: https://api.ownholidayclub.com/api/app-gallery');
      var response = await serviceRepo.getAppGallery();
      print('✅ APP GALLERY STATUS CODE: ${response.statusCode}');
      print('📦 APP GALLERY RESPONSE BODY: ${response.body}');
      
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          var data = body['data'];
          List<Map<String, dynamic>> tempGalleryImages = [];
          
          if (data['featuredImages'] != null && (data['featuredImages'] as List).isNotEmpty) {
            var fImgs = List<Map<String, dynamic>>.from(data['featuredImages'].map((item) => {
              'title': item['text'] ?? '',
              'image': item['image'] != null ? item['image']['url'] ?? '' : '',
            }));
            if (fImgs.length > 8) {
              featuredExperiences.value = fImgs.sublist(0, 8);
              tempGalleryImages.addAll(fImgs.sublist(8).map((item) => {
                'title': item['title'],
                'url': item['image'],
              }));
            } else {
              featuredExperiences.value = fImgs;
            }
          } else {
            // Fallback to old logic if no featured images are found in the App Gallery API
            featuredExperiences.value = allServicesWithGallery.where((svc) => svc['gallery'] != null && (svc['gallery'] as List).isNotEmpty).toList();
          }

          if (data['fullGalleryImages'] != null && (data['fullGalleryImages'] as List).isNotEmpty) {
            var gImgs = List<Map<String, dynamic>>.from(data['fullGalleryImages'].map((item) => {
              'title': item['text'] ?? '',
              'url': item['image'] != null ? item['image']['url'] ?? '' : '',
            }));
            tempGalleryImages.addAll(gImgs);
          } else if (tempGalleryImages.isEmpty) {
            // Fallback to old logic if no gallery images are found
            var fallbackGallery = allServicesWithGallery.expand((s) {
              final title = s['serviceTitle'] ?? 'Event';
              final gallery = List<String>.from(s['gallery'] ?? []);
              return gallery.map((url) => {'title': title, 'url': url});
            }).toList();
            tempGalleryImages.addAll(fallbackGallery);
          }
          appGalleryImages.value = tempGalleryImages;
          print('✅ Processed ${featuredExperiences.length} featured images and ${appGalleryImages.length} gallery images');
        } else {
          print('❌ API Returned Success=False or Data=null');
        }
      } else {
        print('❌ API Failed with Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching App Gallery: $e');
    }
  }

  Future<void> fetchTrendingShorts() async {
    isShortsLoading.value = true;
    try {
      print('--- 🚀 [API REQUEST] GET TRENDING SHORTS ---');
      print('🔗 URL: https://api.ownholidayclub.com/api/app-video-gallery');
      var response = await serviceRepo.getAppVideoGallery();
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null && body['data']['videos'] != null) {
          trendingShorts.value = List<Map<String, dynamic>>.from(body['data']['videos']);
        }
      }
    } catch (e) {
      print('Error fetching trending shorts: $e');
    } finally {
      isShortsLoading.value = false;
    }
  }

  Future<void> fetchFaqs() async {
    try {
      print('--- 🚀 [API REQUEST] GET FAQ ---');
      print('🔗 URL: https://api.ownholidayclub.com/api/faq/membership');
      var response = await serviceRepo.getFaqs();
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('---------------------------------');
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

  Future<void> fetchCmsPages() async {
    isCmsLoading.value = true;
    try {
      print('--- 🚀 [API REQUEST] GET CMS PAGES ---');
      print('🔗 URL: https://api.ownholidayclub.com/api/cms/pages');
      var response = await serviceRepo.getCmsPages();
      print('✅ STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('---------------------------------');
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['pages'] != null && body['pages'] is List) {
          final pagesList = List<dynamic>.from(body['pages']);
          
          final privacyPage = pagesList.firstWhere(
            (p) => p['slug'] == 'privacy-policy',
            orElse: () => null,
          );
          if (privacyPage != null) {
            privacyPolicyTitle.value = privacyPage['title'] ?? 'Privacy Policy';
            privacyPolicyContent.value = privacyPage['body'] ?? '';
          }
          
          final termsPage = pagesList.firstWhere(
            (p) => p['slug'] == 'terms-and-conditions' || p['slug'] == 'terms-conditions' || p['slug'] == 'terms&conditions',
            orElse: () => null,
          );
          if (termsPage != null) {
            termsTitle.value = termsPage['title'] ?? 'Terms & Conditions';
            termsContent.value = termsPage['body'] ?? '';
          }
        }
      }
    } catch (e) {
      print('Error fetching CMS pages: $e');
    } finally {
      isCmsLoading.value = false;
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
