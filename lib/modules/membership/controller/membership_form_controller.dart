import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:own_holiday_app/data/repository/membership_repo.dart';
import 'package:own_holiday_app/data/repository/auth_repo.dart';
import 'package:own_holiday_app/modules/auth/login/model/user_model.dart';
import 'package:own_holiday_app/modules/account/controller/account_controller.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import 'package:own_holiday_app/modules/membership/model/membership_tier.dart';
import 'package:own_holiday_app/routes/app_pages.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:own_holiday_app/utils/razorpay_web_platform.dart';

class MembershipFormController extends GetxController {
  final MembershipRepo membershipRepo = Get.find();
  final AuthRepo authRepo = Get.find();
  late Razorpay _razorpay;

  var currentStep = 1.obs;
  var isLoading = false.obs;
  var isSaved = false.obs;
  Map<String, dynamic>? savedRazorpayOptions;

  late MembershipTier selectedTier;

  // Controllers for Step 1
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final mobileController = TextEditingController();
  final mobileOtpController = TextEditingController();
  final emailController = TextEditingController();
  final emailOtpController = TextEditingController();
  final anniversaryController = TextEditingController();
  final referralCodeController = TextEditingController();
  var isReferralCodeValid = false.obs;
  var isReferralCodeChecking = false.obs;

  // Permanent (Residence) Address Controllers
  final houseNoController = TextEditingController();
  final residenceAddressController = TextEditingController();
  final residenceCityController = TextEditingController();
  final pinController = TextEditingController();

  // Correspondence Address Controllers
  final corrHouseNoController = TextEditingController();
  final corrAddressController = TextEditingController();
  final corrCityController = TextEditingController();
  final corrPinController = TextEditingController();
  var selectedStateCorrAddress = RxnString();
  var selectedCountryCorrAddress = RxnString('India');

  // "Same as Permanent" toggle for Correspondence Address
  var sameAsPermanent = false.obs;

  void syncCorrespondenceFromPermanent() {
    corrHouseNoController.text = houseNoController.text;
    corrAddressController.text = residenceAddressController.text;
    corrCityController.text = residenceCityController.text;
    corrPinController.text = pinController.text;
    selectedStateCorrAddress.value = selectedStateRes.value;
    selectedCountryCorrAddress.value = selectedCountryRes.value;
  }

  // Family Details
  final spouseNameController = TextEditingController();
  final spouseDobController = TextEditingController();
  final spouseMobileController = TextEditingController();
  final spouseEmailController = TextEditingController();

  var numberOfChildren = 0.obs;
  var childrenNameControllers = <TextEditingController>[].obs;
  var childrenGenderOptions = <RxnString>[].obs;
  var childrenDobControllers = <TextEditingController>[].obs;

  void updateChildrenCount(int count) {
    numberOfChildren.value = count;

    // Adjust lengths
    while (childrenNameControllers.length < count) {
      childrenNameControllers.add(TextEditingController());
      childrenGenderOptions.add(RxnString());
      childrenDobControllers.add(TextEditingController());
    }
    while (childrenNameControllers.length > count) {
      childrenNameControllers.removeLast().dispose();
      childrenGenderOptions.removeLast();
      childrenDobControllers.removeLast().dispose();
    }
  }

  // Office Controllers
  final officeAddressController = TextEditingController();
  final officeCityController = TextEditingController();
  final officePhoneController = TextEditingController();
  final officePinController = TextEditingController();

  // OTP Logic
  var isMobileOtpSent = false.obs;
  var isMobileVerified = false.obs;
  var isEmailOtpSent = false.obs;
  var isEmailVerified = false.obs;
  var isEmailSkipped = false.obs;
  String? _tempMobile;
  String? _tempEmail;

  // Selected dropdowns
  var selectedTitle = RxnString();
  var selectedOccupation = RxnString();
  var selectedGender = RxnString();
  var selectedMarried = RxnString();
  var selectedStateRes = RxnString();
  var selectedStateOff = RxnString();
  var selectedCountryRes = RxnString('India');
  var selectedCountryOff = RxnString('India');
  var selectedAddressProof = RxnString();

