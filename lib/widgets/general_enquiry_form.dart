import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/data/repository/service_repo.dart';
import 'package:own_holiday_app/modules/home/controller/home_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class GeneralEnquiryForm extends StatefulWidget {
  const GeneralEnquiryForm({super.key});

  @override
  State<GeneralEnquiryForm> createState() => _GeneralEnquiryFormState();
}

class _GeneralEnquiryFormState extends State<GeneralEnquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileOtpController = TextEditingController();
  final _emailOtpController = TextEditingController();
  final _messageController = TextEditingController();
  final _locationController = TextEditingController();
  List<String> _locationSuggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;

  bool _isSubmitting = false;

  // OTP Verification states
  bool _isSendingMobileOtp = false;
  bool _isMobileOtpSent = false;
  bool _isMobileVerified = false;
  bool _isVerifyingMobileOtp = false;

  // Preferences states
  String _locationType = 'Domestic';
  String _selectedDestination = '';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 1;
  int _kids = 0;
  String _travelType = 'Holiday';
  String _selectedBudget = '';

  List<dynamic> _destinations = [];
  bool _isLoadingDestinations = false;

  late final ServiceRepo _serviceRepo;

  final Map<String, List<Map<String, String>>> _budgetOptions = {
    'Holiday': [
      {'label': 'Below 5,000 (per day)', 'value': 'Below 5000'},
      {'label': '5,000 - 7,000 (per day)', 'value': '5000 - 7000'},
      {'label': '7,000 - 10,000 (per day)', 'value': '7000 - 10000'},
      {'label': 'Above 10,000 (per day)', 'value': 'Above 10000'},
    ],
    'Events': [
      {'label': 'Below 1,000 (per person)', 'value': 'Below 1000'},
      {'label': '1,000 - 2,000 (per person)', 'value': '1000 - 2000'},
      {'label': '2,000 - 3,000 (per person)', 'value': '2000 - 3000'},
      {'label': 'Above 3,000 (per person)', 'value': 'Above 3000'},
    ],
    'Wedding': [
      {'label': 'Below 1,500 (per person)', 'value': 'Below 1500'},
      {'label': '1,500 - 2,500 (per person)', 'value': '1500 - 2500'},
      {'label': '2,500 - 3,500 (per person)', 'value': '2500 - 3500'},
      {'label': 'Above 3,500 (per person)', 'value': 'Above 3500'},
    ],
    'Outing': [
      {'label': 'Below 500 (per person)', 'value': 'Below 500'},
      {'label': '1,000 - 2,000 (per person)', 'value': '1000 - 2000'},
      {'label': '3,000 - 5,000 (per person)', 'value': '3000 - 5000'},
      {'label': 'Above 5,000 (per person)', 'value': 'Above 5000'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _serviceRepo = Get.find<ServiceRepo>();
    _selectedBudget = _budgetOptions[_travelType]![0]['value']!;

    if (Get.isRegistered<HomeController>()) {
      _destinations = Get.find<HomeController>().destinations;
    }
    if (_destinations.isEmpty) {
      _fetchDestinations();
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _locationSuggestions = [];
      });
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    try {
      final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': 'AIzaSyDarNwOH5Gfi1KseDZ82fkh2b0wn66uudg',
        },
        body: jsonEncode({'input': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['suggestions'] != null) {
          final List suggestions = data['suggestions'];
          setState(() {
            _locationSuggestions = suggestions
                .map((s) => s['placePrediction']['text']['text'].toString())
                .toList();
          });
        } else {
          setState(() {
            _locationSuggestions = [];
          });
        }
      } else {
        setState(() {
          _locationSuggestions = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
      setState(() {
        _locationSuggestions = [];
      });
    } finally {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  void _onLocationChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchLocationSuggestions(val);
    });
  }

  Future<void> _fetchDestinations() async {
    if (!mounted) return;
    setState(() => _isLoadingDestinations = true);
    try {
      final response = await _serviceRepo.getDestinations();
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          if (!mounted) return;
          setState(() {
            _destinations = List<Map<String, dynamic>>.from(body['data']);
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading destinations: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingDestinations = false);
      }
    }
  }

  // --- OTP Actions ---

  Future<void> _sendMobileOtp() async {
    final mobile = _phoneController.text.trim();
    if (mobile.length != 10) {
      Get.snackbar("Error", "Please enter a valid 10-digit mobile number.");
      return;
    }
    setState(() => _isSendingMobileOtp = true);
    try {
      final res = await _serviceRepo.sendMobileOtp(mobile);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          _isMobileOtpSent = true;
          _isMobileVerified = false;
        });
        Get.snackbar(
          "OTP Sent",
          body['message'] ?? "Verification OTP sent to your mobile.",
        );
      } else {
        Get.snackbar("Error", body['message'] ?? "Failed to send mobile OTP.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send mobile OTP. Please try again.");
    } finally {
      setState(() => _isSendingMobileOtp = false);
    }
  }

  Future<void> _verifyMobileOtp() async {
    final mobile = _phoneController.text.trim();
    final otp = _mobileOtpController.text.trim();
    if (otp.length != 6) {
      Get.snackbar("Error", "Please enter 6-digit OTP code.");
      return;
    }
    setState(() => _isVerifyingMobileOtp = true);
    try {
      final res = await _serviceRepo.verifyMobileOtp(mobile, otp);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['verified'] == true) {
        setState(() {
          _isMobileVerified = true;
        });
        Get.snackbar(
          "Success",
          body['message'] ?? "Phone number verified successfully!",
        );
      } else {
        Get.snackbar(
          "Error",
          body['message'] ?? "Invalid or expired OTP code.",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "OTP verification failed. Please try again.");
    } finally {
      setState(() => _isVerifyingMobileOtp = false);
    }
  }



  Future<void> _submitEnquiry() async {
    if (_nameController.text.trim().length < 2) {
      Get.snackbar("Error", "Please enter your full name.");
      return;
    }
    final mobile = _phoneController.text.trim();
    if (mobile.length != 10) {
      Get.snackbar("Error", "Please enter a valid 10-digit mobile number.");
      return;
    }
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar("Error", "Please enter a valid email address.");
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a specific location.");
      return;
    }
    if (_checkInDate == null || _checkOutDate == null) {
      Get.snackbar("Error", "Please select check-in and check-out dates.");
      return;
    }
    if (_checkOutDate!.isBefore(_checkInDate!) ||
        _checkOutDate!.isAtSameMomentAs(_checkInDate!)) {
      Get.snackbar("Error", "Check-out date must be after check-in date.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> data = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "location": _locationController.text.trim(),
        "searchLocation": _locationController.text.trim(),
        "locationType": "General",
        "checkIn": DateFormat('yyyy-MM-dd').format(_checkInDate!),
        "checkOut": DateFormat('yyyy-MM-dd').format(_checkOutDate!),
        "adults": _adults,
        "kids": _kids,
        "travelType": _travelType,
        "budget": _selectedBudget,
        "message": _messageController.text.trim(),
        "source": "Mobile App Side Drawer",
        "contextType": "callback-request",
        "contextName": "Mobile Side Drawer",
      };

      final response = await _serviceRepo.submitGeneralEnquiry(data);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        Get.snackbar(
          "Error",
          body['message'] ??
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF047857),
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              "Submission Successful",
              style: GoogleFonts.montserrat(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Thank you for your interest. We will contact you shortly.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: AppColors.greyText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Close form sheet
                },
                child: Text(
                  "CLOSE",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottomPadding),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top handle bar
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Close button / title header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SEND YOUR QUERY",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1565C0),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 3,
                          margin: const EdgeInsets.only(top: 1, bottom: 0),
                          color: AppColors.primaryYellow,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Full Name
                _buildLabel("FULL NAME"),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D1321),
                  ),
                  decoration: _inputDecoration(
                    "Enter full name",
                    Icons.person_outline_rounded,
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 12),

                // Mobile Number
                _buildLabel("MOBILE NUMBER"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_isMobileVerified,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D1321),
                        ),
                        decoration: _inputDecoration(
                          "10-digit mobile number",
                          Icons.phone_android_rounded,
                        ),
                        onChanged: (val) {
                          if (_isMobileOtpSent) {
                            setState(() {
                              _isMobileOtpSent = false;
                              _mobileOtpController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    _isMobileVerified
                        ? Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF059669),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "✓ VERIFIED",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF047857),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryYellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isSendingMobileOtp
                                  ? null
                                  : _sendMobileOtp,
                              child: _isSendingMobileOtp
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isMobileOtpSent ? "RESEND" : "GET OTP",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                  ],
                ),

                // Mobile OTP verification box
                if (_isMobileOtpSent && !_isMobileVerified) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEDEFF2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _mobileOtpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter 6-digit OTP",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                letterSpacing: 0,
                                color: Colors.grey,
                              ),
                              counterText: "",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: _isVerifyingMobileOtp
                              ? null
                              : _verifyMobileOtp,
                          child: _isVerifyingMobileOtp
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "VERIFY",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Email Address
                _buildLabel("EMAIL ADDRESS *"),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D1321),
                  ),
                  decoration: _inputDecoration(
                    "email@example.com",
                    Icons.mail_outline_rounded,
                  ),
                  validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? "Required" : null,
                ),
                const SizedBox(height: 12),

                _buildLocationAutocompleteField(),
                const SizedBox(height: 12),

                // Check-in & Check-out in a single Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("CHECK-IN"),
                          _buildDatePickerButton(
                            label: _checkInDate == null
                                ? "mm/dd/yyyy"
                                : DateFormat('MM/dd/yyyy').format(_checkInDate!),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 2),
                                ),
                              );
                              if (date != null) {
                                setState(() {
                                  _checkInDate = date;
                                  if (_checkOutDate != null &&
                                      _checkOutDate!.isBefore(_checkInDate!)) {
                                    _checkOutDate = null;
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("CHECK-OUT"),
                          _buildDatePickerButton(
                            label: _checkOutDate == null
                                ? "mm/dd/yyyy"
                                : DateFormat('MM/dd/yyyy').format(_checkOutDate!),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    _checkInDate?.add(const Duration(days: 1)) ??
                                    DateTime.now(),
                                firstDate:
                                    _checkInDate?.add(const Duration(days: 1)) ??
                                    DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 2),
                                ),
                              );
                              if (date != null) {
                                setState(() {
                                  _checkOutDate = date;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Adults & Kids in a single Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("ADULTS"),
                          DropdownButtonFormField<int>(
                            value: _adults,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D1321),
                            ),
                            decoration: _inputDecoration(
                              null,
                              Icons.people_outline_rounded,
                            ),
                            items: List.generate(10, (i) => i + 1).map((n) {
                              return DropdownMenuItem<int>(
                                value: n,
                                child: Text("$n Adult${n > 1 ? 's' : ''}"),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _adults = val ?? 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("KIDS (BELOW 10 YEARS)"),
                          DropdownButtonFormField<int>(
                            value: _kids,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D1321),
                            ),
                            decoration: _inputDecoration(null, Icons.child_care_rounded),
                            items: List.generate(7, (i) => i).map((n) {
                              return DropdownMenuItem<int>(
                                value: n,
                                child: Text("$n Kid${n != 1 ? 's' : ''}"),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _kids = val ?? 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Budget Dropdown Options
                _buildLabel("SELECT YOUR BUDGET"),
                DropdownButtonFormField<String>(
                  value: _selectedBudget,
                  dropdownColor: Colors.white,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D1321),
                  ),
                  decoration: _inputDecoration(null, Icons.payments_outlined),
                  items: _budgetOptions[_travelType]!
                      .map<DropdownMenuItem<String>>((opt) {
                        return DropdownMenuItem<String>(
                          value: opt['value'],
                          child: Text(opt['label']!),
                        );
                      })
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedBudget = val ?? ''),
                ),
                const SizedBox(height: 12),

                // Special Request
                _buildLabel("SPECIAL REQUEST (OPTIONAL)"),
                TextFormField(
                  controller: _messageController,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0D1321),
                  ),
                  decoration: _inputDecoration(
                    "Any special request? Let us know!",
                    Icons.message_outlined,
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _submitEnquiry,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlack,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "CONFIRM REQUEST",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.send_rounded, size: 14),
                            ],
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
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required VoidCallback onTap,
  }) {
    final hasDate = label != "mm/dd/yyyy";

    return InkWell(
      onTap: onTap,

      child: Container(
        height: 48,

        padding: const EdgeInsets.symmetric(horizontal: 10),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(10),

          border: Border.all(color: const Color(0xFFCED4DA)),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: Colors.grey,
            ),

            const SizedBox(width: 8),

            Text(
              label,

              style: GoogleFonts.poppins(
                fontSize: 11.5,

                fontWeight: hasDate ? FontWeight.bold : FontWeight.normal,

                color: hasDate ? const Color(0xFF0D1321) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAutocompleteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _buildLabel("SPECIFIC LOCATION"),

        TextFormField(
          controller: _locationController,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D1321),
          ),
          decoration: InputDecoration(
            hintText: "Search precise location...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: Colors.grey,
            ),
            suffixIcon: _isLoadingSuggestions
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF000000),
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCED4DA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCED4DA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF000000),
                width: 1.5,
              ),
            ),
          ),

          onChanged: _onLocationChanged,

          validator: (v) => v!.isEmpty ? "Required" : null,
        ),

        if (_locationSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),

          Container(
            constraints: const BoxConstraints(maxHeight: 200),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(10),

              border: Border.all(color: const Color(0xFFCED4DA)),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),

                  blurRadius: 5,

                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: ListView.separated(
              shrinkWrap: true,

              padding: EdgeInsets.zero,

              itemCount: _locationSuggestions.length,

              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFEDEFF2)),

              itemBuilder: (context, index) {
                final suggestion = _locationSuggestions[index];

                return ListTile(
                  dense: true,

                  title: Text(
                    suggestion,

                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF0D1321),
                    ),
                  ),

                  onTap: () {
                    setState(() {
                      _locationController.text = suggestion;

                      _locationSuggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
      prefixIcon: Icon(icon, size: 18, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),

      isDense: true,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(color: Color(0xFFCED4DA)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(color: Color(0xFFCED4DA)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
      ),
    );
  }
}
