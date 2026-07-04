import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import '../controller/membership_form_controller.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class MembershipFormView extends StatelessWidget {
  const MembershipFormView({super.key});

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terms & Conditions',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'PURCHASER (S) DECLARATION\nTERM & CONTIDIONS',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 11.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Own Holiday Club (Rigel Hospitality Services Pvt. Ltd.) the Company, register address Alt f Mohan Estate, Room No. MR-01, Second Floor, Plot No A26, Block B, Mohan Cooperative Industrial Estate, New Delhi -110044',
                          style: GoogleFonts.poppins(fontSize: 11.0),
                        ),
                        const SizedBox(height: 12),
                        _buildTermPoint('1. ', 'In this application and subsequent Agreement the following words shall have the meaning given in the Rules of Occupation of the Resort (a copy of which has been made available to the Applicant) in respect thereof save where the context otherwise requires.'),
                        _buildTermPoint('2. ', 'The Applicant(s) acknowledge to have read and understood the rules of occupation of the resort, and hereby agrees to be bound by the rules and regulations contained therein. The Membership shall continue until the termination date of the scheme or cancellation of Membership in accordance with the relevant provisions of the rules of occupation.'),
                        _buildTermPoint('3. THE COMPANY: ', 'The Company is Rigel Hospitality Services Pvt. Ltd. Who are Developers of the Own Holiday Club situated at South Delhi, New Delhi -110044', boldPrefix: true),
                        _buildTermPoint('4. MEMBERSHIP CARD : ', 'Upon the Applicant(s) completing all payments due under this agreement, Developer shall cause (within 30 days) to be issued to the Applicant(s), a Membership card specifying the Applicant(s) timeshare occupancy rights and upon such card being issued the applicant shall thereby be admitted to membership of the Resort relating to the Apartment or type thereof.', boldPrefix: true),
                        _buildTermPoint('5. RIGHT OF OCCUPATION: ', 'The Applicant(s) is/are entitled to a right of occupation in the apartment as stipulated in the Particulars of Holiday Membership Such right shall exist on a right to use basis and shall exist for the period as stipulated therein.', boldPrefix: true),
                        _buildTermPoint('6. RIGHT OF TRANSFER: ', 'The Applicant(s) besides having the right to use his/her/their week(s), he/she/they may also sell, gift, or bequeath the week(s) to third party, with prior written intimation to “The Company”. Neither the Developer nor the Marketer operates a guaranteed rental or resale service or memberships.', boldPrefix: true),
                        _buildTermPoint('7. OBLIGATION OF COMPANY: ', 'Subject to the prompt payment by the Applicant of the maintenance payments, the Company hereby undertakes with the Applicant to observe and perform the obligations imposed upon it. In case Annual Service Fees is not paid for 5 years then this membership stands cancelled without any prior information to member. You can split your holiday.', boldPrefix: true),
                        _buildTermPoint('8. OBLIGATION OF COMPANY TOWARDS PURCHASER: ', 'The Obligations of Company shall arise/take place in respect of agreement between Marketer and Purchaser only on receipt of full amount of consideration and not otherwise.', boldPrefix: true),
                        _buildTermPoint('9. TERMINATION OF MEMBER’S RIGHT: ', 'In the event of the Application(s) / Member (s) failing to make any payment, due pursuant to this Agreement, the provisions of the rules and regulations of resort relating to terminating the members right to use the resort shall apply.', boldPrefix: true),
                        _buildTermPoint('10. UTILITY FEES: ', 'The Utility Fees stipulated in this agreement shall be payable, to the Company, for the following year in which the Applicant(s) shall be entitled to occupy the apartment as a Resort purchaser. At the time of Holiday booking, the purchaser required to pay the Utility Fees (Approx INR 1500 to INR 2500 Per Night depend upon the properties & location) .', boldPrefix: true),
                        _buildTermPoint('11. INTERPRETATION: ', 'This Purchase Agreement, its terms and conditions, Purchaser(s) acknowledgement, shall constitute the full agreement between the parties herein and the Purchaser(s) acknowledges that no other document shall form a constituted part of this agreement for the purpose of enforcement and interpretation of this agreement.', boldPrefix: true),
                        _buildTermPoint('12. TAXES & LEVIES: ', 'Any present or future levy/tax/duty/charge/fee imposed by State/ Union Government or Local/ public body or authority, (expect any levy on its turnover/income/assets payable by Company), on the members actual use of deemed/concomitant activities thereto, must be borne by the member or if paid by the company on his behalf, be reimbursed on demand.', boldPrefix: true),
                        _buildTermPoint('13. EXIT OPTION: ', 'It is understood that this Agreement upon receipt of written notice (without any personal and financial reason) is cancellable at the option of either of the parties to this agreement within a period of 7 days from date of this Agreement. Upon the non-receipt of any such notice within the stipulated period, the parties agree to be bound by the terms and conditions of this agreement thereafter and the Developer shall not be entitled to refund any money that held by it. . But this clause is not applicable for 5 year’s membership term.', boldPrefix: true),
                        _buildTermPoint('14. REFUND : ', 'It is understood that if the Agreement is cancelled as per clause 14 above by the Applicant (s) the Company shall refund to the Applicant(s), the payments then held by the Company after deducting the administration fee & expenses of Rs. 25000/- paid by the purchaser, but without any interest within 180 days from the date of cancellation request .', boldPrefix: true),
                        _buildTermPoint('15. MODIFICATION: ', 'No modification of this Agreement shall be valid unless made in writing and signed by the Applicant/Member and the Director of Own Holiday Club (Rigel Hospitality Services Pvt. Ltd.) No over writing is allowed on Agreement paper and it is not valid.', boldPrefix: true),
                        _buildTermPoint('16. ARBITRATION AND JURISDICTION: ', 'It is agrees between the parties herein that in the event of any dispute, claims or differences arising under this agreement, the second party shall contact the central customer care team of Own Holiday Club (Rigel Hospitality Services Pvt. Ltd.) at Delhi. In the event the second party reaches no resolution then the second party shall discuss the issue with the resolution cell of the first party. Thereafter if the parties fail to reach any resolution even after discussion with the officers from the resolution cell, the second party may adjudicate the dispute by way of sole arbitrator as per the provisions contained under law. The sole arbitrator shall be nominated by the first party and/or the authorized person of the first party alone. The place of arbitration shall be DELHI only.', boldPrefix: true),
                        _buildTermPoint('17. ', 'All disputes arising out of the relation to the present agreement including for arbitration proceedings shall be subject to exclusive and sole jurisdiction of the court. The definition of the courts includes districts/state consumer forums also situated at Delhi alone and now where else since the agreement is entered between the parties at Delhi for all material purpose and by the virtue of present agreement the jurisdiction of the courts is excluded by the parties except for court situated in Delhi alone. The second party is hereby unconditionally and irrevocably agreed the place of jurisdiction for adopting any kind of legal recourse will be at Delhi.'),
                        _buildTermPoint('18. ', 'The dates from 15th December to 15th January every year comes under blackout dates and we are not providing any bookings in this period.'),
                        _buildTermPoint('19. ', 'Food/Pickup/Drop/Sightseeing facility can be done only on chargeable basis.'),
                        _buildTermPoint('20. ', 'SECOND PARTY hereby declares that particulars given above are true, correct and completely in order. If any transaction is delayed or not affected at all for the reason of incomplete or incorrect information, SECOND PARTY shall not hold Rigel Hospitality Services Pvt. Ltd. responsible for any loss/damages/ inconvenience caused due to the same.'),
                        _buildTermPoint('21. ', 'SECOND PARTY confirms the understanding that all bookings are subject to availability and booking of more than one room simultaneously is purely as per availability.'),
                        _buildTermPoint('22. ', 'Member confirms that this agreement is accepted without any force and confirms that this agreement does not create any undue financial burden on him or on his family.', isSecondPartBold: true),
                        const SizedBox(height: 12),
                        Text(
                          'I confirm and understand that no verbal promised are valid and developer does not take any responsibility for the same.',
                          style: GoogleFonts.poppins(fontSize: 11.0),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'I have read all terms and conditions and accept all of them.',
                          style: GoogleFonts.poppins(fontSize: 11.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Purchaser's Signatures: 1 __________________________2. ________________________________",
                          style: GoogleFonts.poppins(fontSize: 11.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Signed for and on behalf of the developer (Rigel Hospitality Services Pvt. Ltd.)',
                          style: GoogleFonts.poppins(fontSize: 11.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Authorized Signatory: _____________________________________',
                          style: GoogleFonts.poppins(fontSize: 11.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            '(This is a system-generated agreement and does not require a physical signature.)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 11.0),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermPoint(String prefix, String suffix, {bool boldPrefix = false, bool isSecondPartBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 11.0,
                  color: Colors.black87,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: prefix,
                    style: TextStyle(fontWeight: boldPrefix ? FontWeight.bold : FontWeight.normal),
                  ),
                  TextSpan(
                    text: suffix,
                    style: TextStyle(fontWeight: isSecondPartBold ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Instantiate controller
    final controller = Get.find<MembershipFormController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 40,
        title: Transform.translate(
          offset: const Offset(-8, 0),
          child: Image.asset(
            'assets/images/own-holiday-club-logo.png',
            height: 60,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                elevation: 0,
              ),
              onPressed: () => Get.toNamed(Routes.MEMBER_LOGIN),
              child: Text(
                'MEMBER LOGIN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(6),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 50,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Cards (Dynamic)
                  _buildPurchaseOverviewCard(
                    label: "Package Name",
                    value: controller.selectedTier.name,
                    hint: controller.selectedTier.duration ?? "Long Term",
                    tone: "featured",
                  ),
                  Obx(
                    () => _buildPurchaseOverviewCard(
                      label: "Step 1",
                      value: "Personal Details",
                      hint: "Provide your information",
                      tone: controller.currentStep.value == 1
                          ? "accent"
                          : "default",
                    ),
                  ),
                  Obx(
                    () => _buildPurchaseOverviewCard(
                      label: "Step 2",
                      value: "Finalize & Pay",
                      hint: "Documents and payment",
                      tone: controller.currentStep.value == 2
                          ? "accent"
                          : "default",
                    ),
                  ),

                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 20),

                  // Form Content
                  Obx(() {
                    if (controller.currentStep.value == 1) {
                      return _buildStep1(context, controller);
                    } else {
                      return _buildStep2(context, controller);
                    }
                  }),
                ],
              ),
            ),
          ),
          Obx(
            () => controller.isLoading.value
                ? Container(
                    color: AppColors.primaryBlack.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryYellow,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(
    BuildContext context,
    MembershipFormController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERSONAL INFORMATION',
              style: GoogleFonts.poppins(
                color: const Color(0xFFC8102E),
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.only(top: 6),
              color: Colors.grey[200],
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildDropdown('Title *', controller.selectedTitle, [
          'Mr.',
          'Mrs.',
          'Ms.',
          'Dr.',
        ]),
        const SizedBox(height: 14),
        _buildTextField(
          'First Name *',
          controller.nameController,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          'Last Name *',
          controller.lastNameController,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          'DOB *',
          controller.dobController,
          readOnly: true,
          prefixIcon: Icons.calendar_month_outlined,
          suffixIcon: const Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: Colors.grey,
          ),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(
                const Duration(days: 365 * 18),
              ),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              String formatted =
                  "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
              controller.dobController.text = formatted;
            }
          },
        ),
        const SizedBox(height: 14),
        // Mobile Number Field
        Obx(() {
          final isVerified = controller.isMobileVerified.value;
          final isOtpSent = controller.isMobileOtpSent.value;
          final labelText = isVerified
              ? 'Mobile Number'
              : (isOtpSent ? 'Enter OTP' : 'Mobile Number');

          if (isVerified) {
            return _buildTextField(
              labelText,
              controller.mobileController,
              readOnly: true,
              prefixIcon: Icons.phone_iphone_outlined,
              suffixIcon: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryYellow,
                size: 20,
              ),
            );
          }

          return _buildTextField(
            labelText,
            controller.mobileController,
            prefixIcon: Icons.phone_iphone_outlined,
            autofillHints: isOtpSent ? const [AutofillHints.oneTimeCode] : null,
            suffixIcon: Container(
              height: 30,
              margin: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  backgroundColor: isOtpSent
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  foregroundColor: isOtpSent ? Colors.white : Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: isOtpSent
                    ? controller.verifyMobileOtp
                    : controller.sendMobileOtp,
                child: Text(
                  isOtpSent ? 'VERIFY' : 'SEND OTP',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isOtpSent ? Colors.white : Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 14),
        // Email Address Field
        Obx(() {
          final isVerified = controller.isEmailVerified.value;
          final isOtpSent = controller.isEmailOtpSent.value;
          final labelText = isVerified
              ? 'Email Address'
              : (isOtpSent ? 'Enter OTP' : 'Email Address');

          if (isVerified) {
            return _buildTextField(
              labelText,
              controller.emailController,
              readOnly: true,
              prefixIcon: Icons.mail_outline,
              suffixIcon: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryYellow,
                size: 20,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTextField(
                labelText,
                controller.emailController,
                prefixIcon: Icons.mail_outline,
                autofillHints: isOtpSent
                    ? const [AutofillHints.oneTimeCode]
                    : null,
                suffixIcon: Container(
                  height: 30,
                  margin: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: isOtpSent
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      foregroundColor: isOtpSent ? Colors.white : Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: isOtpSent
                        ? controller.verifyEmailOtp
                        : controller.sendEmailOtp,
                    child: Text(
                      isOtpSent ? 'VERIFY' : 'SEND OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isOtpSent ? Colors.white : Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        Obx(
          () => controller.isEmailVerified.value
              ? const SizedBox(height: 8)
              : const SizedBox(height: 3),
        ),
        _buildDropdown('Gender *', controller.selectedGender, [
          'Male',
          'Female',
          'Other',
        ], prefixIcon: Icons.wc_outlined),
        const SizedBox(height: 14),
        _buildDropdown(
          'Marital Status *',
          controller.selectedMarried,
          ['Married', 'Single', 'Separated'],
          prefixIcon: Icons.favorite_outline,
        ),
        const SizedBox(height: 14),
        Obx(() {
          final isMarried = controller.selectedMarried.value == 'Married';
          if (!isMarried) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Anniversary',
                controller.anniversaryController,
                readOnly: true,
                prefixIcon: Icons.calendar_month_outlined,
                suffixIcon: const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    controller.anniversaryController.text = DateFormat(
                      'dd-MM-yyyy',
                    ).format(picked);
                  }
                },
              ),
              const SizedBox(height: 14),
            ],
          );
        }),
        _buildDropdown(
          'Occupation *',
          controller.selectedOccupation,
          [
            'Business',
            'Private Job',
            'Government Job',
            'Professional',
            'Self Employed',
            'Homemaker',
            'Retired',
            'Student',
            'Other',
          ],
          prefixIcon: Icons.work_outline,
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADDRESS INFORMATION',
              style: GoogleFonts.poppins(
                color: const Color(0xFFC8102E),
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.only(top: 6),
              color: Colors.grey[200],
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(
          'House No. / Block No.',
          controller.houseNoController,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          'Permanent Address *',
          controller.residenceAddressController,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          'City *',
          controller.residenceCityController,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),
        _buildDropdown('State *', controller.selectedStateRes, [
          'Andhra Pradesh',
          'Arunachal Pradesh',
          'Assam',
          'Bihar',
          'Chhattisgarh',
          'Goa',
          'Gujarat',
          'Haryana',
          'Himachal Pradesh',
          'Jharkhand',
          'Karnataka',
          'Kerala',
          'Madhya Pradesh',
          'Maharashtra',
          'Manipur',
          'Meghalaya',
          'Mizoram',
          'Nagaland',
          'Odisha',
          'Punjab',
          'Rajasthan',
          'Sikkim',
          'Tamil Nadu',
          'Telangana',
          'Tripura',
          'Uttar Pradesh',
          'Uttarakhand',
          'West Bengal',
          'Andaman & Nicobar Islands',
          'Chandigarh',
          'Dadra & Nagar Haveli and Daman & Diu',
          'Delhi',
          'Jammu & Kashmir',
          'Ladakh',
          'Lakshadweep',
          'Puducherry',
        ], prefixIcon: Icons.map_outlined),
        const SizedBox(height: 14),
        _buildCountryDropdown(
          'Country *',
          controller.selectedCountryRes,
          controller,
          prefixIcon: Icons.public_outlined,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          'Pin Code',
          controller.pinController,
          prefixIcon: Icons.pin_drop_outlined,
        ),
        const SizedBox(height: 20),
        Obx(
          () => GestureDetector(
            onTap: () => controller.showOfficeAddress.value =
                !controller.showOfficeAddress.value,
            child: Row(
              children: [
                Icon(
                  controller.showOfficeAddress.value
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  size: 16,
                  color: const Color(0xFF1565C0),
                ),
                const SizedBox(width: 6),
                Text(
                  controller.showOfficeAddress.value
                      ? 'Remove Office Address'
                      : 'Add Office Address (Optional)',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1565C0),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          if (!controller.showOfficeAddress.value) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OFFICE ADDRESS (OPTIONAL)',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    margin: const EdgeInsets.only(top: 6),
                    color: Colors.grey[200],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTextField(
                'Office Address',
                controller.officeAddressController,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                'Office City',
                controller.officeCityController,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 14),
              _buildDropdown('State', controller.selectedStateOff, [
                'Andhra Pradesh',
                'Arunachal Pradesh',
                'Assam',
                'Bihar',
                'Chhattisgarh',
                'Goa',
                'Gujarat',
                'Haryana',
                'Himachal Pradesh',
                'Jharkhand',
                'Karnataka',
                'Kerala',
                'Madhya Pradesh',
                'Maharashtra',
                'Manipur',
                'Meghalaya',
                'Mizoram',
                'Nagaland',
                'Odisha',
                'Punjab',
                'Rajasthan',
                'Sikkim',
                'Tamil Nadu',
                'Telangana',
                'Tripura',
                'Uttar Pradesh',
                'Uttarakhand',
                'West Bengal',
                'Andaman & Nicobar Islands',
                'Chandigarh',
                'Dadra & Nagar Haveli and Daman & Diu',
                'Delhi',
                'Jammu & Kashmir',
                'Ladakh',
                'Ladakh',
                'Lakshadweep',
                'Puducherry',
              ], prefixIcon: Icons.map_outlined),
              const SizedBox(height: 14),
              _buildCountryDropdown(
                'Country',
                controller.selectedCountryOff,
                controller,
                prefixIcon: Icons.public_outlined,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                'Pin',
                controller.officePinController,
                prefixIcon: Icons.pin_drop_outlined,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                'Phone',
                controller.officePhoneController,
                prefixIcon: Icons.phone_outlined,
              ),
            ],
          );
        }),

        Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'FAMILY DETAILS ',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC8102E),
                        letterSpacing: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: '(Compulsory for Married)',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                'Spouse Name *',
                controller.spouseNameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                'Spouse DOB *',
                controller.spouseDobController,
                readOnly: true,
                prefixIcon: Icons.calendar_today_outlined,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    controller.spouseDobController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(picked);
                  }
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                'Spouse Mobile *',
                controller.spouseMobileController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                'Spouse Email *',
                controller.spouseEmailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Children details
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CHILDREN DETAILS',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4B5563),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'NO. OF CHILDREN: ',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 28,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFD1D5DB),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: controller.numberOfChildren.value,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: List.generate(5, (index) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(index.toString()),
                                    );
                                  }),
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.updateChildrenCount(val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (controller.numberOfChildren.value > 0) ...[
                      const SizedBox(height: 16),
                      ...List.generate(controller.numberOfChildren.value, (
                        index,
                      ) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              'CHILD NAME',
                              controller.childrenNameControllers[index],
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: 14),
                            _buildDropdown(
                              'Gender',
                              controller.childrenGenderOptions[index],
                              ['Male', 'Female', 'Other'],
                              prefixIcon: Icons.people_outline,
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              'DOB',
                              controller.childrenDobControllers[index],
                              readOnly: true,
                              prefixIcon: Icons.calendar_today_outlined,
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  controller
                                      .childrenDobControllers[index]
                                      .text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(picked);
                                }
                              },
                            ),
                            if (index < controller.numberOfChildren.value - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Color(0xFFE5E7EB)),
                              ),
                          ],
                        );
                      }),
                    ],
                  ],
                ),
            ],
          );
        }),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: controller.isConsentChecked.value,
                  activeColor: AppColors.primaryYellow,
                  checkColor: Colors.black,
                  onChanged: (val) =>
                      controller.isConsentChecked.value = val ?? false,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'I agree to the ',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF4B5563),
              ),
            ),
            GestureDetector(
              onTap: () => _showTermsDialog(context),
              child: Text(
                'Terms & Conditions',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC8102E),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.nextStep,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      'Next Step ➔',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(
    BuildContext context,
    MembershipFormController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOCUMENTS',
          style: GoogleFonts.poppins(
            color: AppColors.primaryYellow,
            fontWeight: FontWeight.bold,
            fontSize: 13.0,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => _buildFileRow(
            'Profile Image',
            controller.profileImageFile.value?.name ?? 'No file chosen',
            () => controller.pickFile('profileImage'),
            prefixIcon: Icons.image_outlined,
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => _buildFileRow(
            'Aadhaar Card',
            controller.idProofFile.value?.name ?? 'No file chosen',
            () => controller.pickFile('idProof'),
            prefixIcon: Icons.credit_card_outlined,
          ),
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          'Address Proof',
          controller.selectedAddressProof,
          ['Passport', 'Gov ID', 'PAN Card', 'Driving Licence', 'Voter ID'],
          isHighlight: true,
          prefixIcon: Icons.file_present_outlined,
        ),
        const SizedBox(height: 14),
        Obx(
          () => _buildFileRow(
            'Upload Proof',
            controller.addressProofFile.value?.name ?? 'No file chosen',
            () => controller.pickFile('addressProof'),
            prefixIcon: Icons.upload_file_outlined,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'CONSENT',
          style: GoogleFonts.poppins(
            color: AppColors.primaryYellow,
            fontWeight: FontWeight.bold,
            fontSize: 13.0,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: controller.isConsentChecked.value,
                    activeColor: AppColors.primaryYellow,
                    checkColor: Colors.black,
                    onChanged: (val) =>
                        controller.isConsentChecked.value = val ?? false,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        Text(
                          'I agree to the ',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Terms & Conditions',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryYellow,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showTermsPopup(context),
                      child: Text(
                        'Read full terms and conditions',
                        style: GoogleFonts.poppins(
                          color: AppColors.greyText,
                          fontSize: 12.0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Color(0xFFCED4DA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: controller.previousStep,
                  icon: const Icon(Icons.arrow_back, size: 14),
                  label: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: controller.proceedToPayment,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Pay Now',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryDropdown(
    String labelText,
    RxnString rxValue,
    MembershipFormController controller, {
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(labelText),
        Obx(
          () => GestureDetector(
            onTap: () => _showCountryPicker(rxValue, controller),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCED4DA)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      rxValue.value ?? 'Select Country',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: rxValue.value != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: rxValue.value != null
                            ? const Color(0xFF0D1321)
                            : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker(
    RxnString rxValue,
    MembershipFormController controller,
  ) {
    final TextEditingController searchCtrl = TextEditingController();
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final query = searchCtrl.text.toLowerCase();
            final filtered = query.isEmpty
                ? controller.countriesList
                : controller.countriesList
                      .where((c) => c.toLowerCase().contains(query))
                      .toList();
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              maxChildSize: 0.92,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 14),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchCtrl,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.poppins(fontSize: 12.0),
                        decoration: InputDecoration(
                          hintText: 'Search country...',
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.greyText,
                            fontSize: 12.0,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.greyText,
                            size: 18,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: AppColors.lightGrey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: AppColors.lightGrey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: AppColors.primaryYellow,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: controller.countriesList.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryYellow,
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final country = filtered[index];
                                final isSelected = rxValue.value == country;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    country,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.0,
                                      color: isSelected
                                          ? AppColors.primaryYellow
                                          : AppColors.primaryBlack,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primaryYellow,
                                          size: 16,
                                        )
                                      : null,
                                  onTap: () {
                                    rxValue.value = country;
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    bool isRequired = false;
    String labelText = text;
    if (text.endsWith(' *')) {
      isRequired = true;
      labelText = text.substring(0, text.length - 2);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
      child: RichText(
        text: TextSpan(
          text: labelText.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF334155),
            letterSpacing: 0.5,
          ),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: GoogleFonts.poppins(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC8102E),
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String labelText,
    TextEditingController controller, {
    bool readOnly = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    VoidCallback? onTap,
    Iterable<String>? autofillHints,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(labelText),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D1321),
          ),
          decoration: InputDecoration(
            hintText: labelText,
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 9,
              horizontal: 8,
            ),
            isDense: true,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    child: Icon(prefixIcon, size: 18, color: Colors.grey),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 0,
            ),
            suffixIcon: suffixIcon,
            suffixIconConstraints: suffixIcon != null
                ? const BoxConstraints(minWidth: 34, minHeight: 0)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFFCED4DA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFFCED4DA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: Color(0xFF000000),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTermsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terms & Conditions',
              style: GoogleFonts.poppins(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.close,
                color: AppColors.greyText,
                size: 20,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Membership Agreement',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'By purchasing a membership, you agree to abide by the rules and regulations of Own Holiday Club.',
                style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '2. Payment & Refunds',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'All membership payments are final. Refunds are subject to the cancellation policy.',
                style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '3. Document Verification',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Your membership is subject to successful verification of your submitted KYC documents.',
                style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '4. Usage of Benefits',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Membership benefits, including holiday packages and discounts, are non-transferable unless explicitly stated.',
                style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    RxnString rxValue,
    List<String> items, {
    bool isHighlight = false,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(hint),
        Obx(
          () => DropdownButtonFormField<String>(
            value: rxValue.value,
            isExpanded: true,
            dropdownColor: Colors.white,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1321),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 8,
              ),
              isDense: true,
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10, right: 6),
                      child: Icon(prefixIcon, size: 18, color: Colors.grey),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: isHighlight
                      ? AppColors.primaryYellow
                      : const Color(0xFFCED4DA),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: isHighlight
                      ? AppColors.primaryYellow
                      : const Color(0xFFCED4DA),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color(0xFF000000),
                  width: 1.5,
                ),
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey,
              size: 16,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: (val) {
              if (val != null) rxValue.value = val;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileRow(
    String label,
    String fileName,
    VoidCallback onTap, {
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(label),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFCED4DA)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(4),
                    ),
                    border: Border(right: BorderSide(color: Color(0xFFCED4DA))),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefixIcon != null) ...[
                        Icon(prefixIcon, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        'Choose File',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D1321),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    fileName,
                    style: GoogleFonts.poppins(
                      color:
                          fileName.contains('chosen') ||
                              fileName.contains('No file')
                          ? Colors.grey
                          : const Color(0xFF0D1321),
                      fontSize: 11.5,
                      fontWeight:
                          fileName.contains('chosen') ||
                              fileName.contains('No file')
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseOverviewCard({
    required String label,
    required String value,
    required String hint,
    required String tone,
  }) {
    Color bgColor;
    Color borderColor;
    Color labelColor;
    Color accentColor;

    if (tone == 'featured') {
      bgColor = const Color(0xFFFEF2F2).withOpacity(0.5);
      borderColor = const Color(0xFFFEE2E2);
      labelColor = const Color(0xFFC8102E);
      accentColor = const Color(0xFFC8102E);
    } else if (tone == 'accent') {
      bgColor = const Color(0xFFECFDF5).withOpacity(0.5);
      borderColor = const Color(0xFFD1FAE5);
      labelColor = Colors.green[700]!;
      accentColor = Colors.green[500]!;
    } else {
      bgColor = const Color(0xFFFFFBEB).withOpacity(0.5);
      borderColor = const Color(0xFFFEF3C7);
      labelColor = Colors.amber[700]!;
      accentColor = Colors.amber[500]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(height: 2, width: 32, color: accentColor),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hint.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  hint.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
