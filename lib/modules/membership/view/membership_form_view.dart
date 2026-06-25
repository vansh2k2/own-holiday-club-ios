import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import '../controller/membership_form_controller.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class MembershipFormView extends StatelessWidget {
  const MembershipFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate controller
    final controller = Get.find<MembershipFormController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset('assets/images/own-holiday-club-logo.png', height: 40),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                elevation: 0,
              ),
              onPressed: () => Get.toNamed(Routes.MEMBER_LOGIN),
              child: Text(
                'MEMBER LOGIN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Header Cards (Dynamic)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.primaryYellow),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PACKAGE NAME',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryBlack,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.selectedTier.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryYellow,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                controller.selectedTier.duration ?? 'Long Term Access',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.0,
                                  color: AppColors.greyText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF4FF),
                            border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  
                                  
                                  Expanded(
                                    child: Text(
                                      'TOTAL PAYABLE',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF1565C0),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${controller.selectedTier.price}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryBlack,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Active Now',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryBlack.withOpacity(0.6),
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PROGRESS',
                                style: GoogleFonts.poppins(
                                  color: AppColors.greyText,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Step ${controller.currentStep.value} of 2',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              Text(
                                controller.currentStep.value == 1 ? 'Personal details' : 'Documents',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.0,
                                  color: AppColors.greyText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

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
          Obx(() => controller.isLoading.value 
            ? Container(
                color: AppColors.primaryBlack.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
              )
            : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext context, MembershipFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERSONAL DETAIL',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                width: 30,
                height: 2,
                margin: const EdgeInsets.only(top: 2),
                color: AppColors.primaryYellow,
              ),
            ],
          ),
          const SizedBox(height: 12),          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildDropdown('Title', controller.selectedTitle, ['Mr.', 'Mrs.', 'Ms.', 'Dr.']),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 7,
                child: _buildTextField('First Name', controller.nameController, prefixIcon: Icons.person_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField('Last Name', controller.lastNameController, prefixIcon: Icons.person_outline),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  'DOB (DD-MM-YYYY)',
                  controller.dobController,
                  readOnly: true,
                  prefixIcon: Icons.calendar_month_outlined,
                  suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      String formatted = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                      controller.dobController.text = formatted;
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                suffixIcon: const Icon(Icons.check_circle_rounded, color: AppColors.primaryYellow, size: 20),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildTextField(
                    labelText,
                    controller.mobileController,
                    prefixIcon: Icons.phone_iphone_outlined,
                    autofillHints: isOtpSent ? const [AutofillHints.oneTimeCode] : null,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: isOtpSent ? controller.verifyMobileOtp : controller.sendMobileOtp,
                    child: Text(
                      isOtpSent ? 'VERIFY' : 'SEND OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
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
                suffixIcon: const Icon(Icons.check_circle_rounded, color: AppColors.primaryYellow, size: 20),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildTextField(
                    labelText,
                    controller.emailController,
                    prefixIcon: Icons.mail_outline,
                    autofillHints: isOtpSent ? const [AutofillHints.oneTimeCode] : null,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: isOtpSent ? controller.verifyEmailOtp : controller.sendEmailOtp,
                    child: Text(
                      isOtpSent ? 'VERIFY' : 'SEND OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdown('Gender', controller.selectedGender, ['Male', 'Female', 'Other'], prefixIcon: Icons.wc_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown(
                  'Marital Status', 
                  controller.selectedMarried, 
                  ['Married', 'Single', 'Separated'],
                  prefixIcon: Icons.favorite_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                  suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      controller.anniversaryController.text = DateFormat('dd-MM-yyyy').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
          _buildDropdown('Occupation', controller.selectedOccupation, ['Business', 'Private Job', 'Government Job', 'Professional', 'Self Employed', 'Homemaker', 'Retired', 'Student', 'Other'], prefixIcon: Icons.work_outline),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADDRESS',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                width: 30,
                height: 2,
                margin: const EdgeInsets.only(top: 2),
                color: AppColors.primaryYellow,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('House No. / Block No.', controller.houseNoController, prefixIcon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          _buildTextField('Residence Address', controller.residenceAddressController, prefixIcon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField('Residence City', controller.residenceCityController, prefixIcon: Icons.location_on_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown('State', controller.selectedStateRes, ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman & Nicobar Islands', 'Chandigarh', 'Dadra & Nagar Haveli and Daman & Diu', 'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'], prefixIcon: Icons.map_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCountryDropdown('Country', controller.selectedCountryRes, controller, prefixIcon: Icons.public_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField('Pin Code', controller.pinController, prefixIcon: Icons.pin_drop_outlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => GestureDetector(
            onTap: () => controller.showOfficeAddress.value = !controller.showOfficeAddress.value,
            child: Row(
              children: [
                Icon(
                  controller.showOfficeAddress.value ? Icons.remove_circle_outline : Icons.add_circle_outline,
                  size: 16,
                  color: const Color(0xFF1565C0),
                ),
                const SizedBox(width: 6),
                Text(
                  controller.showOfficeAddress.value ? 'Remove Office Address' : 'Add Office Address (Optional)',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1565C0),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          )),
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
                        color: const Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 2,
                      margin: const EdgeInsets.only(top: 2),
                      color: AppColors.primaryYellow,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Office Address', controller.officeAddressController, prefixIcon: Icons.location_on_outlined),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField('Office City', controller.officeCityController, prefixIcon: Icons.location_on_outlined),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown('State', controller.selectedStateOff, ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman & Nicobar Islands', 'Chandigarh', 'Dadra & Nagar Haveli and Daman & Diu', 'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Ladakh', 'Lakshadweep', 'Puducherry'], prefixIcon: Icons.map_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildCountryDropdown('Country', controller.selectedCountryOff, controller, prefixIcon: Icons.public_outlined),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField('Pin', controller.officePinController, prefixIcon: Icons.pin_drop_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Phone', controller.officePhoneController, prefixIcon: Icons.phone_outlined),
              ],
            );
          }),
          const SizedBox(height: 20),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value ? null : controller.nextStep,
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
                        color: Colors.black,
                      ),
                    ),
            ),
          ))
        ],
      );
  }

  Widget _buildStep2(BuildContext context, MembershipFormController controller) {
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
          const SizedBox(height: 12),
          Obx(() => _buildFileRow(
            'Profile Image',
            controller.profileImageFile.value?.name ?? 'No file chosen',
            () => controller.pickFile('profileImage'),
            prefixIcon: Icons.image_outlined,
          )),
          const SizedBox(height: 12),
          Obx(() => _buildFileRow(
            'Aadhaar Card',
            controller.idProofFile.value?.name ?? 'No file chosen',
            () => controller.pickFile('idProof'),
            prefixIcon: Icons.credit_card_outlined,
          )),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: _buildDropdown('Address Proof', controller.selectedAddressProof, ['Passport', 'Gov ID', 'PAN Card', 'Driving Licence', 'Voter ID'], isHighlight: true, prefixIcon: Icons.file_present_outlined),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLabel('UPLOAD PROOF'),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFCED4DA)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => controller.pickFile('addressProof'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F3F5),
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                                border: Border(right: BorderSide(color: Color(0xFFCED4DA))),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.file_upload_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Choose File',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
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
                              child: Obx(() => Text(
                                controller.addressProofFile.value?.name ?? 'No file chosen',
                                style: GoogleFonts.poppins(
                                  color: controller.addressProofFile.value?.name != null ? const Color(0xFF0D1321) : Colors.grey,
                                  fontSize: 11.5,
                                  fontWeight: controller.addressProofFile.value?.name != null ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: controller.isConsentChecked.value,
                    activeColor: AppColors.primaryYellow,
                    checkColor: Colors.black,
                    onChanged: (val) => controller.isConsentChecked.value = val ?? false,
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          Text('I agree to the ', style: GoogleFonts.poppins(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w500)),
                          Text('Terms & Conditions', style: GoogleFonts.poppins(color: AppColors.primaryYellow, fontSize: 12.0, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _showTermsPopup(context),
                        child: Text('Read full terms and conditions', style: GoogleFonts.poppins(color: AppColors.greyText, fontSize: 12.0, decoration: TextDecoration.underline)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: controller.proceedToPayment,
                    icon: const Icon(Icons.payment, size: 14, color: Colors.black),
                    label: Text(
                      'Pay Now',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      );
  }

  Widget _buildCountryDropdown(String labelText, RxnString rxValue, MembershipFormController controller, {IconData? prefixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(labelText),
        Obx(() => GestureDetector(
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
                      fontWeight: rxValue.value != null ? FontWeight.bold : FontWeight.normal,
                      color: rxValue.value != null ? const Color(0xFF0D1321) : Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
              ],
            ),
          ),
        )),
      ],
    );
  }

  void _showCountryPicker(RxnString rxValue, MembershipFormController controller) {
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
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchCtrl,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.poppins(fontSize: 12.0),
                        decoration: InputDecoration(
                          hintText: 'Search country...',
                          hintStyle: GoogleFonts.poppins(color: AppColors.greyText, fontSize: 12.0),
                          prefixIcon: const Icon(Icons.search, color: AppColors.greyText, size: 18),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: AppColors.primaryYellow),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: controller.countriesList.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(color: AppColors.primaryYellow),
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
                                      color: isSelected ? AppColors.primaryYellow : AppColors.primaryBlack,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: AppColors.primaryYellow, size: 16)
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {bool readOnly = false, IconData? prefixIcon, Widget? suffixIcon, VoidCallback? onTap, Iterable<String>? autofillHints}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(labelText),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
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
            contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
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
                ? const BoxConstraints(
                    minWidth: 34,
                    minHeight: 0,
                  )
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
              borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
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
            Text('Terms & Conditions', style: GoogleFonts.poppins(fontSize: 15.0, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: AppColors.greyText, size: 20),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Membership Agreement', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.0)),
              const SizedBox(height: 2),
              Text('By purchasing a membership, you agree to abide by the rules and regulations of Own Holiday Club.', style: GoogleFonts.poppins(fontSize: 12.0, color: AppColors.greyText)),
              const SizedBox(height: 12),
              Text('2. Payment & Refunds', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.0)),
              const SizedBox(height: 2),
              Text('All membership payments are final. Refunds are subject to the cancellation policy.', style: GoogleFonts.poppins(fontSize: 12.0, color: AppColors.greyText)),
              const SizedBox(height: 12),
              Text('3. Document Verification', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.0)),
              const SizedBox(height: 2),
              Text('Your membership is subject to successful verification of your submitted KYC documents.', style: GoogleFonts.poppins(fontSize: 12.0, color: AppColors.greyText)),
              const SizedBox(height: 12),
              Text('4. Usage of Benefits', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.0)),
              const SizedBox(height: 2),
              Text('Membership benefits, including holiday packages and discounts, are non-transferable unless explicitly stated.', style: GoogleFonts.poppins(fontSize: 12.0, color: AppColors.greyText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, RxnString rxValue, List<String> items, {bool isHighlight = false, IconData? prefixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(hint),
        Obx(() => DropdownButtonFormField<String>(
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
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
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
              borderSide: BorderSide(color: isHighlight ? AppColors.primaryYellow : const Color(0xFFCED4DA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: isHighlight ? AppColors.primaryYellow : const Color(0xFFCED4DA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) rxValue.value = val;
          },
        )),
      ],
    );
  }

  Widget _buildFileRow(String label, String fileName, VoidCallback onTap, {IconData? prefixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(label),
        Container(
          height: 44,
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
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
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
                          fontSize: 11.5,
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
                      color: fileName.contains('chosen') || fileName.contains('No file') ? Colors.grey : const Color(0xFF0D1321),
                      fontSize: 11.5,
                      fontWeight: fileName.contains('chosen') || fileName.contains('No file') ? FontWeight.normal : FontWeight.bold,
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
}
