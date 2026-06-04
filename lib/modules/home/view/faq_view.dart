import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/home_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final HomeController controller = Get.find<HomeController>();

  // Fallback default FAQs matching the website when API returns empty list
  final List<Map<String, String>> _defaultFaqs = const [
    {
      'question': 'How does the vacation membership work?',
      'answer': 'Our vacation membership gives you access to a curated network of luxury resorts and properties worldwide. Once enrolled, you receive an annual credit allocation that can be used to book stays, experiences, and exclusive member benefits at participating destinations.',
    },
    {
      'question': 'Can I transfer my membership to my children?',
      'answer': 'Yes — our memberships are fully inheritable. You can transfer ownership to your children or designated beneficiaries at any time through a simple documentation process, ensuring your family continues to enjoy the benefits for generations.',
    },
    {
      'question': 'What happens if I don\'t use my credits this year?',
      'answer': 'Unused credits roll over to the following year — we never want you to lose what you\'ve earned. Credits are valid for up to 24 months, giving you complete flexibility to plan your ideal vacation on your own schedule.',
    },
    {
      'question': 'Are there any hidden maintenance fees?',
      'answer': 'Absolutely none. We believe in complete transparency. Your annual membership fee covers everything — property maintenance, concierge access, and platform services. The price you see is exactly what you pay, with no surprises.',
    },
    {
      'question': 'How do I book a property as a member?',
      'answer': 'Booking is seamless through our member portal or dedicated concierge line. Simply select your preferred destination, dates, and room type. Members receive priority booking windows — often 12 months in advance — ensuring you always get the best availability.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Hit FAQ API and log to terminal on page entry
    controller.fetchFaqs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: AppColors.primaryBlack,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryBlack, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Banner Section
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HAVE QUESTIONS?',
                  style: GoogleFonts.montserrat(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryYellow,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Frequently Asked Questions',
                  style: GoogleFonts.montserrat(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // FAQ List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryYellow,
              onRefresh: () => controller.fetchFaqs(),
              child: Obx(() {
              if (controller.isLoading.value && controller.faqs.isEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: 6,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Skeleton(height: 60, borderRadius: 12.0),
                  ),
                );
              }

              final List<dynamic> faqList = controller.faqs.isNotEmpty ? controller.faqs : _defaultFaqs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: faqList.length,
                itemBuilder: (context, index) {
                  final faq = Map<String, dynamic>.from(faqList[index]);
                  return FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderGrey.withOpacity(0.6), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.softYellow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.question_answer_outlined,
                                size: 16,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                            title: Text(
                              faq['question'] ?? faq['q'] ?? '',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.0,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            iconColor: AppColors.primaryYellow,
                            collapsedIconColor: AppColors.greyText,
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.softYellow.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryYellow.withOpacity(0.15),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  faq['answer'] ?? faq['a'] ?? '',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.0,
                                    color: AppColors.primaryBlack.withOpacity(0.95),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            ),  // RefreshIndicator
          ),
        ],
      ),
    );
  }
}
