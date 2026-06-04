import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/modules/account/controller/account_controller.dart';
import 'package:own_holiday_app/modules/auth/login/model/user_model.dart';

class MyBookingsView extends StatelessWidget {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'My Booking History',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryBlack),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryBlack, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final bookings =
            accountController.userData.value?.holidayBookings ?? [];

        return RefreshIndicator(
          onRefresh: () async => accountController.refreshProfile(),
          color: const Color(0xFFC9A84C),
          backgroundColor: Colors.white,
          child: bookings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                  color: const Color(0xFFEDEFF2), width: 1),
                            ),
                            child: const Icon(Icons.event_busy_rounded,
                                size: 40, color: AppColors.greyText),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No bookings yet',
                            style: GoogleFonts.montserrat(
                                color: AppColors.primaryBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your holiday booking requests will appear here.',
                            style: GoogleFonts.montserrat(
                                color: AppColors.greyText,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return _BookingCard(booking: bookings[index]);
                  },
                ),
        );
      }),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  static const _boxShadow = [
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
  ];

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final place = booking.place ?? 'Unknown Destination';
    final requestId = booking.id != null && booking.id!.length >= 6
        ? '#${booking.id!.substring(booking.id!.length - 6).toUpperCase()}'
        : '#N/A';
    final requestedDate = booking.requestedAt != null
        ? df.format(DateTime.parse(booking.requestedAt!))
        : 'Date Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2), width: 1),
        boxShadow: _boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            // ── Collapsed header ──────────────────────────────────────
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1628),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded,
                      color: Color(0xFFC9A84C), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A1628),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Request ID: $requestId',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  _StatusBadge(status: booking.status ?? 'booking'),
                  const Spacer(),
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: AppColors.greyText),
                  const SizedBox(width: 4),
                  Text(
                    requestedDate,
                    style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            // ── Expanded details ──────────────────────────────────────
            children: [
              const Divider(height: 1, color: Color(0xFFEDEFF2)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    _detailRow(
                      Icons.calendar_today_rounded,
                      'Check-in',
                      booking.checkIn != null
                          ? df.format(DateTime.parse(booking.checkIn!))
                          : 'N/A',
                    ),
                    const SizedBox(height: 2),
                    const Divider(height: 16, color: Color(0xFFF4F5F7)),
                    _detailRow(
                      Icons.calendar_month_rounded,
                      'Check-out',
                      booking.checkOut != null
                          ? df.format(DateTime.parse(booking.checkOut!))
                          : 'N/A',
                    ),
                    const SizedBox(height: 2),
                    const Divider(height: 16, color: Color(0xFFF4F5F7)),
                    _detailRow(
                      Icons.group_outlined,
                      'Guests',
                      '${booking.adults ?? 0} Adults, ${booking.kids ?? 0} Kids',
                    ),
                    if (booking.slotNumber != null) ...[
                      const SizedBox(height: 2),
                      const Divider(height: 16, color: Color(0xFFF4F5F7)),
                      _detailRow(
                        Icons.confirmation_number_outlined,
                        'Slot',
                        'Slot #${booking.slotNumber}',
                      ),
                    ],
                    if (booking.confirmedAt != null) ...[
                      const SizedBox(height: 2),
                      const Divider(height: 16, color: Color(0xFFF4F5F7)),
                      _detailRow(
                        Icons.check_circle_outline_rounded,
                        'Confirmed On',
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(DateTime.parse(booking.confirmedAt!)),
                        valueColor: const Color(0xFF047857),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.greyText),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: valueColor ?? const Color(0xFF0A1628),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    Color bg, border, text;
    String label;

    if (s == 'booked' || s == 'confirmed' || s == 'approved' || s == 'used') {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFF059669);
      text = const Color(0xFF047857);
      label = 'CONFIRMED';
    } else if (s == 'cancelled') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFEF4444);
      text = const Color(0xFFB91C1C);
      label = 'CANCELLED';
    } else {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFF59E0B);
      text = const Color(0xFFB45309);
      label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
