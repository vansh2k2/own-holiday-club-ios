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
        backgroundColor: const Color(0xFFF4F5F7),
        body: Obx(() {
          final u = controller.user.value;
          if (u == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            );
          }
          return CustomScrollView(
            slivers: [
              _buildSliverHeader(context, u),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      FadeInUp(delay: const Duration(milliseconds: 100), child: _buildMembershipBanner(u)),
                      const SizedBox(height: 16),
                      FadeInUp(delay: const Duration(milliseconds: 150), child: _buildMenuSection(u)),
                      const SizedBox(height: 24),
                      FadeInUp(delay: const Duration(milliseconds: 200), child: _buildSignOutButton()),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── SLIVER HEADER ──────────────────────────
  Widget _buildSliverHeader(BuildContext context, UserModel u) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primaryBlack,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        onPressed: () => Get.offAllNamed(Routes.DASHBOARD),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_outlined, color: AppColors.primaryYellow, size: 16),
          ),
          onPressed: () {
            Get.snackbar('Notice', 'Profile editing will be available soon.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.primaryYellow,
                colorText: AppColors.primaryBlack);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderContent(u),
      ),
    );
  }

  Widget _buildHeaderContent(UserModel u) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBlack,
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
                color: AppColors.primaryYellow.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
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
                      radius: 38,
                      backgroundColor: Colors.grey[900],
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
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                u.membershipId ?? 'N/A',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.primaryBlack,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
        Icon(icon, color: Colors.white54, size: 11),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ── MEMBERSHIP BANNER ──────────────────────
  Widget _buildMembershipBanner(UserModel u) {
    final m = u.membership;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryYellow, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m?.name?.toUpperCase() ?? 'OHC PRIVILEGE',
                  style: GoogleFonts.montserrat(
                    color: AppColors.primaryYellow,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Valid till: ${m?.validUntil ?? 'N/A'}',
                  style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500),
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
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active': return Colors.greenAccent;
      case 'expired': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.greenAccent;
    }
  }

  // ── 5 MENU ITEMS ───────────────────────────
  Widget _buildMenuSection(UserModel u) {
    final items = [
      _MenuItem(
        icon: Icons.person_outline_rounded,
        label: 'Personal Info',
        subtitle: 'Profile, address, documents',
        color: const Color(0xFF6366F1),
        onTap: () => Get.to(() => PersonalInfoPage(u: u)),
      ),
      _MenuItem(
        icon: Icons.card_membership_rounded,
        label: 'Membership',
        subtitle: '${u.membership?.name ?? 'OHC'} • ${u.membership?.nightsPerYear ?? 'N/A'}',
        color: const Color(0xFFF59E0B),
        onTap: () => Get.to(() => MembershipPage(u: u)),
      ),
      _MenuItem(
        icon: Icons.flight_takeoff_rounded,
        label: 'Book Holiday',
        subtitle: '${u.holidayBookings?.length ?? 0} trips used',
        color: const Color(0xFF10B981),
        onTap: () => Get.to(() => HolidayBookingsPage(u: u, ctrl: controller)),
      ),
      _MenuItem(
        icon: Icons.receipt_long_rounded,
        label: 'Payment Details',
        subtitle: '${u.payments?.length ?? 0} transactions',
        color: const Color(0xFF3B82F6),
        onTap: () => Get.to(() => PaymentsPage(u: u)),
      ),
      _MenuItem(
        icon: Icons.help_outline_rounded,
        label: 'Help & FAQ',
        subtitle: 'Common questions & support',
        color: const Color(0xFF8B5CF6),
        onTap: () => Get.toNamed(Routes.FAQ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildMenuTile(item),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 60, endIndent: 0, color: Color(0xFFF1F5F9)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SIGN OUT ───────────────────────────────
  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () => controller.logout(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.red, size: 16),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: GoogleFonts.montserrat(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PAGE 1: PERSONAL INFO
// ─────────────────────────────────────────────
class PersonalInfoPage extends StatelessWidget {
  final UserModel u;
  const PersonalInfoPage({super.key, required this.u});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar('Personal Profile', const Color(0xFF6366F1)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FadeInUp(child: _buildInfoCard('Basic Details', Icons.person_outline_rounded, const Color(0xFF6366F1), [
              _InfoRow('Full Name', u.name),
              _InfoRow('Mobile', u.mobile),
              _InfoRow('Email', u.email),
              _InfoRow('Gender', u.gender),
              _InfoRow('Date of Birth', u.dob),
              _InfoRow('Marital Status', u.maritalStatus),
              _InfoRow('Anniversary', u.anniversary),
              _InfoRow('Occupation', u.occupation),
            ])),
            const SizedBox(height: 16),
            if (u.residenceAddress != null)
              FadeInUp(delay: const Duration(milliseconds: 100), child: _buildInfoCard('Residence Address', Icons.home_rounded, const Color(0xFF10B981), [
                _InfoRow('House/Flat No', u.residenceAddress?.houseNo),
                _InfoRow('Address', u.residenceAddress?.addressLine),
                _InfoRow('City', u.residenceAddress?.city),
                _InfoRow('State', u.residenceAddress?.state),
                _InfoRow('Country', u.residenceAddress?.country),
                _InfoRow('PIN Code', u.residenceAddress?.pin),
                _InfoRow('Phone', u.residenceAddress?.phone),
              ])),
            if (u.officeAddress != null) ...[
              const SizedBox(height: 16),
              FadeInUp(delay: const Duration(milliseconds: 200), child: _buildInfoCard('Office Address', Icons.business_rounded, const Color(0xFF8B5CF6), [
                _InfoRow('Building/Office', u.officeAddress?.houseNo),
                _InfoRow('Address', u.officeAddress?.addressLine),
                _InfoRow('City', u.officeAddress?.city),
                _InfoRow('State', u.officeAddress?.state),
                _InfoRow('Country', u.officeAddress?.country),
                _InfoRow('PIN Code', u.officeAddress?.pin),
              ])),
            ],
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 300), child: _buildDocCard(u)),
            const SizedBox(height: 80),
          ],
        ),
      ),
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
}

// ─────────────────────────────────────────────
//  PAGE 2: MEMBERSHIP
// ─────────────────────────────────────────────
class MembershipPage extends StatelessWidget {
  final UserModel u;
  const MembershipPage({super.key, required this.u});

  @override
  Widget build(BuildContext context) {
    final m = u.membership;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: _buildAppBar('Membership', const Color(0xFFF59E0B)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PREMIUM MEMBER', style: GoogleFonts.montserrat(color: AppColors.primaryYellow, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 2)),
                        const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryYellow, size: 22),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(m?.name?.toUpperCase() ?? 'OHC PRIVILEGE', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(u.membershipId ?? 'N/A', style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12)),
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
            ),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 100), child: _buildInfoCard('Membership Details', Icons.card_membership_rounded, const Color(0xFFF59E0B), [
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
            ])),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PAGE 3: HOLIDAY BOOKINGS
