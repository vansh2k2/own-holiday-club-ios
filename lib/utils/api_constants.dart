class ApiConstants {
  static const String baseUrl = "https://api.ownholidayclub.com/api";
  static const String heroSlides = "$baseUrl/hero-slides";
  
  // Auth Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  
  // Membership Endpoints
  static const String membershipPlans = "$baseUrl/membership/tiers";
  static const String membershipPurchase = "$baseUrl/membership/purchase";
  
  // Dashboard & Stats
  static const String dashboardStats = "$baseUrl/dashboard/stats";
  static const String dashboardCharts = "$baseUrl/dashboard/charts";
  
  // Website Settings
  static const String settings = "$baseUrl/settings";
  static const String socialMedia = "$baseUrl/social-media";
  
  // Services
  static const String exploreServices = "$baseUrl/explore-services";
  static const String serviceDetails = "$baseUrl/service-details";
  static const String serviceEnquiries = "$baseUrl/service-enquiries";
  
  // Destinations & Content
  static const String destinations = "$baseUrl/destinations";
  static const String blogs = "$baseUrl/blogs";
  static const String faq = "$baseUrl/faq";
  
  // Payments
  static const String createOrder = "$baseUrl/payments/membership/order";
  static const String verifyPayment = "$baseUrl/payments/membership/verify";
  
  // Leads & Forms
  static const String enquiries = "$baseUrl/enquiries";
  static const String contactEnquiries = "$baseUrl/contact-enquiries";
  static const String propertyListings = "$baseUrl/property-listings";
  static const String newsletter = "$baseUrl/newsletter-subscriptions";
  static const String holidayLeads = "$baseUrl/holiday-leads";

  // User Profile
  static const String profile = "$baseUrl/profile";
  static const String members = "$baseUrl/members";
}

