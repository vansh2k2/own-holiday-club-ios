import 'package:get/get.dart';
import 'package:own_holiday_app/modules/splash/view/splash_view.dart';
import 'package:own_holiday_app/modules/splash/controller/splash_controller.dart';

import 'package:own_holiday_app/modules/onboarding/view/onboarding_view.dart';
import 'package:own_holiday_app/modules/onboarding/controller/onboarding_controller.dart';
import 'package:own_holiday_app/modules/auth/login/view/login_view.dart';
import 'package:own_holiday_app/modules/auth/login/controller/login_controller.dart';
import 'package:own_holiday_app/modules/auth/otp/view/otp_view.dart';
import 'package:own_holiday_app/modules/auth/otp/controller/otp_controller.dart';
import 'package:own_holiday_app/modules/dashboard/view/dashboard_view.dart';
import 'package:own_holiday_app/modules/dashboard/controller/dashboard_controller.dart';
import 'package:own_holiday_app/modules/home/controller/home_controller.dart';
import 'package:own_holiday_app/modules/account/controller/account_controller.dart';
import 'package:own_holiday_app/modules/auth/member_login/view/member_login_view.dart';
import 'package:own_holiday_app/modules/auth/member_login/controller/member_login_controller.dart';
import 'package:own_holiday_app/modules/auth/member_details/view/member_details_view.dart';
import 'package:own_holiday_app/modules/auth/member_details/controller/member_details_controller.dart';

import 'package:own_holiday_app/modules/membership/view/membership_view.dart';
import 'package:own_holiday_app/modules/membership/controller/membership_controller.dart';
import 'package:own_holiday_app/modules/membership/view/membership_form_view.dart';
import 'package:own_holiday_app/modules/membership/controller/membership_form_controller.dart';
import 'package:own_holiday_app/modules/bookings/view/my_bookings_view.dart';
import 'package:own_holiday_app/modules/home/view/destinations_reel_view.dart';
import 'package:own_holiday_app/modules/home/view/gallery_view.dart';
import 'package:own_holiday_app/modules/home/view/faq_view.dart';
import 'package:own_holiday_app/modules/home/view/destination_details_view.dart';
import 'package:own_holiday_app/modules/home/view/service_details_view.dart';
import 'package:own_holiday_app/modules/home/view/services_reel_view.dart';
import 'package:own_holiday_app/modules/account/view/privacy_policy_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: BindingsBuilder(() {
        Get.put(OtpController());
      }),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        Get.put(HomeController());
        Get.put(AccountController());
      }),
    ),
    GetPage(
      name: _Paths.MEMBER_LOGIN,
      page: () => const MemberLoginView(),
      binding: BindingsBuilder(() {
        Get.put(MemberLoginController());
      }),
    ),
    GetPage(
      name: _Paths.MEMBER_DETAILS,
      page: () => const MemberDetailsView(),
      binding: BindingsBuilder(() {
        Get.put(MemberDetailsController());
      }),
    ),
    GetPage(
      name: _Paths.MEMBERSHIP,
      page: () => const MembershipView(),
      binding: BindingsBuilder(() {
        Get.put(MembershipController());
      }),
    ),
    GetPage(
      name: _Paths.MEMBERSHIP_FORM,
      page: () => const MembershipFormView(),
      binding: BindingsBuilder(() {
        Get.put(MembershipFormController());
      }),
    ),
    GetPage(
      name: _Paths.DESTINATIONS_REEL,
      page: () => const DestinationsReelView(),
    ),
    GetPage(
      name: _Paths.MY_BOOKINGS,
      page: () => const MyBookingsView(),
    ),
    GetPage(
      name: _Paths.GALLERY,
      page: () => const GalleryView(),
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
    GetPage(
      name: _Paths.DESTINATION_DETAILS,
      page: () => const DestinationDetailsView(),
    ),
    GetPage(
      name: _Paths.SERVICE_DETAILS,
      page: () => const ServiceDetailsView(),
    ),
    GetPage(
      name: _Paths.SERVICES_REEL,
      page: () => const ServicesReelView(),
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
    ),
  ];
}
