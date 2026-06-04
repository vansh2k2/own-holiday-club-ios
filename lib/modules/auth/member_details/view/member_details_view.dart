import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import '../controller/member_details_controller.dart';
import '../../login/model/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_holiday_app/widgets/skeleton.dart';
import 'package:own_holiday_app/modules/home/controller/home_controller.dart';
import 'package:own_holiday_app/modules/account/controller/account_controller.dart';
import 'book_holiday_view.dart';

// ─────────────────────────────────────────────
//  MAIN MEMBER DETAILS VIEW
// ─────────────────────────────────────────────
class MemberDetailsView extends GetView<MemberDetailsController> {
  const MemberDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.offAllNamed(Routes.DASHBOARD);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: Obx(() {
          final u = controller.user.value;
          if (u == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            );
          }
          return RefreshIndicator(
            color: AppColors.primaryYellow,
            onRefresh: () => Get.find<AccountController>().fetchProfile(),
            child: CustomScrollView(
              slivers: [
                _buildSliverHeader(context, u),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      children: [
                        FadeInUp(delay: const Duration(milliseconds: 100), child: _buildMembershipBanner(u)),
                        const SizedBox(height: 20),
                        FadeInUp(delay: const Duration(milliseconds: 150), child: _buildAccordionMenuSection(u)),
                        const SizedBox(height: 24),
                        FadeInUp(delay: const Duration(milliseconds: 200), child: _buildSignOutButton()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── SLIVER HEADER (Premium Light Color Theme) ──────────────────────────
  Widget _buildSliverHeader(BuildContext context, UserModel u) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryBlack, size: 18),
        onPressed: () => Get.offAllNamed(Routes.DASHBOARD),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderContent(u),
      ),
    );
  }

  Widget _buildHeaderContent(UserModel u) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryYellow.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -20, left: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlack.withOpacity(0.02),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryYellow, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      backgroundImage: u.profileImage != null
                          ? CachedNetworkImageProvider(u.profileImage!)
                          : null,
                      child: u.profileImage == null
                          ? const Icon(Icons.person, size: 36, color: AppColors.primaryYellow)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (u.name ?? 'Member').toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: AppColors.primaryBlack,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                u.membershipId ?? 'N/A',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.primaryBlack,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildHeaderChip(Icons.phone_rounded, u.mobile ?? 'N/A'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.greyText, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.montserrat(
            color: AppColors.primaryBlack, 
            fontSize: 13.0, 
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }

  // ── MEMBERSHIP BANNER (Premium Gold Theme) ──────────────────────
  Widget _buildMembershipBanner(UserModel u) {
    final m = u.membership;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFDF2), Color(0xFFFFF9E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromRGBO(27, 31, 35, 0.15),
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryYellow, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m?.name?.toUpperCase() ?? 'OHC PRIVILEGE',
                  style: GoogleFonts.montserrat(
                    color: AppColors.primaryBlack,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Valid till: ${m?.validUntil ?? 'N/A'}',
                  style: GoogleFonts.montserrat(
                    color: AppColors.greyText, 
                    fontSize: 12.0, 
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getStatusColor(m?.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getStatusColor(m?.status).withOpacity(0.3)),
            ),
            child: Text(
              m?.status?.toUpperCase() ?? 'ACTIVE',
              style: GoogleFonts.montserrat(
                color: _getStatusColor(m?.status),
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active': return AppColors.primaryYellow;
      case 'expired': return AppColors.brownAccent;
      case 'pending': return AppColors.primaryYellow;
      default: return AppColors.primaryYellow;
    }
  }

  // ── INLINE ACCORDION MENU SECTION (No routing!) ───────────────────────────
  Widget _buildAccordionMenuSection(UserModel u) {
    return Column(
      children: [
        _buildAccordionItem(
          index: 0,
          icon: Icons.person_outline_rounded,
          label: 'Personal Info',
          subtitle: 'Profile, address, documents',
          color: const Color(0xFF6366F1),
          child: _buildPersonalInfoContent(u),
        ),
        _buildAccordionItem(
          index: 1,
          icon: Icons.card_membership_rounded,
          label: 'Membership Details',
          subtitle: '${u.membership?.name ?? 'OHC'} • ${u.membership?.nightsPerYear ?? 'N/A'}',
          color: const Color(0xFFF59E0B),
          child: _buildMembershipContent(u),
        ),
        _buildAccordionItem(
          index: 2,
          icon: Icons.flight_takeoff_rounded,
          label: 'Book Holiday',
          subtitle: '${u.holidayBookings?.length ?? 0} trips used',
          color: const Color(0xFF10B981),
          child: const SizedBox.shrink(),
          onTap: () => Get.to(() => BookHolidayView(user: u)),
        ),
        _buildAccordionItem(
          index: 3,
          icon: Icons.receipt_long_rounded,
          label: 'Payment Details',
          subtitle: '${u.payments?.length ?? 0} transactions',
          color: const Color(0xFF3B82F6),
          child: _buildPaymentsContent(u),
        ),
        _buildAccordionItem(
          index: 4,
          icon: Icons.help_outline_rounded,
          label: 'Help & FAQ',
          subtitle: 'Common questions & support',
          color: const Color(0xFF8B5CF6),
          child: _buildFaqContent(),
        ),
      ],
    );
  }

  Widget _buildAccordionItem({
    required int index,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Obx(() {
      final isExpanded = controller.expandedSection.value == index;
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey.withOpacity(0.4), width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color.fromRGBO(27, 31, 35, 0.15),
              offset: Offset(0, 0),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap ?? () => controller.toggleSection(index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.montserrat(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: GoogleFonts.montserrat(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4F5F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.greyText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: child,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  // ── 1. PERSONAL INFO SECTION CONTENT ──
  Widget _buildPersonalInfoContent(UserModel u) {
    return Column(
      children: [
        _buildInfoCard('Basic Details', Icons.person_outline_rounded, const Color(0xFF6366F1), [
          _InfoRow('Full Name', u.name),
          _InfoRow('Mobile', u.mobile),
          _InfoRow('Email', u.email),
          _InfoRow('Gender', u.gender),
          _InfoRow('Date of Birth', u.dob),
          _InfoRow('Marital Status', u.maritalStatus),
          _InfoRow('Anniversary', u.anniversary),
          _InfoRow('Occupation', u.occupation),
        ]),
        if (u.residenceAddress != null) ...[
          const SizedBox(height: 14),
          _buildInfoCard('Residence Address', Icons.home_rounded, const Color(0xFF10B981), [
            _InfoRow('House/Flat No', u.residenceAddress?.houseNo),
            _InfoRow('Address', u.residenceAddress?.addressLine),
            _InfoRow('City', u.residenceAddress?.city),
            _InfoRow('State', u.residenceAddress?.state),
            _InfoRow('Country', u.residenceAddress?.country),
            _InfoRow('PIN Code', u.residenceAddress?.pin),
            _InfoRow('Phone', u.residenceAddress?.phone),
          ]),
        ],
        if (u.officeAddress != null) ...[
          const SizedBox(height: 14),
          _buildInfoCard('Office Address', Icons.business_rounded, const Color(0xFF8B5CF6), [
            _InfoRow('Building/Office', u.officeAddress?.houseNo),
            _InfoRow('Address', u.officeAddress?.addressLine),
            _InfoRow('City', u.officeAddress?.city),
            _InfoRow('State', u.officeAddress?.state),
            _InfoRow('Country', u.officeAddress?.country),
            _InfoRow('PIN Code', u.officeAddress?.pin),
          ]),
        ],
        const SizedBox(height: 14),
        _buildDocCard(u),
      ],
    );
  }

  Widget _buildDocCard(UserModel u) {
    return _PageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader('Verified Documents', Icons.verified_user_rounded, const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _DocTile('ID Proof', u.documents?.idProofType, u.documents?.idProofUrl)),
              const SizedBox(width: 12),
              Expanded(child: _DocTile('Address Proof', u.documents?.addressProofType, u.documents?.addressProofUrl)),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. MEMBERSHIP SECTION CONTENT ──
  Widget _buildMembershipContent(UserModel u) {
    final m = u.membership;
    return Column(
      children: [
        // Member Card in Light Gold theme
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFDF0), Color(0xFFFFF4D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryYellow.withOpacity(0.6), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.02),
                offset: Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color.fromRGBO(27, 31, 35, 0.15),
                offset: Offset(0, 0),
                blurRadius: 0,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PREMIUM MEMBER', 
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryBlack, 
                      fontSize: 12.0, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 2
                    ),
                  ),
                  const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryYellow, size: 24),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                m?.name?.toUpperCase() ?? 'OHC PRIVILEGE', 
                style: GoogleFonts.montserrat(color: AppColors.primaryBlack, fontSize: 16.0, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 4),
              Text(
                u.membershipId ?? 'N/A', 
                style: GoogleFonts.montserrat(color: AppColors.greyText, fontSize: 12.0, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _MemberStat('STATUS', m?.status ?? 'Active'),
                  const SizedBox(width: 24),
                  _MemberStat('VALID TILL', m?.validUntil ?? 'N/A'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard('Membership Details', Icons.card_membership_rounded, const Color(0xFFF59E0B), [
          _InfoRow('Plan Name', m?.name),
          _InfoRow('Status', m?.status),
          _InfoRow('Valid Until', m?.validUntil),
          _InfoRow('Purchased On', m?.purchasedAt),
          _InfoRow('Duration', m?.duration),
          _InfoRow('Period', m?.period),
          _InfoRow('Base Years', m?.baseDurationYears?.toString()),
          _InfoRow('Bonus Years', m?.bonusYears?.toString()),
          _InfoRow('Total Years', m?.totalDurationYears?.toString()),
          _InfoRow('Nights / Year', m?.nightsPerYear),
          _InfoRow('Price', m?.price != null ? '₹${m!.price}' : null),
        ]),
      ],
    );
  }

  // ── 3. HOLIDAY BOOKINGS SECTION CONTENT ──
  Widget _buildHolidayBookingsContent(UserModel u) {
    final totalSlots = u.membership?.totalDurationYears ?? 5;
    final bookings = u.holidayBookings ?? [];
    final startDate = u.membership?.purchasedAt != null
        ? DateTime.tryParse(u.membership!.purchasedAt!) ?? DateTime.now()
        : DateTime.now();

    return Column(
      children: [
        // Stats row
        Row(
          children: [
            _StatBox('TOTAL', totalSlots, Colors.blue),
            const SizedBox(width: 10),
            _StatBox('USED', bookings.length, AppColors.primaryYellow),
            const SizedBox(width: 10),
            _StatBox('LEFT', totalSlots - bookings.length, AppColors.primaryYellow),
          ],
        ),
        const SizedBox(height: 18),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalSlots,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final slot = i + 1;
            final from = DateTime(startDate.year + i, startDate.month, startDate.day);
            final to = DateTime(startDate.year + i + 1, startDate.month, startDate.day);
            final booking = bookings.firstWhereOrNull((b) => b.slotNumber == slot);
            final hasActive = bookings.any((b) => b.status != 'cancelled' && b.status != 'completed');
            final isAvailable = booking == null && !hasActive && slot == _firstUnbooked(u);

            return _TripCard(
              slot: slot,
              from: from,
              to: to,
              booking: booking,
              isAvailable: isAvailable,
              ctrl: controller,
            );
          },
        ),
      ],
    );
  }

  int _firstUnbooked(UserModel u) {
    for (int i = 1; i <= 30; i++) {
      if (u.holidayBookings?.any((b) => b.slotNumber == i) != true) return i;
    }
    return 1;
  }

  // ── 4. PAYMENTS SECTION CONTENT ──
  Widget _buildPaymentsContent(UserModel u) {
    final payments = u.payments ?? [];
    if (payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: _EmptyState('No payment records found', Icons.receipt_long_outlined),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final p = payments[i];
        return _PageCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.membershipTierName ?? 'OHC Privilege',
                          style: GoogleFonts.montserrat(fontSize: 13.0, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.paymentId ?? 'N/A',
                          style: GoogleFonts.montserrat(fontSize: 11.0, color: AppColors.greyText, fontWeight: FontWeight.w500)
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${p.amount ?? '0'}',
                    style: GoogleFonts.montserrat(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 14),
              _PayRow('Status', p.status?.toUpperCase() ?? 'N/A', isStatus: true, statusOk: p.status?.toLowerCase() == 'captured'),
              _PayRow('Method', p.method?.toUpperCase() ?? 'N/A'),
              _PayRow('Date', p.paidAt != null ? _fmtDate(p.paidAt) : 'N/A'),
              if (p.bank != null && p.bank!.isNotEmpty) _PayRow('Bank', p.bank!),
              if (p.wallet != null && p.wallet!.isNotEmpty) _PayRow('Wallet', p.wallet!),
              _PayRow('Period', p.period ?? 'N/A'),
            ],
          ),
        );
      },
    );
  }

  // ── 5. HELP & FAQ SECTION CONTENT ──
  Widget _buildFaqContent() {
    final homeCtrl = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    // Default FAQs matching the website fallback
    const defaultFaqs = [
      {'question': 'How does the vacation membership work?', 'answer': 'Our vacation membership gives you access to a curated network of luxury resorts and properties worldwide. Once enrolled, you receive an annual credit allocation that can be used to book stays, experiences, and exclusive member benefits at participating destinations.'},
      {'question': 'Can I transfer my membership to my children?', 'answer': 'Yes — our memberships are fully inheritable. You can transfer ownership to your children or designated beneficiaries at any time through a simple documentation process, ensuring your family continues to enjoy the benefits for generations.'},
      {'question': "What happens if I don't use my credits this year?", 'answer': "Unused credits roll over to the following year — we never want you to lose what you've earned. Credits are valid for up to 24 months, giving you complete flexibility to plan your ideal vacation on your own schedule."},
      {'question': 'Are there any hidden maintenance fees?', 'answer': 'Absolutely none. We believe in complete transparency. Your annual membership fee covers everything — property maintenance, concierge access, and platform services. The price you see is exactly what you pay, with no surprises.'},
      {'question': 'How do I book a property as a member?', 'answer': 'Booking is seamless through our member portal or dedicated concierge line. Simply select your preferred destination, dates, and room type. Members receive priority booking windows — often 12 months in advance — ensuring you always get the best availability.'},
    ];

    // Trigger FAQ fetch when this section is rendered
    homeCtrl.fetchFaqs();

    return Obx(() {
      if (homeCtrl.isLoading.value && homeCtrl.faqs.isEmpty) {
        return Column(
          children: List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 55, borderRadius: 12.0),
            ),
          ),
        );
      }

      final List<Map<String, String>> faqList = homeCtrl.faqs.isNotEmpty
          ? homeCtrl.faqs.map((f) => {'question': f['question']?.toString() ?? '', 'answer': f['answer']?.toString() ?? ''}).toList()
          : defaultFaqs;

      return Column(
        children: faqList.map((faq) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.02),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color.fromRGBO(27, 31, 35, 0.15),
                  offset: Offset(0, 0),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Theme(
              data: ThemeData(
                dividerColor: Colors.transparent,
                colorScheme: const ColorScheme.light(primary: AppColors.primaryYellow),
              ),
              child: ExpansionTile(
                title: Text(
                  faq['question'] ?? '',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                    color: AppColors.primaryBlack,
                  ),
                ),
                iconColor: AppColors.primaryYellow,
                collapsedIconColor: AppColors.greyText,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softYellow.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      faq['answer'] ?? '',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.0,
                        color: AppColors.primaryBlack,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ── SIGN OUT ───────────────────────────────
  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () => controller.logout(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.brownAccent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.brownAccent.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.brownAccent, size: 18),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: GoogleFonts.montserrat(
                color: AppColors.brownAccent,
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED HELPERS & COMPONENTS
// ─────────────────────────────────────────────

/// Tries to parse common date strings (ISO 8601, dd-MM-yyyy, etc.)
/// and returns them in compact Indian format: 12 Jun 2025
/// If not a date, returns the original string unchanged.
String _fmtDate(String? raw) {
  if (raw == null || raw.isEmpty) return raw ?? '';
  try {
    final d = DateTime.parse(raw);
    return DateFormat('dd MMM yyyy').format(d);
  } catch (_) {
    // try dd-MM-yyyy or dd/MM/yyyy
    for (final fmt in ['dd-MM-yyyy', 'dd/MM/yyyy', 'MM/dd/yyyy']) {
      try {
        final d = DateFormat(fmt).parseStrict(raw);
        return DateFormat('dd MMM yyyy').format(d);
      } catch (_) {}
    }
    return raw; // not a date, return as-is
  }
}

Widget _buildInfoCard(String title, IconData icon, Color color, List<_InfoRow> rows) {
  return _PageCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardHeader(title, icon, color),
        const SizedBox(height: 14),
        ...rows.map((r) => _InfoRowWidget(r)),
      ],
    ),
  );
}

class _PageCard extends StatelessWidget {
  final Widget child;
  const _PageCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.4), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromRGBO(27, 31, 35, 0.15),
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _CardHeader(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title, 
          style: GoogleFonts.montserrat(
            fontSize: 13.0, 
            fontWeight: FontWeight.bold, 
            color: AppColors.primaryBlack
          )
        ),
      ],
    );
  }
}

class _InfoRow {
  final String label;
  final String? value;
  const _InfoRow(this.label, this.value);
}

class _InfoRowWidget extends StatelessWidget {
  final _InfoRow row;
  const _InfoRowWidget(this.row, {super.key});

  @override
  Widget build(BuildContext context) {
    if (row.value == null || row.value!.isEmpty) return const SizedBox.shrink();
    final displayValue = _fmtDate(row.value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              row.label, 
              style: GoogleFonts.montserrat(
                fontSize: 12.0, 
                color: AppColors.greyText, 
                fontWeight: FontWeight.w500
              )
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayValue,
              style: GoogleFonts.montserrat(
                fontSize: 12.0, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primaryBlack
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final String label;
  final String? type;
  final String? url;
  const _DocTile(this.label, this.type, this.url);

  @override
  Widget build(BuildContext context) {
    final hasDoc = url != null && url!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasDoc ? const Color(0xFFE2E8F0) : const Color(0xFFFEE2E2)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromRGBO(27, 31, 35, 0.15),
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasDoc ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasDoc ? Icons.verified_user_rounded : Icons.error_outline_rounded,
              color: hasDoc ? AppColors.primaryYellow : AppColors.brownAccent,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            style: GoogleFonts.montserrat(fontSize: 12.0, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)
          ),
          const SizedBox(height: 2),
          Text(
            type ?? (hasDoc ? 'Verified' : 'Missing'),
            style: GoogleFonts.montserrat(fontSize: 11.0, color: AppColors.greyText, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 12),
          if (hasDoc)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showPreview(context, url!),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'VIEW PREVIEW', 
                  style: GoogleFonts.montserrat(
                    fontSize: 11.0, 
                    fontWeight: FontWeight.bold, 
                    color: const Color(0xFF6366F1)
                  )
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPreview(BuildContext context, String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) => Skeleton(),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.white,
                  child: const Center(child: Icon(Icons.error_outline, size: 40, color: AppColors.greyText)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final int slot;
  final DateTime from, to;
  final BookingModel? booking;
  final bool isAvailable;
  final MemberDetailsController ctrl;
  const _TripCard({
    required this.slot, required this.from, required this.to,
    required this.booking, required this.isAvailable, required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final b = booking;
    return _PageCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$slot', 
                        style: GoogleFonts.montserrat(color: AppColors.primaryYellow, fontSize: 13.0, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slot $slot – Year ${from.year}', 
                        style: GoogleFonts.montserrat(fontSize: 12.0, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${df.format(from)} → ${df.format(to)}',
                        style: GoogleFonts.montserrat(fontSize: 11.0, color: AppColors.greyText, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ],
              ),
              if (b != null)
                _StatusChip(b.status ?? 'pending')
              else if (isAvailable)
                Obx(() => ElevatedButton(
                  onPressed: ctrl.isBooking.value ? null : () => _showHolidayBookingForm(context, slot, from.year),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Activate', 
                    style: GoogleFonts.montserrat(fontSize: 11.0, fontWeight: FontWeight.bold)
                  ),
                ))
              else
                _StatusChip('locked'),
            ],
          ),
          if (b != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            Row(
              children: [
                if (b.place != null) ...[
                  const Icon(Icons.location_on_rounded, color: AppColors.primaryYellow, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    b.place!, 
                    style: GoogleFonts.montserrat(fontSize: 12.0, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(width: 16),
                ],
                if (b.adults != null) ...[
                  const Icon(Icons.people_rounded, color: AppColors.greyText, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    '${b.adults} Adults${b.kids != null && b.kids! > 0 ? ', ${b.kids} Kids' : ''}',
                    style: GoogleFonts.montserrat(fontSize: 12.0, color: AppColors.greyText, fontWeight: FontWeight.w500)
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (status.toLowerCase()) {
      case 'confirmed': c = AppColors.primaryYellow; break;
      case 'pending': c = AppColors.primaryYellow; break;
      case 'cancelled': c = AppColors.brownAccent; break;
      case 'completed': c = Colors.blue; break;
      case 'locked': c = AppColors.greyText; break;
      default: c = AppColors.greyText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(), 
        style: GoogleFonts.montserrat(color: c, fontSize: 11.0, fontWeight: FontWeight.bold)
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey.withOpacity(0.4), width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color.fromRGBO(27, 31, 35, 0.15),
              offset: Offset(0, 0),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$value', 
              style: GoogleFonts.montserrat(fontSize: 16.0, fontWeight: FontWeight.bold, color: color)
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: GoogleFonts.montserrat(fontSize: 12.0, color: AppColors.greyText, fontWeight: FontWeight.w600)
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberStat extends StatelessWidget {
  final String label;
  final String value;
  const _MemberStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.montserrat(
            color: AppColors.greyText, 
            fontSize: 11.0, 
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 3),
        Text(
          value, 
          style: GoogleFonts.montserrat(
            color: AppColors.primaryBlack, 
            fontSize: 13.0, 
            fontWeight: FontWeight.bold
          )
        ),
      ],
    );
  }
}

class _PayRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  final bool statusOk;
  const _PayRow(this.label, this.value, {this.isStatus = false, this.statusOk = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: GoogleFonts.montserrat(fontSize: 12.0, color: AppColors.greyText, fontWeight: FontWeight.w500)
          ),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: GoogleFonts.montserrat(
                      fontSize: 11.0, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.primaryYellow
                    ),
                  ),
                )
              : Text(
                  value, 
                  style: GoogleFonts.montserrat(fontSize: 12.0, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)
                ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState(this.message, this.icon);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.borderGrey),
          const SizedBox(height: 12),
          Text(
            message, 
            style: GoogleFonts.montserrat(color: AppColors.greyText, fontSize: 12.0, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }
}

void _showHolidayBookingForm(BuildContext context, int slot, int year) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _HolidayBookingSheet(slot: slot, year: year),
  );
}

class _HolidayBookingSheet extends StatefulWidget {
  final int slot;
  final int year;
  const _HolidayBookingSheet({required this.slot, required this.year});

  @override
  State<_HolidayBookingSheet> createState() => _HolidayBookingSheetState();
}

class _HolidayBookingSheetState extends State<_HolidayBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _msgCtrl = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 2;
  int _kids = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.borderGrey, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Activate Slot ${widget.slot}',
                style: GoogleFonts.montserrat(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
              ),
              const SizedBox(height: 6),
              Text(
                'Plan your holiday for year ${widget.year}. Our team will contact you to confirm the booking.',
                style: GoogleFonts.montserrat(fontSize: 12.0, color: AppColors.greyText, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: _buildDateField('Check-in', _checkIn, (d) => setState(() => _checkIn = d))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateField('Check-out', _checkOut, (d) => setState(() => _checkOut = d))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCounter('Adults', _adults, (v) => setState(() => _adults = v))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCounter('Kids', _kids, (v) => setState(() => _kids = v))),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _msgCtrl,
                maxLines: 3,
                style: GoogleFonts.montserrat(fontSize: 12.0, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Preferred Destination or special requests...',
                  hintStyle: GoogleFonts.montserrat(fontSize: 12.0, color: AppColors.greyText, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('SUBMIT ACTIVATION REQUEST', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        if (d != null) onSelect(d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.greyText),
            const SizedBox(width: 10),
            Text(
              date == null ? label : DateFormat('dd/MM/yy').format(date),
              style: GoogleFonts.montserrat(fontSize: 12.0, color: date == null ? AppColors.greyText : AppColors.primaryBlack, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int val, Function(int) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12.0, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
          Row(
            children: [
              InkWell(onTap: () => val > 0 ? onChange(val - 1) : null, child: const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.greyText)),
              const SizedBox(width: 10),
              Text(val.toString(), style: GoogleFonts.montserrat(fontSize: 12.0, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              InkWell(onTap: () => onChange(val + 1), child: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF10B981))),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_checkIn == null || _checkOut == null) {
      Get.snackbar('Required', 'Please select check-in and check-out dates.', backgroundColor: AppColors.primaryYellow, colorText: Colors.white);
      return;
    }

    setState(() => _isSubmitting = true);
    final ctrl = Get.find<MemberDetailsController>();
    
    final payload = {
      'name': ctrl.user.value?.name ?? 'Member',
      'email': ctrl.user.value?.email ?? '',
      'phone': ctrl.user.value?.mobile ?? '',
      'checkIn': _checkIn!.toIso8601String(),
      'checkOut': _checkOut!.toIso8601String(),
      'adults': _adults,
      'kids': _kids,
      'message': _msgCtrl.text,
      'contextType': 'membership-slot',
      'contextName': 'Slot ${widget.slot} - Year ${widget.year}',
      'source': 'app-member-panel',
    };

    try {
      final errorMessage = await ctrl.submitHolidayActivation(payload);
      if (errorMessage == null) {
        Get.back();
        Get.snackbar(
          'Success',
          'Activation request submitted! Our concierge will contact you shortly.',
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF15803D),
          icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF15803D)),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Booking Failed',
          errorMessage,
          backgroundColor: const Color(0xFFFEE2E2),
          colorText: const Color(0xFFB91C1C),
          icon: const Icon(Icons.error_outline_rounded, color: Color(0xFFB91C1C)),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.', backgroundColor: AppColors.brownAccent, colorText: Colors.white);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}