import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/modules/account/controller/account_controller.dart';
import '../controller/member_details_controller.dart';
import '../../login/model/user_model.dart';

class BookHolidayView extends StatefulWidget {
  final UserModel user;
  const BookHolidayView({super.key, required this.user});

  @override
  State<BookHolidayView> createState() => _BookHolidayViewState();
}

class _BookHolidayViewState extends State<BookHolidayView> {
  late final MemberDetailsController controller;
  late final AccountController accountController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MemberDetailsController>()
        ? Get.find<MemberDetailsController>()
        : Get.put(MemberDetailsController());
    accountController = Get.find<AccountController>();
  }

  Future<void> _onRefresh() async {
    await accountController.refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Holiday Slots',
          style: GoogleFonts.montserrat(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
              fontSize: 16.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryBlack, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final u = accountController.userData.value ?? widget.user;
        final totalSlots = u.membership?.totalDurationYears ?? 5;
        final bookings = u.holidayBookings ?? [];
        final startDate = u.membership?.purchasedAt != null
            ? DateTime.tryParse(u.membership!.purchasedAt!) ?? DateTime.now()
            : DateTime.now();

        final requestedCount =
            bookings.where((b) => b.status?.toLowerCase() == 'booking').length;
        final usedCount =
            bookings.where((b) => b.status?.toLowerCase() == 'booked').length;
        final remainingCount =
            (totalSlots - (requestedCount + usedCount)).clamp(0, totalSlots);
        final lengthOfStay = u.membership?.nightsPerYear ?? '6 Nights / 7 Days';

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFFC9A84C),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Quota Strip ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _QuotaCard(
                        label: 'Total Access',
                        value: '$totalSlots',
                        valueColor: const Color(0xFF6366F1),
                        borderColor: const Color(0xFFE0E7FF),
                        bgColor: const Color(0xFFF5F3FF),
                        icon: Icons.confirmation_num_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuotaCard(
                        label: 'Req / Used',
                        value: '$requestedCount / $usedCount',
                        valueColor: const Color(0xFFB45309),
                        borderColor: const Color(0xFFFDE68A),
                        bgColor: const Color(0xFFFFFBEB),
                        icon: Icons.hourglass_top_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuotaCard(
                        label: 'Remaining',
                        value: '$remainingCount',
                        valueColor: const Color(0xFF047857),
                        borderColor: const Color(0xFFA7F3D0),
                        bgColor: const Color(0xFFECFDF5),
                        icon: Icons.beach_access_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'Select a Slot to Book',
                  style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack),
                ),
                const SizedBox(height: 12),

                // ── Slots List ───────────────────────────────────────────
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalSlots,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final slot = i + 1;
                    final from = DateTime(
                        startDate.year + i, startDate.month, startDate.day);
                    final to = DateTime(startDate.year + i + 1,
                        startDate.month, startDate.day);
                    final booking =
                        bookings.firstWhereOrNull((b) => b.slotNumber == slot);

                    return _SlotCard(
                      slot: slot,
                      validFrom: from,
                      validTo: to,
                      lengthOfStay: lengthOfStay,
                      booking: booking,
                      onBook: () =>
                          _showBookingDialog(context, slot, from, to),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showBookingDialog(
      BuildContext context, int slot, DateTime validFrom, DateTime validTo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingSheet(
        slot: slot,
        validFrom: validFrom,
        validTo: validTo,
        controller: controller,
      ),
    );
  }
}

// ── Quota Card ────────────────────────────────────────────────────────────────
class _QuotaCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color borderColor;
  final Color bgColor;
  final IconData icon;

  const _QuotaCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.borderColor,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: valueColor, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.montserrat(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: valueColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
                fontSize: 9.0,
                fontWeight: FontWeight.w600,
                color: valueColor.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ── Slot Card ─────────────────────────────────────────────────────────────────
class _SlotCard extends StatelessWidget {
  final int slot;
  final DateTime validFrom;
  final DateTime validTo;
  final String lengthOfStay;
  final BookingModel? booking;
  final VoidCallback onBook;

  const _SlotCard({
    required this.slot,
    required this.validFrom,
    required this.validTo,
    required this.lengthOfStay,
    required this.booking,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final b = booking;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slot header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1628),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Slot #$slot',
                    style: GoogleFonts.montserrat(
                        color: const Color(0xFFC9A84C),
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lengthOfStay,
                    style: GoogleFonts.montserrat(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A1628)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Validity
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined,
                    size: 14, color: AppColors.greyText),
                const SizedBox(width: 6),
                Text(
                  'Validity: ${df.format(validFrom)} — ${df.format(validTo)}',
                  style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),

            // Booking details if booked
            if (b != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFEDEFF2), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Color(0xFFC9A84C), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(b.place ?? 'N/A',
                              style: GoogleFonts.montserrat(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0A1628))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.date_range_rounded,
                            color: AppColors.greyText, size: 13),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${df.format(DateTime.tryParse(b.checkIn ?? '') ?? validFrom)} → ${df.format(DateTime.tryParse(b.checkOut ?? '') ?? validTo)}',
                            style: GoogleFonts.montserrat(
                                fontSize: 11.0,
                                color: AppColors.greyText,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.group_outlined,
                            color: AppColors.greyText, size: 13),
                        const SizedBox(width: 6),
                        Text(
                          'Guests: ${b.adults ?? 0} Adults, ${b.kids ?? 0} Kids',
                          style: GoogleFonts.montserrat(
                              fontSize: 11.0,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFEDEFF2)),
            const SizedBox(height: 12),

            // Action button — bottom right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildActionButton()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final b = booking;
    if (b == null) {
      return ElevatedButton(
        onPressed: onBook,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC9A84C),
          foregroundColor: const Color(0xFF0A1628),
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'BOOK NOW',
          style: GoogleFonts.montserrat(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8),
        ),
      );
    }

    final statusLabel = b.status?.toUpperCase() ?? 'PENDING';
    final statusLower = statusLabel.toLowerCase();

    Color bg = const Color(0xFFF8FAFC);
    Color border = const Color(0xFFE8E4DC);
    Color text = const Color(0xFF9CA3AF);

    if (statusLower == 'booking' || statusLower == 'pending') {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFF59E0B);
      text = const Color(0xFFB45309);
    } else if (statusLower == 'booked' ||
        statusLower == 'used' ||
        statusLower == 'approved') {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFF059669);
      text = const Color(0xFF047857);
    } else if (statusLower == 'expired') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFF43F5E);
      text = const Color(0xFFBE123C);
    } else if (statusLower == 'cancelled') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFEF4444);
      text = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusLabel,
        style: GoogleFonts.montserrat(
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            color: text,
            letterSpacing: 0.8),
      ),
    );
  }
}