// ─────────────────────────────────────────────
class HolidayBookingsPage extends StatelessWidget {
  final UserModel u;
  final MemberDetailsController ctrl;
  const HolidayBookingsPage({super.key, required this.u, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final totalSlots = u.membership?.totalDurationYears ?? 5;
    final bookings = u.holidayBookings ?? [];
    final startDate = u.membership?.purchasedAt != null
        ? DateTime.tryParse(u.membership!.purchasedAt!) ?? DateTime.now()
        : DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: _buildAppBar('Book Holiday', const Color(0xFF10B981)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats row
            FadeInDown(
              child: Row(
                children: [
                  _StatBox('TOTAL', totalSlots, Colors.blue),
                  const SizedBox(width: 10),
                  _StatBox('USED', bookings.length, Colors.green),
                  const SizedBox(width: 10),
                  _StatBox('LEFT', totalSlots - bookings.length, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 20),
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

                return FadeInUp(
                  delay: Duration(milliseconds: i * 60),
                  child: _TripCard(
                    slot: slot,
                    from: from,
                    to: to,
                    booking: booking,
                    isAvailable: isAvailable,
                    ctrl: ctrl,
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  int _firstUnbooked(UserModel u) {
    for (int i = 1; i <= 30; i++) {
      if (u.holidayBookings?.any((b) => b.slotNumber == i) != true) return i;
    }
    return 1;
  }
}

// ─────────────────────────────────────────────
//  PAGE 4: PAYMENTS
// ─────────────────────────────────────────────
class PaymentsPage extends StatelessWidget {
  final UserModel u;
  const PaymentsPage({super.key, required this.u});

  @override
  Widget build(BuildContext context) {
    final payments = u.payments ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: _buildAppBar('Payment Details', const Color(0xFF3B82F6)),
      body: payments.isEmpty
          ? _EmptyState('No payment records found', Icons.receipt_long_outlined)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final p = payments[i];
                return FadeInUp(
                  delay: Duration(milliseconds: i * 60),
                  child: _PageCard(
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
                                  Text(p.membershipTierName ?? 'OHC Privilege',
                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
                                  const SizedBox(height: 2),
                                  Text(p.paymentId ?? 'N/A',
                                    style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Text(
                              '₹${p.amount ?? '0'}',
                              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 14),
                        _PayRow('Status', p.status?.toUpperCase() ?? 'N/A', isStatus: true, statusOk: p.status?.toLowerCase() == 'captured'),
                        _PayRow('Method', p.method?.toUpperCase() ?? 'N/A'),
                        _PayRow('Date', p.paidAt ?? 'N/A'),
                        if (p.bank != null && p.bank!.isNotEmpty) _PayRow('Bank', p.bank!),
                        if (p.wallet != null && p.wallet!.isNotEmpty) _PayRow('Wallet', p.wallet!),
                        _PayRow('Period', p.period ?? 'N/A'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────
//  PAGE 5: FAMILY / SPOUSE
// ─────────────────────────────────────────────
class SpousePage extends StatelessWidget {
  final UserModel u;
  const SpousePage({super.key, required this.u});

  @override
  Widget build(BuildContext context) {
    final s = u.spouse;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: _buildAppBar('Family / Spouse', const Color(0xFFEC4899)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: s == null || (s.name == null && s.email == null && s.mobile == null)
            ? Column(
                children: [
                  const SizedBox(height: 40),
                  _EmptyState('No spouse/family details added', Icons.people_alt_outlined),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text('Add Spouse Details', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  FadeInUp(child: _buildInfoCard('Spouse Details', Icons.favorite_rounded, const Color(0xFFEC4899), [
                    _InfoRow('Name', s.name),
                    _InfoRow('Date of Birth', s.dob),
                    _InfoRow('Email', s.email),
                    _InfoRow('Mobile', s.mobile),
                  ])),
                  const SizedBox(height: 80),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED HELPERS & COMPONENTS
// ─────────────────────────────────────────────

PreferredSizeWidget _buildAppBar(String title, Color accent) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.white,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: AppColors.primaryBlack),
      onPressed: () => Get.back(),
    ),
    title: Text(
      title,
      style: GoogleFonts.montserrat(
        color: AppColors.primaryBlack,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: const Color(0xFFF1F5F9)),
    ),
  );
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
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
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(row.label, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              row.value!,
              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlack),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
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
              color: hasDoc ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
          const SizedBox(height: 2),
          Text(type ?? (hasDoc ? 'Verified' : 'Missing'),
            style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey[500])),
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
                child: Text('VIEW PREVIEW', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF6366F1))),
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
                  child: const Center(child: Icon(Icons.error_outline, size: 40, color: Colors.grey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDoc(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
                      child: Text('$slot', style: GoogleFonts.montserrat(color: AppColors.primaryYellow, fontSize: 14, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Slot $slot – Year ${from.year}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800)),
                      Text('${df.format(from)} → ${df.format(to)}',
                        style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey)),
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
                  child: Text('Activate', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900)),
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
                  Text(b.place!, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 16),
                ],
                if (b.adults != null) ...[
                  const Icon(Icons.people_rounded, color: Colors.grey, size: 13),
                  const SizedBox(width: 4),
                  Text('${b.adults} Adults${b.kids != null && b.kids! > 0 ? ', ${b.kids} Kids' : ''}',
                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey)),
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
      case 'confirmed': c = Colors.green; break;
      case 'pending': c = Colors.orange; break;
      case 'cancelled': c = Colors.red; break;
      case 'completed': c = Colors.blue; break;
      case 'locked': c = Colors.grey; break;
      default: c = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(status.toUpperCase(), style: GoogleFonts.montserrat(color: c, fontSize: 8, fontWeight: FontWeight.w900)),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Text('$value', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w700)),
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
        Text(label, style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
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
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusOk ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(value,
                    style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: statusOk ? Colors.green : Colors.orange)),
                )
              : Text(value, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlack)),
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
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon, required this.label, required this.subtitle,
    required this.color, required this.onTap,
  });
}

void _downloadInvoice(String? url) async {
  if (url == null || url.isEmpty) {
    Get.snackbar('Error', 'Invoice not available for this payment.',
        backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    Get.snackbar('Error', 'Could not open invoice URL.',
        backgroundColor: Colors.red, colorText: Colors.white);
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
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Activate Slot ${widget.slot}',
                style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
              ),
              const SizedBox(height: 4),
              Text(
                'Plan your holiday for year ${widget.year}. Our team will contact you to confirm the booking.',
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
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
                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Preferred Destination or special requests...',
                  hintStyle: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey),
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
                    : Text('SUBMIT ACTIVATION REQUEST', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13)),
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
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              date == null ? label : DateFormat('dd/MM/yy').format(date),
              style: GoogleFonts.montserrat(fontSize: 12, color: date == null ? Colors.grey : AppColors.primaryBlack, fontWeight: FontWeight.w600),
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
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[600])),
          Row(
            children: [
              InkWell(onTap: () => val > 0 ? onChange(val - 1) : null, child: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.grey)),
              const SizedBox(width: 10),
              Text(val.toString(), style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w900)),
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
      Get.snackbar('Required', 'Please select check-in and check-out dates.', backgroundColor: Colors.orange, colorText: Colors.white);
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
      final success = await ctrl.submitHolidayActivation(payload);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Activation request submitted! Our concierge will contact you shortly.', 
            backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 4));
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}