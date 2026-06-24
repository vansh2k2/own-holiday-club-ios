import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../home/view/home_view.dart';
import '../../account/view/account_view.dart';
import '../../../data/repository/membership_repo.dart';
import '../../membership/model/membership_tier.dart';

class DashboardController extends GetxController {
  final MembershipRepo membershipRepo = Get.find();
  var currentIndex = 0.obs;

  final pages = [
    HomeView(),
    const Center(child: Text('Membership Content')), 
    const AccountView(),
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  var membershipTiers = <MembershipTier>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMembershipTiers();
  }

  Future<void> fetchMembershipTiers() async {
    try {
      isLoading.value = true;
      final response = await membershipRepo.getMembershipPlans();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tiersJson = data['tiers'] ?? [];
        membershipTiers.value = tiersJson.map((t) => MembershipTier.fromJson(t)).toList();
      }
    } catch (e) {
      print('Error fetching tiers in dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Color getPlanColor(String? name, int index) {
    name = name?.toLowerCase() ?? '';
    if (name.contains('silver')) return const Color(0xFFC0C0C0);
    if (name.contains('gold')) return const Color(0xFFFFD700);
    if (name.contains('platinum')) return const Color(0xFFB4E6FF);
    if (name.contains('diamond')) return const Color(0xFFB9F2FF);
    if (name.contains('titanium')) return const Color(0xFF636363);
    if (name.contains('emerald')) return const Color(0xFF50C878);
    if (name.contains('ruby')) return const Color(0xFFE0115F);
    if (name.contains('sapphire')) return const Color(0xFF0F52BA);
    if (name.contains('purple') || name.contains('royal')) return const Color(0xFF7851A9);
    
    // Use index-based fallback for guaranteed uniqueness among the list
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFB9F2FF), // Diamond Blue
      const Color(0xFFE0115F), // Ruby Red
      const Color(0xFF0F52BA), // Sapphire Blue
      const Color(0xFF7851A9), // Royal Purple
      const Color(0xFF50C878), // Emerald Green
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    return colors[index % colors.length];
  }
}