  // Countries list fetched from API
  var countriesList = <String>[].obs;

  // Toggle office address block visibility
  var showOfficeAddress = false.obs;

  // Document upload files and base64 URLs
  var profileImageFile = Rxn<PlatformFile>();
  var idProofFile = Rxn<PlatformFile>();
  var addressProofFile = Rxn<PlatformFile>();
  var profileImageBase64 = ''.obs;
  var idProofBase64 = ''.obs;
  var addressProofBase64 = ''.obs;

  // Consent
  var isConsentChecked = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedTier = Get.arguments as MembershipTier;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchCountries();
  }

  @override
  void onClose() {
    _razorpay.clear();
    // Dispose all controllers
    nameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    mobileController.dispose();
    mobileOtpController.dispose();
    emailController.dispose();
    emailOtpController.dispose();
    anniversaryController.dispose();
    referralCodeController.dispose();
    houseNoController.dispose();
    residenceAddressController.dispose();
    residenceCityController.dispose();
    pinController.dispose();
    corrHouseNoController.dispose();
    corrAddressController.dispose();
    corrCityController.dispose();
    corrPinController.dispose();
    officeAddressController.dispose();
    officeCityController.dispose();
    officePhoneController.dispose();
    officePinController.dispose();
    spouseNameController.dispose();
    spouseDobController.dispose();
    spouseMobileController.dispose();
    spouseEmailController.dispose();
    for (var c in childrenNameControllers) {
      c.dispose();
    }
    for (var c in childrenDobControllers) {
      c.dispose();
    }
    super.onClose();
  }

  Future<void> nextStep() async {
    if (currentStep.value == 1) {
      if (!isMobileVerified.value) {
        Get.snackbar('Verification Required', 'Please verify your mobile number first.');
        return;
      }
      if (!isEmailVerified.value) {
        Get.snackbar('Verification Required', 'Please verify your email address first.');
        return;
      }

      try {
        isLoading.value = true;
        final memberDetails = _buildMemberDetails();
        print("========== STEP 1 MEMBER DETAILS ==========");
        print(
          const JsonEncoder.withIndent(
            '  ',
          ).convert(memberDetails['personalDetails']),
        );
        print("===========================================");

        final saveResponse = await membershipRepo.saveMembership(
          selectedTier.id,
          memberDetails,
          referralCode: referralCodeController.text,
        );
        final saveData = _decodeApiResponse(saveResponse);
        if (saveResponse.statusCode != 200 && saveResponse.statusCode != 201) {
          throw Exception(saveData['message'] ?? 'Unable to save your details.');
        }
        isSaved.value = true;

        // Save to GetStorage (Local Storage)
        final box = GetStorage();
        await box.write(
          'membership_step1_data',
          memberDetails['personalDetails'],
        );
        print("Saved Step 1 details to local storage successfully!");

        Get.snackbar(
          'Step 1 Saved',
          'Your details are saved. Please continue with the documents.',
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
        currentStep.value = 2;
      } catch (e) {
        print("Error saving step 1 locally: $e");
        Get.snackbar(
          'Error',
          'Failed to save details locally: $e',
          backgroundColor: AppColors.brownAccent,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }

  }

  Map<String, dynamic> _decodeApiResponse(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) {
      return {
        'message': 'The server returned an empty response (${response.statusCode}).',
      };
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {
        'message': 'The server returned an invalid response (${response.statusCode}).',
      };
    } on FormatException {
      return {
        'message': response.statusCode == 404
            ? 'Membership save service is not available on the server yet. Please try again after the backend is deployed.'
            : 'The server returned an invalid response (${response.statusCode}).',
      };
    }
  }

  void previousStep() {
    if (currentStep.value == 2) {
      currentStep.value = 1;
    }
  }

  // --- Countries API ---

  Future<void> _fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final sorted = data.map((c) => c['name']['common'] as String).toList()
          ..sort((a, b) => a.compareTo(b));
        countriesList.value = sorted;
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  // --- API Methods ---

  Future<void> sendMobileOtp() async {
    if (mobileController.text.length != 10) {
      Get.snackbar('Error', 'Invalid mobile number');
      return;
    }
    try {
      isLoading.value = true;
      final mobile = mobileController.text;
      final response = await authRepo.sendMobileOtp(mobile);
      if (response.statusCode == 200) {
        _tempMobile = mobile;
        isMobileOtpSent.value = true;
        mobileController.clear();
        Get.snackbar('Success', 'OTP sent to mobile');
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyMobileOtp() async {
    if (mobileController.text.isEmpty) return;
    if (_tempMobile == null) return;
    try {
      isLoading.value = true;
      final response = await authRepo.verifyMobileOtp(
        _tempMobile!,
        mobileController.text,
      );
      if (response.statusCode == 200) {
        isMobileVerified.value = true;
        isMobileOtpSent.value = false;
        mobileController.text =
            _tempMobile!; // Restore mobile number after verification
        Get.snackbar('Success', 'Mobile verified');
      } else {
        Get.snackbar('Error', 'Invalid OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendEmailOtp() async {
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar('Error', 'Invalid email address');
      return;
    }
    try {
      isLoading.value = true;
      final email = emailController.text;
      final response = await authRepo.sendEmailOtp(email);
      if (response.statusCode == 200) {
        _tempEmail = email;
        isEmailOtpSent.value = true;
        emailController.clear();
        Get.snackbar('Success', 'OTP sent to email');
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyEmailOtp() async {
    if (emailController.text.isEmpty) return;
    if (_tempEmail == null) return;
    try {
      isLoading.value = true;
      final response = await authRepo.verifyEmailOtp(
        _tempEmail!,
        emailController.text,
      );
      if (response.statusCode == 200) {
        isEmailVerified.value = true;
        isEmailOtpSent.value = false;
        emailController.text = _tempEmail!; // Restore email after verification
        Get.snackbar('Success', 'Email verified');
      } else {
        Get.snackbar('Error', 'Invalid OTP');
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification failed');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Payment Flow ---

  Future<void> validateReferralCode() async {
    final code = referralCodeController.text.trim().toUpperCase();
    referralCodeController.text = code;

    if (code.isEmpty) {
      isReferralCodeValid.value = false;
      Get.snackbar('Referral Code', 'Please enter a referral code.');
      return;
    }

    try {
      isReferralCodeChecking.value = true;
      final response = await membershipRepo.validateReferralCode(code);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['valid'] == true) {
        isReferralCodeValid.value = true;
        Get.snackbar(
          'Referral Code',
          'Referral code applied successfully.',
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
      } else {
        isReferralCodeValid.value = false;
        Get.snackbar(
          'Invalid Referral Code',
          data['message'] ?? 'Please check the code and try again.',
        );
      }
    } catch (e) {
      isReferralCodeValid.value = false;
      Get.snackbar(
        'Referral Code Error',
        'Could not validate the referral code. Please try again.',
      );
    } finally {
      isReferralCodeChecking.value = false;
    }
  }

  Future<void> pickFile(String docType) async {
    if (docType == 'addressProof') {
      if (selectedAddressProof.value == null ||
          selectedAddressProof.value!.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'You have to select proof type first',
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        String? base64String;

        Uint8List fileBytes;
        if (file.bytes != null) {
          fileBytes = file.bytes!;
        } else if (file.path != null) {
          fileBytes = await io.File(file.path!).readAsBytes();
        } else {
          return;
        }

        final extension = file.extension?.toLowerCase() ?? 'jpeg';
        if (extension != 'pdf') {
          try {
            final codec = await ui.instantiateImageCodec(
              fileBytes,
              targetWidth: 300,
            );
            final frame = await codec.getNextFrame();
            final byteData = await frame.image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            if (byteData != null) {
              fileBytes = byteData.buffer.asUint8List();
            }
          } catch (e) {
            print("Image compression failed, using original bytes: $e");
          }
        }

        base64String = base64Encode(fileBytes);
        final mimeType = extension == 'pdf' ? 'application/pdf' : 'image/png';
        final dataUrl = 'data:$mimeType;base64,$base64String';

        if (docType == 'profileImage') {
          profileImageFile.value = file;
          profileImageBase64.value = dataUrl;
        } else if (docType == 'idProof') {
          idProofFile.value = file;
          idProofBase64.value = dataUrl;
        } else if (docType == 'addressProof') {
          addressProofFile.value = file;
          addressProofBase64.value = dataUrl;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
    }
  }

  Map<String, dynamic> _buildMemberDetails() {
    return {
      'personalDetails': {
        'firstName': nameController.text,
        'fullName': '${nameController.text} ${lastNameController.text}'.trim(),
        'email': emailController.text,
        'mobile': mobileController.text,
        'dob': dobController.text,
        'occupation': selectedOccupation.value,
        'gender': selectedGender.value,
        'maritalStatus': selectedMarried.value,
        'anniversary': selectedMarried.value == 'Married'
            ? anniversaryController.text
            : '',
        'residenceAddress': {
          'houseNo': houseNoController.text,
          'addressLine': residenceAddressController.text,
          'city': residenceCityController.text,
          'state': selectedStateRes.value,
          'country': selectedCountryRes.value,
          'pin': pinController.text,
        },
        'correspondenceAddress': sameAsPermanent.value
            ? {
                'houseNo': houseNoController.text,
                'addressLine': residenceAddressController.text,
                'city': residenceCityController.text,
                'state': selectedStateRes.value,
                'country': selectedCountryRes.value,
                'pin': pinController.text,
                'sameAsPermanent': true,
              }
            : {
                'houseNo': corrHouseNoController.text,
                'addressLine': corrAddressController.text,
                'city': corrCityController.text,
                'state': selectedStateCorrAddress.value,
                'country': selectedCountryCorrAddress.value,
                'pin': corrPinController.text,
                'sameAsPermanent': false,
              },
        'officeAddress': showOfficeAddress.value
            ? {
                'addressLine': officeAddressController.text,
                'city': officeCityController.text,
                'state': selectedStateOff.value,
                'country': selectedCountryOff.value,
                'phone': officePhoneController.text,
                'pin': officePinController.text,
              }
            : {
                'addressLine': '',
                'city': '',
                'state': '',
                'country': '',
                'phone': '',
                'pin': '',
              },
      },
      'familyDetails': {
        'spouse': {
          'name': spouseNameController.text,
          'dob': spouseDobController.text,
          'mobile': spouseMobileController.text,
          'email': spouseEmailController.text,
        },
        'children': List.generate(
          numberOfChildren.value,
          (index) => {
            'name': childrenNameControllers[index].text,
            'gender': childrenGenderOptions[index].value ?? '',
            'dob': childrenDobControllers[index].text,
          },
        ),
      },
      'documents': {
        'profileImage': {
          'name': profileImageFile.value?.name ?? '',
          'type': profileImageFile.value?.extension == 'pdf'
              ? 'application/pdf'
              : 'image/${profileImageFile.value?.extension ?? "jpeg"}',
          'size': profileImageFile.value?.size ?? 0,
          'dataUrl': profileImageBase64.value,
        },
        'idProof': {
          'name': idProofFile.value?.name ?? '',
          'type': idProofFile.value?.extension == 'pdf'
              ? 'application/pdf'
              : 'image/${idProofFile.value?.extension ?? "jpeg"}',
          'size': idProofFile.value?.size ?? 0,
          'dataUrl': idProofBase64.value,
          'proofType': 'Aadhaar',
        },
        'addressProof': {
          'name': addressProofFile.value?.name ?? '',
          'type': addressProofFile.value?.extension == 'pdf'
              ? 'application/pdf'
              : 'image/${addressProofFile.value?.extension ?? "jpeg"}',
          'size': addressProofFile.value?.size ?? 0,
          'dataUrl': addressProofBase64.value,
          'proofType': selectedAddressProof.value ?? 'PAN',
        },
      },
      'acceptedTerms': isConsentChecked.value,
    };
  }

  Future<void> proceedToPayment() async {
    if (!isSaved.value) {
      Get.snackbar('Save Required', 'Please save your details before payment.');
      return;
    }
    if (referralCodeController.text.trim().isNotEmpty &&
        !isReferralCodeValid.value) {
      await validateReferralCode();
      if (!isReferralCodeValid.value) return;
    }

    if (idProofBase64.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please upload your Aadhaar Card',
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (!isConsentChecked.value) {
      Get.snackbar(
        'Validation Error',
        'Please agree to the Terms & Conditions',
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final memberDetails = _buildMemberDetails();
      print("========== MEMBER DETAILS PAYLOAD ==========");
      print(const JsonEncoder.withIndent('  ').convert(memberDetails));
      print("============================================");

      final response = await membershipRepo.createRazorpayOrder(
        selectedTier.id,
        memberDetails,
      );
      print("========== CREATE ORDER RESPONSE ==========");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");
      print("===========================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        var options = {
          'key': data['key'],
          'amount': data['order']['amount'],
          'name': 'Own Holiday Club',
          'description': data['tier']['name'],
          'order_id': data['order']['id'],
          'prefill': {
            'contact': mobileController.text,
            'email': emailController.text,
          },
          'notes': data['order']['notes'],
        };
        if (kIsWeb) {
          openRazorpayWeb(
            options,
            _handleWebPaymentSuccess,
            _handleWebPaymentError,
          );
        } else {
          _razorpay.open(options);
        }
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      Get.snackbar('Error', 'Payment initialization failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMembershipDetails() async {
    if (idProofBase64.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please upload your Aadhaar Card',
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (!isConsentChecked.value) {
      Get.snackbar(
        'Validation Error',
        'Please agree to the Terms & Conditions',
        backgroundColor: AppColors.brownAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await membershipRepo.saveMembership(
        selectedTier.id,
        _buildMemberDetails(),
        referralCode: referralCodeController.text,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        isSaved.value = true;
        Get.snackbar(
          'Details Saved',
          'Your details were saved. You can pay now or later.',
          backgroundColor: AppColors.primaryYellow,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Save Failed', data['message'] ?? 'Unable to save details.');
      }
    } catch (e) {
      Get.snackbar('Save Failed', 'Unable to save details. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await _verifyPayment({
      'razorpay_payment_id': response.paymentId,
      'razorpay_order_id': response.orderId,
      'razorpay_signature': response.signature,
    });
  }

  Future<void> _handleWebPaymentSuccess(
    Map<String, dynamic> response,
  ) async {
    await _verifyPayment(response);
  }

  void _handleWebPaymentError(String message) {
    Get.snackbar(
      'Payment Failed',
      message,
      backgroundColor: AppColors.brownAccent,
      colorText: Colors.white,
    );
  }

  Future<void> _verifyPayment(Map<String, dynamic> paymentResponse) async {
    try {
      isLoading.value = true;
      final data = {
        'tierId': selectedTier.id,
        'memberDetails': _buildMemberDetails(),
        if (referralCodeController.text.trim().isNotEmpty)
          'referralCode': referralCodeController.text.trim().toUpperCase(),
        ...paymentResponse,
      };
      print("========== VERIFY PAYMENT REQUEST PAYLOAD ==========");
      print(const JsonEncoder.withIndent('  ').convert(data));
      print("====================================================");

      final verifyRes = await membershipRepo.verifyPayment(data);
      print("========== VERIFY PAYMENT RESPONSE ==========");
      print("Status Code: ${verifyRes.statusCode}");
      print("Body: ${verifyRes.body}");
      print("=============================================");

      if (verifyRes.statusCode == 200) {
        final verifyData = jsonDecode(verifyRes.body);
        final userModel = UserModel.fromJson(verifyData['user']);

        // Save to AccountController
        Get.find<AccountController>().userData.value = userModel;
        Get.find<AccountController>().isLoggedIn.value = true;

        Get.offAllNamed(Routes.MEMBER_DETAILS);
        Get.snackbar('Success', 'Welcome to Own Holiday Club!');
      } else {
        Get.snackbar(
          'Error',
          'Payment verification failed. Please contact support.',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Internal error during verification');
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Unknown error',
      backgroundColor: AppColors.brownAccent,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', response.walletName ?? '');
  }
}