// ── Booking Bottom Sheet ──────────────────────────────────────────────────────
class _BookingSheet extends StatefulWidget {
  final int slot;
  final DateTime validFrom;
  final DateTime validTo;
  final MemberDetailsController controller;

  const _BookingSheet({
    required this.slot,
    required this.validFrom,
    required this.validTo,
    required this.controller,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Request Booking (Slot ${widget.slot})',
                style: GoogleFonts.montserrat(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack),
              ),
              const SizedBox(height: 4),
              Text(
                'Valid from ${DateFormat('dd MMM yyyy').format(widget.validFrom)} to ${DateFormat('dd MMM yyyy').format(widget.validTo)}',
                style: GoogleFonts.montserrat(
                    fontSize: 11.0,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              _fieldLabel('Destination / Place'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _placeController,
                style: GoogleFonts.montserrat(
                    fontSize: 12.0, fontWeight: FontWeight.w500),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter a destination'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Enter destination...',
                  hintStyle: GoogleFonts.montserrat(
                      fontSize: 11.0, color: AppColors.greyText),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FB),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Check-In Date'),
                        const SizedBox(height: 6),
                        _buildDateButton(
                            _checkIn, (d) => setState(() => _checkIn = d)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Check-Out Date'),
                        const SizedBox(height: 6),
                        _buildDateButton(
                            _checkOut, (d) => setState(() => _checkOut = d)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Adults'),
                        const SizedBox(height: 6),
                        _buildCounter(_adults,
                            (val) => setState(() => _adults = val), 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Kids'),
                        const SizedBox(height: 6),
                        _buildCounter(_kids,
                            (val) => setState(() => _kids = val), 0),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: const Color(0xFF0A1628),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0A1628)))
                      : Text(
                          'Submit Booking Request',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 12.0),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.montserrat(
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack),
      );

  Widget _buildDateButton(DateTime? date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: widget.validFrom.isAfter(DateTime.now())
              ? widget.validFrom
              : DateTime.now(),
          firstDate: widget.validFrom.isAfter(DateTime.now())
              ? widget.validFrom
              : DateTime.now(),
          lastDate: widget.validTo,
        );
        if (d != null) onSelect(d);
      },
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('dd MMM yyyy').format(date)
                  : 'Select Date',
              style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  color: date != null
                      ? AppColors.primaryBlack
                      : AppColors.greyText,
                  fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.calendar_today_rounded,
                size: 14, color: AppColors.greyText),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(int val, Function(int) onChange, int minVal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed:
                val > minVal ? () => onChange(val - 1) : null,
            icon: const Icon(Icons.remove,
                size: 14, color: AppColors.primaryBlack),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text('$val',
              style: GoogleFonts.montserrat(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack)),
          IconButton(
            onPressed: () => onChange(val + 1),
            icon: const Icon(Icons.add,
                size: 14, color: AppColors.primaryBlack),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null || _checkOut == null) {
      Get.snackbar('Dates Required',
          'Please select both check-in and check-out dates',
          backgroundColor: const Color(0xFFFEE2E2),
          colorText: const Color(0xFFB91C1C),
          icon: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFB91C1C)));
      return;
    }
    if (_checkOut!.isBefore(_checkIn!)) {
      Get.snackbar(
          'Invalid Dates', 'Check-out date must be after check-in date',
          backgroundColor: const Color(0xFFFEE2E2),
          colorText: const Color(0xFFB91C1C),
          icon: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFB91C1C)));
      return;
    }

    setState(() => _isSubmitting = true);
    final payload = {
      'slotNumber': widget.slot,
      'place': _placeController.text.trim(),
      'checkIn': _checkIn!.toIso8601String(),
      'checkOut': _checkOut!.toIso8601String(),
      'adults': _adults,
      'kids': _kids,
    };

    final errorMessage =
        await widget.controller.submitHolidayActivation(payload);
    setState(() => _isSubmitting = false);

    if (errorMessage == null) {
      Get.back();
      Get.snackbar(
        'Success',
        'Booking request submitted! OHC team will contact you.',
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF15803D),
        icon: const Icon(Icons.check_circle_outline_rounded,
            color: Color(0xFF15803D)),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        'Booking Failed',
        errorMessage,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFFB91C1C),
        icon: const Icon(Icons.error_outline_rounded,
            color: Color(0xFFB91C1C)),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
