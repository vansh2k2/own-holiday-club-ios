import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  List<String> _fromSuggestions = [];
  List<String> _toSuggestions = [];
  bool _isLoadingFromSuggestions = false;
  bool _isLoadingToSuggestions = false;
  Timer? _fromDebounceTimer;
  Timer? _toDebounceTimer;

  final LayerLink _fromLayerLink = LayerLink();
  final LayerLink _toLayerLink = LayerLink();
  OverlayEntry? _fromOverlayEntry;
  OverlayEntry? _toOverlayEntry;
  final GlobalKey _fromKey = GlobalKey();
  final GlobalKey _toKey = GlobalKey();
  
  bool _isMobileOtpSent = false;
  bool _isMobileVerified = false;
  bool _isSendingMobileOtp = false;
  bool _isVerifyingMobileOtp = false;
  String? _tempMobile;
  final _mobileOtpCtrl = TextEditingController();

  bool _isVerifyingEmailOtp = false;
  bool _isEmailSkipped = false;
  final _emailOtpCtrl = TextEditingController();
  bool _isSendingEmailOtp = false;
  bool _isEmailOtpSent = false;
  bool _isEmailVerified = false;
  DateTime? _startDate;
  DateTime? _endDate;
  int _adults = 2;
  int _children = 0;
  bool _isSubmitting = false;

  late final ServiceRepo _serviceRepo;
  
  @override
  
  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromDebounceTimer?.cancel();
    _toDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ServiceRepo>()) {
      Get.put(ServiceRepo(apiClient: Get.find()));
    }
    _serviceRepo = Get.find<ServiceRepo>();
  }

  
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13.5,
        color: Colors.grey,
      ),
      prefixIcon: Icon(icon, size: 18, color: Colors.grey),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 0,
      ),
      constraints: const BoxConstraints(maxHeight: 44),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
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
        borderSide: const BorderSide(
          color: Color(0xFF000000),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isLoading,
    required Function(String) onChanged,
    required LayerLink layerLink,
    required GlobalKey fieldKey,
    required bool isFrom,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        CompositedTransformTarget(
          link: layerLink,
          child: Container(
            key: fieldKey,
            child: TextFormField(
              controller: controller,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D1321),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.grey,
                ),
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 0,
                ),
                constraints: const BoxConstraints(maxHeight: 44),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
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
                  borderSide: const BorderSide(
                    color: Color(0xFF000000),
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) {
                if (isFrom) {
                  _hideOverlay(false);
                } else {
                  _hideOverlay(true);
                }
                onChanged(val);
              },
              onTap: () {
                if (isFrom) {
                  _hideOverlay(false);
                } else {
                  _hideOverlay(true);
                }
                _updateOverlay(isFrom);
              },
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
          ),
        ),
      ],
    );
  }



  void _hideOverlay(bool isFrom) {
    if (isFrom) {
      _fromOverlayEntry?.remove();
      _fromOverlayEntry = null;
    } else {
      _toOverlayEntry?.remove();
      _toOverlayEntry = null;
    }
  }

  void _updateOverlay(bool isFrom) {
    _hideOverlay(isFrom);
    final suggestions = isFrom ? _fromSuggestions : _toSuggestions;
    if (suggestions.isEmpty) return;

    final key = isFrom ? _fromKey : _toKey;
    final layerLink = isFrom ? _fromLayerLink : _toLayerLink;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final dx = renderBox.localToGlobal(Offset.zero).dx;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(-dx + 20, size.height + 4),
          child: _buildSuggestionList(isFrom),
        ),
      ),
    );

    if (isFrom) {
      _fromOverlayEntry = entry;
      Overlay.of(context).insert(_fromOverlayEntry!);
    } else {
      _toOverlayEntry = entry;
      Overlay.of(context).insert(_toOverlayEntry!);
    }
  }

  Widget _buildSuggestionList(bool isFrom) {
    final suggestions = isFrom ? _fromSuggestions : _toSuggestions;
    return TapRegion(
      groupId: isFrom ? 'from' : 'to',
      onTapOutside: (_) => _hideOverlay(isFrom),
      child: Material(
        elevation: 8,
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFFCED4DA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isFrom) {
                      _fromController.text = suggestions[index];
                      _fromSuggestions = [];
                    } else {
                      _toController.text = suggestions[index];
                      _toSuggestions = [];
                    }
                  });
                  _hideOverlay(isFrom);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: index == suggestions.length - 1
                            ? Colors.transparent
                            : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          suggestions[index],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _fetchLocationSuggestions(String query, bool isFrom) async {
    if (query.length < 2) {
      setState(() {
        if (isFrom) {
          _fromSuggestions = [];
        } else {
          _toSuggestions = [];
        }
      });
      _updateOverlay(isFrom);
      return;
    }

    setState(() {
      if (isFrom) {
        _isLoadingFromSuggestions = true;
      } else {
        _isLoadingToSuggestions = true;
      }
    });

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
            final parsed = suggestions
                .map((s) => s['placePrediction']['text']['text'].toString())
                .toList();
            if (isFrom) {
              _fromSuggestions = parsed;
            } else {
              _toSuggestions = parsed;
            }
          });
          _updateOverlay(isFrom);
        } else {
          setState(() {
            if (isFrom) {
              _fromSuggestions = [];
            } else {
              _toSuggestions = [];
            }
          });
          _updateOverlay(isFrom);
        }
      } else {
        setState(() {
          if (isFrom) {
            _fromSuggestions = [];
          } else {
            _toSuggestions = [];
          }
        });
        _updateOverlay(isFrom);
      }
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
      setState(() {
        if (isFrom) {
          _fromSuggestions = [];
        } else {
          _toSuggestions = [];
        }
      });
      _updateOverlay(isFrom);
    } finally {
      setState(() {
        if (isFrom) {
          _isLoadingFromSuggestions = false;
        } else {
          _isLoadingToSuggestions = false;
        }
      });
    }
  }

  void _onFromChanged(String val) {
    if (_fromDebounceTimer?.isActive ?? false) _fromDebounceTimer!.cancel();
    _fromDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchLocationSuggestions(val, true);
    });
  }

  void _onToChanged(String val) {
    if (_toDebounceTimer?.isActive ?? false) _toDebounceTimer!.cancel();
    _toDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchLocationSuggestions(val, false);
    });
  }

  Future<void> _sendMobileOtp() async {
    final mobile = _phoneController.text.trim();
    if (mobile.length != 10) {
      Get.snackbar("Error", "Please enter a valid 10-digit mobile number.");
      return;
    }
    setState(() {
      _isSendingMobileOtp = true;
      _tempMobile = mobile;
    });
    try {
      final res = await _serviceRepo.sendMobileOtp(mobile);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          _isMobileOtpSent = true;
          _isMobileVerified = false;
        });
        Get.snackbar("OTP Sent", body['message'] ?? "Verification OTP sent to your mobile.");
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
    final otp = _mobileOtpCtrl.text.trim();
    if (otp.length != 6) {
      Get.snackbar("Error", "Please enter 6-digit OTP code.");
      return;
    }
    setState(() => _isVerifyingMobileOtp = true);
    try {
      final res = await _serviceRepo.verifyMobileOtp(mobile, otp);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['verified'] == true) {
        setState(() => _isMobileVerified = true);
        Get.snackbar("Success", body['message'] ?? "Phone number verified successfully!");
      } else {
        Get.snackbar("Error", body['message'] ?? "Invalid or expired OTP code.");
      }
    } catch (e) {
      Get.snackbar("Error", "OTP verification failed. Please try again.");
    } finally {
      setState(() => _isVerifyingMobileOtp = false);
    }
  }

  Future<void> _sendEmailOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar("Error", "Please enter a valid email address.");
      return;
    }
    setState(() => _isSendingEmailOtp = true);
    try {
      final res = await _serviceRepo.sendEmailOtp(email);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          _isEmailOtpSent = true;
          _isEmailVerified = false;
        });
        Get.snackbar("OTP Sent", body['message'] ?? "Verification OTP sent to your email.");
      } else {
        Get.snackbar("Error", body['message'] ?? "Failed to send email OTP.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send email OTP. Please try again.");
    } finally {
      setState(() => _isSendingEmailOtp = false);
    }
  }

  Future<void> _verifyEmailOtp() async {
    final email = _emailController.text.trim();
    final otp = _emailOtpCtrl.text.trim();
    if (otp.length != 6) {
      Get.snackbar("Error", "Please enter 6-digit OTP code.");
      return;
    }
    setState(() => _isVerifyingEmailOtp = true);
    try {
      final res = await _serviceRepo.verifyEmailOtp(email, otp);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['verified'] == true) {
        setState(() => _isEmailVerified = true);
        Get.snackbar("Success", body['message'] ?? "Email verified successfully!");
      } else {
        Get.snackbar("Error", body['message'] ?? "Invalid or expired OTP code.");
      }
    } catch (e) {
      Get.snackbar("Error", "OTP verification failed. Please try again.");
    } finally {
      setState(() => _isVerifyingEmailOtp = false);
    }
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
        "destinationName": _toController.text,
        "fromLocation": _fromController.text,
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
                
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Phone Number",
                      style: GoogleFonts.montserrat(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (_isMobileOtpSent && !_isMobileVerified)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isMobileOtpSent = false;
                            if (_tempMobile != null) {
                              _phoneController.text = _tempMobile!;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'EDIT NUMBER',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_isMobileVerified,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D1321),
                        ),
                        decoration: _inputDecoration(
                          _isMobileVerified ? 'Verified Phone' : '10-digit mobile number',
                          Icons.phone_outlined,
                        ),
                        onChanged: (val) {
                          if (_isMobileOtpSent) {
                            setState(() {
                              _isMobileOtpSent = false;
                              _mobileOtpCtrl.clear();
                            });
                          }
                        },
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _isMobileVerified
                        ? Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(5),
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
                            height: 38,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryYellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isSendingMobileOtp || _isVerifyingMobileOtp
                                  ? null
                                  : (_isMobileOtpSent ? _verifyMobileOtp : _sendMobileOtp),
                              child: _isSendingMobileOtp || _isVerifyingMobileOtp
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isMobileOtpSent ? "VERIFY" : "SEND OTP",
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
                if (_isMobileOtpSent && !_isMobileVerified) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFEDEFF2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _mobileOtpCtrl,
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
                                fontSize: 13,
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
                              borderRadius: BorderRadius.circular(5),
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
                const SizedBox(height: 16),

                
                
                Text(
                  "Email Address",
                  style: GoogleFonts.montserrat(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isEmailVerified && !_isEmailSkipped,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0D1321),
                        ),
                        decoration: _inputDecoration(
                          "you@example.com",
                          Icons.email_outlined,
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty || !v.contains('@'))
                            ? "Required"
                            : null,
                        onChanged: (val) {
                          if (_isEmailOtpSent) {
                            setState(() {
                              _isEmailOtpSent = false;
                              _emailOtpCtrl.clear();
                            });
                          }
                        },
                      ),
                    ),
                    if (!_isEmailSkipped) ...[
                      const SizedBox(width: 10),
                      _isEmailVerified
                          ? Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(5),
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
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 38,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryYellow,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: _isSendingEmailOtp
                                        ? null
                                        : _sendEmailOtp,
                                    child: _isSendingEmailOtp
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _isEmailOtpSent
                                                ? "RESEND"
                                                : "SEND OTP",
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isEmailSkipped = true;
                                      _isEmailOtpSent = false;
                                      _emailOtpCtrl.clear();
                                    });
                                  },
                                  child: Text(
                                    "SKIP",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6B7280),
                                      decoration: TextDecoration.underline,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ],
                ),
                if (_isEmailOtpSent &&
                    !_isEmailVerified &&
                    !_isEmailSkipped) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFEDEFF2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailOtpCtrl,
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
                                fontSize: 13,
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
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: _isVerifyingEmailOtp
                              ? null
                              : _verifyEmailOtp,
                          child: _isVerifyingEmailOtp
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
                const SizedBox(height: 16),

                
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildLocationField(
                        label: "CURRENT CITY",
                        hint: "Where are you now?",
                        controller: _fromController,
                        isLoading: _isLoadingFromSuggestions,
                        onChanged: _onFromChanged,
                        layerLink: _fromLayerLink,
                        fieldKey: _fromKey,
                        isFrom: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLocationField(
                        label: "DESTINATION",
                        hint: "Search destination...",
                        controller: _toController,
                        isLoading: _isLoadingToSuggestions,
                        onChanged: _onToChanged,
                        layerLink: _toLayerLink,
                        fieldKey: _toKey,
                        isFrom: false,
                      ),
                    ),
                  ],
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
                  isSelected ? DateFormat('MM/dd/yyyy').format(date) : hint,
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
