import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../../home/view/home_view.dart';
import '../../account/view/account_view.dart';
import '../../../data/repository/membership_repo.dart';
import '../../membership/model/membership_tier.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends GetxController {
  final MembershipRepo membershipRepo = Get.find();

  var currentIndex = 0.obs;

  final pages = [
    HomeView(),
    const Center(
      child: Text('Membership Content'),
    ),
    const AccountView(),
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  var membershipTiers = <MembershipTier>[].obs;
  var isLoading = false.obs;

  Worker? _membershipPopupWorker;

  @override
  void onInit() {
    super.onInit();
    fetchMembershipTiers();
  }

  Future<void> fetchMembershipTiers() async {
    try {
      isLoading.value = true;

      final response =
          await membershipRepo.getMembershipPlans();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> tiersJson =
            data['tiers'] ?? [];

        membershipTiers.value = tiersJson
            .map(
              (t) => MembershipTier.fromJson(t),
            )
            .toList();
      }
    } catch (e) {
      print(
        'Error fetching tiers in dashboard: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();

    _membershipPopupWorker =
        ever<List<MembershipTier>>(
      membershipTiers,
      _showPopupWhenReady,
    );

    // The request can finish before onReady
    // registers the worker.
    _showPopupWhenReady(membershipTiers);
  }

  void _showPopupWhenReady(
    List<MembershipTier> tiers,
  ) {
    if (tiers.isNotEmpty &&
        !Get.isDialogOpen!) {
      _showClaimMembershipPopup(tiers);
    }
  }

  void _showClaimMembershipPopup(
    List<MembershipTier> tiers,
  ) {
    _showExactOfferPopup(tiers);
  }

  // ============================================================
  // ANNIVERSARY OFFER POPUP
  // ============================================================

  void _showExactOfferPopup(
    List<MembershipTier> tiers,
  ) {
    final oneRupeeTier = tiers.firstWhere(
      (tier) =>
          double.tryParse(
            tier.price.replaceAll(
              RegExp(r'[^0-9.]'),
              '',
            ),
          ) ==
          1,
      orElse: () => tiers.first,
    );

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog.fullscreen(
          backgroundColor: Colors.transparent,

          child: LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // ========================================================
                  // MAIN POPUP
                  //
                  // LEFT / RIGHT SAME
                  // HEIGHT SAME
                  // LIMITED TIME OFFER SAFE
                  // ========================================================

                  Positioned(
                    top: constraints.maxHeight * .45,

                    // OUTER LEFT-RIGHT SPACE
                    // SAME AS BEFORE
                    left: 10,
                    right: 10,

                    // Gives enough height for
                    // LIMITED TIME OFFER
                    bottom: 0,

                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),

                      child: GestureDetector(
                        behavior:
                            HitTestBehavior.opaque,

                        onTap: () {
                          Get.back();

                          Get.toNamed(
                            Routes.MEMBERSHIP_FORM,
                            arguments:
                                oneRupeeTier,
                          );
                        },

                        child: SizedBox.expand(
                          child: Image.asset(
                            'assets/images/membership_offer_popup.png',

                            width:
                                double.infinity,
                            height:
                                double.infinity,

                            // =============================================
                            // IMPORTANT FIX
                            //
                            // contain = left/right white strips
                            //
                            // cover = bottom crop ho sakta hai
                            //
                            // fill = poora container fill
                            //        + no left/right white strips
                            //        + LIMITED TIME OFFER visible
                            // =============================================

                            fit: BoxFit.fill,

                            alignment:
                                Alignment.topCenter,

                            filterQuality:
                                FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),

      barrierDismissible: false,
    );
  }

  // ============================================================
  // LEGACY CLAIM MEMBERSHIP POPUP
  // ============================================================

  void _showLegacyClaimMembershipPopup(
    List<MembershipTier> tiers,
  ) {
    final oneRupeeTier = tiers.firstWhere(
      (tier) =>
          double.tryParse(
            tier.price.replaceAll(
              RegExp(r'[^0-9.]'),
              '',
            ),
          ) ==
          1,
      orElse: () => tiers.first,
    );

    Get.dialog(
      PopScope(
        canPop: false,

        child: Dialog.fullscreen(
          backgroundColor: Colors.transparent,

          child: SafeArea(
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) =>
                  Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 24,
                  ),

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight *
                              .72,

                      maxHeight:
                          constraints.maxHeight *
                              .90,
                    ),

                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),

                      padding:
                          const EdgeInsets.fromLTRB(
                        18,
                        20,
                        18,
                        18,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF7FBFF,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          28,
                        ),

                        boxShadow: const [
                          BoxShadow(
                            color:
                                Color(
                              0x55000000,
                            ),
                            blurRadius: 24,
                            offset:
                                Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          // ==================================================
                          // LOGO
                          // ==================================================

                          Image.asset(
                            'assets/images/own-holiday-club-logo.png',
                            height: 38,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          // ==================================================
                          // UNLOCK OUR
                          // ==================================================

                          const Text(
                            'Unlock Our',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Color(
                                0xFF123D75,
                              ),
                            ),
                          ),

                          // ==================================================
                          // ANNIVERSARY
                          // ==================================================

                          const Text(
                            '14ᵗʰ Anniversary',
                            style: TextStyle(
                              fontSize: 30,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  Color(
                                0xFFE7B51D,
                              ),
                            ),
                          ),

                          // ==================================================
                          // SPECIAL OFFER
                          // ==================================================

                          const Text(
                            'Special Offer',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Color(
                                0xFF123D75,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          const Text(
                            'YOUR HOLIDAY JUST GOT BETTER',
                            style: TextStyle(
                              color:
                                  Color(
                                0xFF173E73,
                              ),
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // ==================================================
                          // MEMBERSHIP NAME
                          // ==================================================

                          Container(
                            width:
                                double.infinity,

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 9,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF0C4389,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                22,
                              ),

                              border:
                                  Border.all(
                                color:
                                    const Color(
                                  0xFFE7B51D,
                                ),
                                width: 2,
                              ),
                            ),

                            child: Text(
                              oneRupeeTier
                                  .name
                                  .toUpperCase(),

                              textAlign:
                                  TextAlign.center,

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // MEMBERSHIP FEE
                          // ==================================================

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .end,

                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    Text(
                                      'MEMBERSHIP FEE:',
                                      style:
                                          TextStyle(
                                        color:
                                            Color(
                                          0xFF123D75,
                                        ),
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    Text(
                                      '+ ADMIN FEE',
                                      style:
                                          TextStyle(
                                        color:
                                            Color(
                                          0xFF123D75,
                                        ),
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (oneRupeeTier
                                      .actuallyPrice !=
                                  null)
                                Text(
                                  '₹${oneRupeeTier.actuallyPrice}',

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.red,

                                    decoration:
                                        TextDecoration
                                            .lineThrough,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                              const SizedBox(
                                width: 5,
                              ),

                              Text(
                                '₹${oneRupeeTier.price}',

                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF123D75,
                                  ),
                                  fontSize: 32,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          // ==================================================
                          // FEATURES
                          // ==================================================

                          ...oneRupeeTier
                              .features
                              .take(5)
                              .map(
                            (feature) =>
                                Align(
                              alignment:
                                  Alignment
                                      .centerLeft,

                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 3,
                                ),

                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .check_circle,

                                      color:
                                          Color(
                                        0xFF073F86,
                                      ),

                                      size: 17,
                                    ),

                                    const SizedBox(
                                      width: 8,
                                    ),

                                    Expanded(
                                      child: Text(
                                        feature,

                                        style:
                                            const TextStyle(
                                          color:
                                              Color(
                                            0xFF173E73,
                                          ),
                                          fontSize:
                                              13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // LIMITED TIME OFFER
                          // DO NOT REMOVE
                          // ==================================================

                          Container(
                            width:
                                double.infinity,

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 7,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFFFC928,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                5,
                              ),
                            ),

                            child:
                                const Text(
                              '⌛ LIMITED TIME OFFER',

                              textAlign:
                                  TextAlign.center,

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF123D75,
                                ),

                                fontWeight:
                                    FontWeight
                                        .w900,

                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // ==================================================
                          // GET THIS OFFER
                          // ==================================================

                          SizedBox(
                            width:
                                double.infinity,

                            child:
                                ElevatedButton(
                              onPressed: () {
                                Get.back();

                                Get.toNamed(
                                  Routes
                                      .MEMBERSHIP_FORM,

                                  arguments:
                                      oneRupeeTier,
                                );
                              },

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF0C4389,
                                ),

                                foregroundColor:
                                    Colors.white,

                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 14,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    25,
                                  ),
                                ),
                              ),

                              child:
                                  const Text(
                                'GET THIS OFFER  →',

                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          // ==================================================
                          // DISCLAIMER
                          // ==================================================

                          const Text(
                            '₹1 is the membership fee. Applicable taxes and admin fee may apply.',

                            textAlign:
                                TextAlign.center,

                            style: TextStyle(
                              fontSize: 8,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      barrierDismissible: false,
    );
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _membershipPopupWorker?.dispose();
    super.onClose();
  }

  // ============================================================
  // PLAN COLORS
  // ============================================================

  Color getPlanColor(
    String? name,
    int index,
  ) {
    name = name?.toLowerCase() ?? '';

    if (name.contains('silver')) {
      return const Color(0xFFC0C0C0);
    }

    if (name.contains('gold')) {
      return const Color(0xFFFFD700);
    }

    if (name.contains('platinum')) {
      return const Color(0xFFB4E6FF);
    }

    if (name.contains('diamond')) {
      return const Color(0xFFB9F2FF);
    }

    if (name.contains('titanium')) {
      return const Color(0xFF636363);
    }

    if (name.contains('emerald')) {
      return const Color(0xFF50C878);
    }

    if (name.contains('ruby')) {
      return const Color(0xFFE0115F);
    }

    if (name.contains('sapphire')) {
      return const Color(0xFF0F52BA);
    }

    if (name.contains('purple') ||
        name.contains('royal')) {
      return const Color(0xFF7851A9);
    }

    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFB9F2FF),
      const Color(0xFFE0115F),
      const Color(0xFF0F52BA),
      const Color(0xFF7851A9),
      const Color(0xFF50C878),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return colors[
      index % colors.length
    ];
  }
}