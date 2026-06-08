import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_holiday_app/utils/app_colors.dart';
import '../../home/controller/home_controller.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  final HomeController controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // Hit CMS pages API immediately on page entry to search for policies
    controller.fetchCmsPages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: AppColors.primaryBlack,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryBlack, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isCmsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryYellow,
            ),
          );
        }

        // If dynamic Privacy Policy is loaded from the CMS API, render it
        if (controller.privacyPolicyContent.value.trim().isNotEmpty) {
          return RefreshIndicator(
            color: AppColors.primaryYellow,
            onRefresh: () => controller.fetchCmsPages(),
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGrey.withOpacity(0.5), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.softYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security_rounded, size: 20, color: AppColors.primaryYellow),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Dynamic Policy from Server',
                          style: GoogleFonts.montserrat(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  controller.privacyPolicyTitle.value,
                  style: GoogleFonts.montserrat(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  controller.privacyPolicyContent.value,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.0,
                    color: AppColors.bodyText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            ),  // SingleChildScrollView
          );  // RefreshIndicator
        }

        // Static Fallback View (Highly styled and readable)
        return RefreshIndicator(
          color: AppColors.primaryYellow,
          onRefresh: () => controller.fetchCmsPages(),
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro Card (Border fixed: uniform border with yellow bar inside)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGrey.withOpacity(0.5), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Inner Accent Stripe to replace non-uniform border
                    Container(
                      width: 4,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.softYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security_rounded, size: 20, color: AppColors.primaryYellow),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'By visiting website www.ownholidayclub.com and our mobile application you are accepting the terms stated hereunder relating to privacy. It explains how RHSPL handles personal information and complies with the requirements of the privacy act. If you have further questions relating to this policy please contact our member experience management team by e-mail at membership@ownholidayclub.com.',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.5,
                          color: AppColors.bodyText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildSection(
                'Collecting Information About You',
                'In accordance with the applicable acts governing privacy, RHSPL only collects personal information that is necessary for business purposes. We endeavour at all times to collect personal information in a fair and lawful manner, and to meet our members\' expectations that we will respect their right to control how their personal information is collected and used. RHSPL collects personal information to be used for the purpose of its business. These include:\n\n• Prior and Post purchase of RHSPL’s Membership, Exchange program: RHSPL collects information about members and prospects at the time when a person first joins a program and while a person is a member. The main categories of information we collect relate to a person\'s general contact information, personal details including spouse/family members details such as name, age range, gender, demographic information like post code, preferences, interest, professional details, address, contact information including e-mail address, use of the program, payment details, responses to surveys, Know Your Customer (KYC) documents as mandated by Government authorities and other details.\n\n• RHSPL Resort Management: RHSPL collects personal information related to bookings and as necessary for other purposes related to the management of the resort facility. Further personal information may be collected in specific instances such as in the event of an incident occurring on site for legal and insurance reasons.\n\nRHSPL collects information on individuals when they book their travel arrangements, in order to process the transaction and to fulfil booking requests with travel and tourism operators. We also collect general business information relating to employees, contractors, shareholders, resort managers and other individuals.',
              ),
              
              _buildSection(
                'Using and Disclosing Your Personal Information',
                'Our purpose in collecting information about you is to provide you with personalized membership services, including exploring options like exchanging your holiday accommodation entitlements. RHSPL uses personal information in several different ways in operating our membership programs and operating our business, improve our product and services. We also use your personal information for internal quality assurance purposes.\n\nRHSPL provides personal information to resort operators in order to facilitate a booking that you have requested. Otherwise, RHSPL does not routinely disclose personal information, except where it is necessary to provide you with a service that you have requested. RHSPL will not normally otherwise use or disclose any information about you without your consent, unless:\n\n• Required by law.\n• To protect the rights, property or personal safety of another RHSPL member, or any member of the public.\n• The assets and operations of the business are transferred to another party as a going concern.',
              ),
              
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6), // Subtle soft amber tint
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primaryYellow, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Disclaimer for using data',
                            style: GoogleFonts.montserrat(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'I/We hereby agree and authorize Rigel Hospitality Services Pvt.Ltd. and all of its divisions, affiliates, subsidiaries, related parties and other group companies (collectively the “RHSPL Group”) to access my/our basic data / contact details provided herewith, i.e. name, address, telephone number, e-mail address, birth date and / or anniversary date. I/ We hereby consent to, agree and acknowledge that any of the RHSPL Group may call/ email/ SMS me/us... I/We provide the details herein at my/our sole discretion and confirm that no RHSPL Entity shall be held responsible or liable for any claim arising out of accessing or using my/our basic data. I/We consent to being assigned a unique identity within the RHSPL Group. I/We also agree that if at any point of time, I/We wish to stop receiving such communications from RHSPL Entity, I/We will call at Rigel Hospitality Services Pvt. Ltd designated call center number and register my/our preference or write to membership@ownholidayclub.com with “OPT OUT CCD” as Subject.',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        color: AppColors.primaryBlack.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildSection(
                'For our Web Site Users',
                'RHSPL is committed to high standards of data security. We offer SSL encryption, the industry standard security measures for transactions made over the Internet. We primarily use "cookies" to help us determine which service and support information is appropriate to your computer and to facilitate your use of our instant transactions area. Accepting a cookie in no way gives us access to your computer or any personal information about you.\n\nLinks from our web site: Our web site contains links to other sites. Please be aware that we are not responsible for the content or privacy practices of such other sites.',
              ),
              
              _buildSection(
                'For our Mobile App Users',
                'When you download or use apps created by RHSPL, we may receive information about your location and your mobile device, including a unique identifier. We may use this information to provide you with location-based services, such as advertising, search results, and other personalized content. We also process technical data such as your IP-address, Device ID, Device Contacts, and operating system to enable functionalities and resolve technical difficulties.',
              ),
              
              _buildSection(
                'Storage, Security & Access',
                'Storage and security: RHSPL endeavours to take all reasonable steps to keep secure any information which we hold about you. We use a sophisticated computer data network, and all access is password controlled. Data is secured in a secure data centre environment, totally private and not accessible over the Internet. Under no circumstances, including negligence, shall RHSPL have any liability in respect of personal information provided by you on this website.\n\nTransfer overseas: As a global business, RHSPL may use overseas facilities to process or back up information. We will only transfer information overseas as authorized by the applicable Privacy laws.\n\nAccessing & Changing: You are welcome to access your record or ask to change/delete inaccurate data by contacting us. For security purposes, confirmation of your identity will be required. Our file will usually be made available to you within 14 days.',
              ),

              // Contact & Grievance Card (Dark UI)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1321), // Dark navy blue
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Shield Watermark
                    Positioned(
                      top: 10,
                      right: -10,
                      child: Icon(
                        Icons.shield_outlined,
                        size: 150,
                        color: Colors.white.withOpacity(0.03),
                      ),
                    ),
                    // Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Grievance & Contact',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Any complaints, requests, or concerns with regards to the use, processing, or disclosure of information provided by you may be taken up with our designated grievance redressal officer.',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.0,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Contact Info
                        _buildDarkContactItem(
                          Icons.email_outlined,
                          'EMAIL',
                          'membership@ownholidayclub.com',
                        ),
                        const SizedBox(height: 16),
                        _buildDarkContactItem(
                          Icons.phone_outlined,
                          'PHONE',
                          '+91 9871984074',
                          subText: 'Mon - Sat: 9.30 AM to 6.30 PM\nClosed on Sunday & National Holidays',
                        ),
                        const SizedBox(height: 16),
                        _buildDarkContactItem(
                          Icons.location_on_outlined,
                          'ADDRESS',
                          'Second floor, estate, MR- 01, Altf Mohan estate, room no, plot no A. 26, Saidabad, Block B, Mohan Cooperative Industrial Estate, New Delhi, Delhi 110044',
                        ),
                        const SizedBox(height: 24),
                        // Complaint Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Please provide the following in your complaint:',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFACC15), // Yellow
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildBulletPoint('Identification of the information provided by you.'),
                              _buildBulletPoint('Clear statement if information is personal or sensitive.'),
                              _buildBulletPoint('Your Membership ID, Mobile number and/or e-mail address.'),
                              _buildBulletPoint('A statement that you have a good-faith belief that use of the information was processed incorrectly.'),
                              _buildBulletPoint('A statement, under penalty of perjury, that the information is accurate.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Future changes: From time to time, our policies will be reviewed and may be revised. Changes to RHSPL\'s Privacy Policy will be made by posting an updated version of the policy on our website.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 10.5,
                    color: AppColors.greyText,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
          ),  // SingleChildScrollView
        );  // RefreshIndicator
      }),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: 12.0,
              color: AppColors.bodyText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkContactItem(IconData icon, String label, String text, {String? subText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFACC15)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: const Color(0xFFFACC15),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: GoogleFonts.montserrat(
                  fontSize: 13.0,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              if (subText != null) ...[
                const SizedBox(height: 4),
                Text(
                  subText,
                  style: GoogleFonts.montserrat(
                    fontSize: 10.0,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 11.5,
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
