import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/data/repository/service_repo.dart';

class EnquiryFormSheet extends StatefulWidget {
  final Map<String, dynamic> destination;
  const EnquiryFormSheet({super.key, required this.destination});

  @override
  State<EnquiryFormSheet> createState() => _EnquiryFormSheetState();
}

class _EnquiryFormSheetState extends State<EnquiryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  int _adults = 2;
  int _children = 0;
  bool _isSubmitting = false;

  late final ServiceRepo _serviceRepo;
  
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ServiceRepo>()) {
      Get.put(ServiceRepo(apiClient: Get.find()));
    }
    _serviceRepo = Get.find<ServiceRepo>();
  }

  Future<void> _submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> data = {
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "destinationId": widget.destination['id'] ?? widget.destination['_id'],
        "destinationName": widget.destination['name'] ?? widget.destination['title'],
        "startDate": _startDate?.toIso8601String(),
        "endDate": _endDate?.toIso8601String(),
        "adults": _adults,
        "children": _children,
        "message": _messageController.text,
        "source": "Mobile App Destination Reel"
      };

      final response = await _serviceRepo.submitDestinationEnquiry(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          "Success", 
          "Your enquiry has been submitted successfully. Our team will contact you soon.",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error", 
          "Failed to submit enquiry. Please try again later.",
          backgroundColor: AppColors.brownAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Something went wrong. Please check your connection.",
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Request an Itinerary",
                  style: GoogleFonts.montserrat(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Complete the details below to begin planning your journey to ${widget.destination['name'] ?? widget.destination['title']}.",
                  style: GoogleFonts.montserrat(
                    fontSize: 12.0,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _nameController,
                  label: "Full Name",
                  hint: "Enter your full name",
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _phoneController,
                  label: "Phone Number",
                  hint: "10-digit mobile number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _emailController,
                  label: "Email Address",
                  hint: "you@example.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@') ? "Valid email required" : null,
                ),
                const SizedBox(height: 16),
                
                _buildDatePicker(
                  label: "Arrival Date",
                  hint: "Add date",
                  date: _startDate,
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) setState(() => _startDate = date);
                  },
                ),
                const SizedBox(height: 16),
                _buildDatePicker(
                  label: "Departure Date",
                  hint: "Add date",
                  date: _endDate,
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate?.add(const Duration(days: 1)) ?? DateTime.now(),
                      firstDate: _startDate?.add(const Duration(days: 1)) ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) setState(() => _endDate = date);
                  },
                ),
                const SizedBox(height: 16),
                
                _buildCounterField(
                  label: "Adults Count",
                  icon: Icons.group_outlined,
                  value: _adults,
                  onChanged: (v) => setState(() => _adults = v),
                ),
                const SizedBox(height: 16),
                _buildCounterField(
                  label: "Kids (< 10 yrs)",
                  icon: Icons.child_care_outlined,
                  value: _children,
                  onChanged: (v) => setState(() => _children = v),
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _messageController,
                  label: "Special Requests or Preferences... (Optional)",
                  hint: "Any specific needs or occasions...",
                  icon: Icons.message_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : _submitEnquiry,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SUBMIT INQUIRY",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11.5,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.send_rounded, size: 12),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "YOUR INFORMATION IS STRICTLY CONFIDENTIAL.",
                    style: GoogleFonts.montserrat(
                      fontSize: 9.0,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  InputDecoration _inputDecoration(String? hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
      prefixIcon: Icon(icon, size: 18, color: Colors.grey),
      prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
      constraints: const BoxConstraints(maxHeight: 44),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      isDense: true,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0D1321),
          ),
          decoration: _inputDecoration(hint, icon ?? Icons.text_fields),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String hint,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isSelected = date != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFFCED4DA)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey),
                const SizedBox(width: 14),
                Text(
                  isSelected ? DateFormat('MM/dd/yyyy').format(date!) : hint,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0D1321) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterField({
    required String label,
    required IconData icon,
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFFCED4DA)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: const Color(0xFF0D1321),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  if (value > 0) onChanged(value - 1);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.remove, size: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  onChanged(value + 1);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
