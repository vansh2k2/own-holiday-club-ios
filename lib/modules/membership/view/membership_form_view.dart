import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import '../controller/membership_form_controller.dart';
import 'package:intl/intl.dart';

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
                foregroundColor: AppColors.primaryBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                elevation: 0,
              ),
              onPressed: () => Get.toNamed(Routes.MEMBER_LOGIN),
              child: const Text('MEMBER LOGIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.primaryYellow),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PACKAGE NAME', style: TextStyle(color: AppColors.primaryYellow, fontSize: 8, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(controller.selectedTier.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlack), overflow: TextOverflow.ellipsis),
                            Text(controller.selectedTier.duration ?? 'Long Term Access', style: const TextStyle(fontSize: 9, color: AppColors.greyText), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlack,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(6)),
                                  child: const Icon(Icons.account_balance_wallet, size: 12, color: AppColors.primaryBlack),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(child: Text('TOTAL PAYABLE', style: TextStyle(color: AppColors.primaryYellow, fontSize: 8, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('₹${controller.selectedTier.price}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PROGRESS', style: TextStyle(color: AppColors.greyText, fontSize: 8, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Step ${controller.currentStep.value} of 2', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                            Text(controller.currentStep.value == 1 ? 'Personal details' : 'Documents', style: const TextStyle(fontSize: 9, color: AppColors.greyText), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      )),
                    ),
                  ],
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
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
              )
            : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext context, MembershipFormController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PERSONAL DETAIL', style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(flex: 3, child: _buildDropdown('Title', controller.selectedTitle, ['Mr.', 'Mrs.', 'Ms.', 'Dr.'])),
              const SizedBox(width: 10),
              Expanded(flex: 7, child: _buildTextField('First Name', controller.nameController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField('Last Name', controller.lastNameController)),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  'DOB (DD-MM-YYYY)',
                  controller.dobController,
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.greyText),
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
          Obx(() => _buildTextField(
            controller.isMobileVerified.value 
                ? 'Mobile Number' 
                : (controller.isMobileOtpSent.value ? 'Enter OTP' : 'Mobile Number'), 
            controller.mobileController,
            readOnly: controller.isMobileVerified.value,
            autofillHints: (controller.isMobileOtpSent.value && !controller.isMobileVerified.value) ? const [AutofillHints.oneTimeCode] : null,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: controller.isMobileVerified.value 
                ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isMobileOtpSent.value ? AppColors.primaryBlack : AppColors.primaryYellow,
                      foregroundColor: controller.isMobileOtpSent.value ? AppColors.primaryYellow : AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      elevation: 0,
                      minimumSize: const Size(60, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: controller.isMobileOtpSent.value ? controller.verifyMobileOtp : controller.sendMobileOtp,
                    child: Text(
                      controller.isMobileOtpSent.value ? 'Verify' : 'Send OTP', 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ),
            ),
          )),
          const SizedBox(height: 12),
          // Email Address Field
          Obx(() => _buildTextField(
            controller.isEmailVerified.value 
                ? 'Email Address' 
                : (controller.isEmailOtpSent.value ? 'Enter OTP' : 'Email Address'), 
            controller.emailController,
            readOnly: controller.isEmailVerified.value,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: controller.isEmailVerified.value 
                ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isEmailOtpSent.value ? AppColors.primaryBlack : AppColors.primaryYellow,
                      foregroundColor: controller.isEmailOtpSent.value ? AppColors.primaryYellow : AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      elevation: 0,
                      minimumSize: const Size(60, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: controller.isEmailOtpSent.value ? controller.verifyEmailOtp : controller.sendEmailOtp,
                    child: Text(
                      controller.isEmailOtpSent.value ? 'Verify' : 'Send OTP', 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ),
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdown('Occupation', controller.selectedOccupation, ['Business', 'Private Job', 'Government Job', 'Professional', 'Self Employed', 'Homemaker', 'Retired', 'Student', 'Other'])),
              const SizedBox(width: 10),
              Expanded(child: _buildDropdown('Gender', controller.selectedGender, ['Male', 'Female', 'Other'])),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final isMarried = controller.selectedMarried.value == 'Married';
            return Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Married', 
                    controller.selectedMarried, 
                    ['Married', 'Single', 'Separated'],
                  ),
                ),
                if (isMarried) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      'Anniversary',
                      controller.anniversaryController,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.greyText),
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
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: 24),
          const Text('ADDRESS', style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          _buildTextField('House No. / Block No.', controller.houseNoController),
          const SizedBox(height: 12),
          _buildTextField('Residence Address', controller.residenceAddressController),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField('Residence City', controller.residenceCityController)),
              const SizedBox(width: 10),
              Expanded(child: _buildDropdown('State', controller.selectedStateRes, ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman & Nicobar Islands', 'Chandigarh', 'Dadra & Nagar Haveli and Daman & Diu', 'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildCountryDropdown(controller.selectedCountryRes, controller)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField('Pin Code', controller.pinController)),
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
                  color: AppColors.primaryYellow,
                ),
                const SizedBox(width: 6),
                Text(
                  controller.showOfficeAddress.value ? 'Remove Office Address' : 'Add Office Address (Optional)',
                  style: const TextStyle(
                    color: AppColors.primaryYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
                const Text('OFFICE ADDRESS (OPTIONAL)', style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 12),
                _buildTextField('Office Address', controller.officeAddressController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Office City', controller.officeCityController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDropdown('State', controller.selectedStateOff, ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman & Nicobar Islands', 'Chandigarh', 'Dadra & Nagar Haveli and Daman & Diu', 'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildCountryDropdown(controller.selectedCountryOff, controller)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField('Pin', controller.officePinController)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Phone', controller.officePhoneController),
              ],
            );
          }),
          Obx(() => SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: controller.isLoading.value ? null : controller.nextStep,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBlack,
                      ),
                    )
                  : const Text('Next Step ➔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, MembershipFormController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DOCUMENTS', style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          Obx(() => _buildFileRow(
            'Profile Image',
            controller.profileImageFile.value?.name ?? 'No file chosen',
            () => controller.pickFile('profileImage'),
          )),
          const SizedBox(height: 12),
          Obx(() => _buildFileRow(
            'Aadhaar Card',
            controller.idProofFile.value?.name ?? 'No file chosen',
            () => controller.pickFile('idProof'),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildDropdown('Address Proof', controller.selectedAddressProof, ['Passport', 'Gov ID', 'PAN Card', 'Driving Licence', 'Voter ID'], isHighlight: true),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => controller.pickFile('addressProof'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                            border: Border(right: BorderSide(color: AppColors.lightGrey)),
                          ),
                          child: const Text('↑ Choose', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Obx(() => Text(
                            controller.addressProofFile.value?.name ?? 'No file',
                            style: const TextStyle(color: AppColors.greyText, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('CONSENT', style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
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
                    checkColor: AppColors.primaryBlack,
                    onChanged: (val) => controller.isConsentChecked.value = val ?? false,
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Wrap(
                        children: [
                          Text('I agree to the ', style: TextStyle(color: AppColors.primaryBlack, fontSize: 12)),
                          Text('Terms & Conditions', style: TextStyle(color: AppColors.primaryYellow, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _showTermsPopup(context),
                        child: const Text('Read full terms and conditions', style: TextStyle(color: AppColors.greyText, fontSize: 11, decoration: TextDecoration.underline)),
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
                      foregroundColor: AppColors.primaryBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: controller.previousStep,
                    icon: const Icon(Icons.arrow_back, size: 14),
                    label: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                      foregroundColor: AppColors.primaryBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: controller.proceedToPayment,
                    icon: const Icon(Icons.payment, size: 14),
                    label: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCountryDropdown(RxnString rxValue, MembershipFormController controller) {
    return Obx(() => GestureDetector(
      onTap: () => _showCountryPicker(rxValue, controller),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                rxValue.value ?? 'Select Country',
                style: TextStyle(
                  fontSize: 12,
                  color: rxValue.value != null ? AppColors.primaryBlack : AppColors.greyText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.greyText, size: 16),
          ],
        ),
      ),
    ));
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
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search country...',
                          hintStyle: const TextStyle(color: AppColors.greyText, fontSize: 12),
                          prefixIcon: const Icon(Icons.search, color: AppColors.greyText, size: 18),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildTextField(String hint, TextEditingController controller, {bool readOnly = false, Widget? suffixIcon, VoidCallback? onTap, Iterable<String>? autofillHints}) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        autofillHints: autofillHints,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.greyText, fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryYellow),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
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
            const Text('Terms & Conditions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: AppColors.greyText, size: 20),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Membership Agreement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('By purchasing a membership, you agree to abide by the rules and regulations of Own Holiday Club.', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
              SizedBox(height: 12),
              Text('2. Payment & Refunds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('All membership payments are final. Refunds are subject to the cancellation policy.', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
              SizedBox(height: 12),
              Text('3. Document Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Your membership is subject to successful verification of your submitted KYC documents.', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
              SizedBox(height: 12),
              Text('4. Usage of Benefits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Membership benefits, including holiday packages and discounts, are non-transferable unless explicitly stated.', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, RxnString rxValue, List<String> items, {bool isHighlight = false}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: isHighlight ? AppColors.primaryYellow : AppColors.lightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<String>(
          isExpanded: true,
          menuMaxHeight: 300,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.greyText, size: 16),
          hint: Text(hint, style: const TextStyle(color: AppColors.greyText, fontSize: 12), overflow: TextOverflow.ellipsis),
          value: rxValue.value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (val) {
            if (val != null) rxValue.value = val;
          },
        )),
      ),
    );
  }

  Widget _buildFileRow(String label, String fileName, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.primaryBlack, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      border: Border(right: BorderSide(color: AppColors.lightGrey)),
                    ),
                    child: const Text('↑ Choose', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(fileName, style: const TextStyle(color: AppColors.greyText, fontSize: 11), overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
