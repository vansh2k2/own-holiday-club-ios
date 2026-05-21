import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_holiday_app/utils/app_colors.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 18,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'By visiting website www.ownholidayclub.com and our mobile application you are accepting the terms stated hereunder relating to privacy. It explains how RHSPL handles personal information and complies with the requirements of the privacy act. If you have further questions relating to this policy please contact our member experience management team by e-mail at membership@ownholidayclub.com.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: Colors.grey[800],
                  height: 1.6,
                ),
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
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Disclaimer for using data',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'I/We hereby agree and authorize Rigel Hospitality Services Pvt.Ltd. and all of its divisions, affiliates, subsidiaries, related parties and other group companies (collectively the “RHSPL Group”) to access my/our basic data / contact details provided herewith, i.e. name, address, telephone number, e-mail address, birth date and / or anniversary date. I/We hereby consent to, agree and acknowledge that any of the RHSPL Group may call/ email/ SMS me/us. I/We consent to being assigned a unique identity within the RHSPL Group. If I/We wish to stop receiving communications, I/We will write to membership@ownholidayclub.com with “OPT OUT CCD” as Subject.',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.amber.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            _buildSection(
              'For our Web Site Users',
              'RHSPL is committed to high standards of data security. We offer SSL encryption, the industry standard security measures for transactions made over the Internet. We primarily use "cookies" to help us determine which service and support information is appropriate to your computer and to facilitate your use of our instant transactions area.\n\nLinks from our web site: Our web site contains links to other sites. Please be aware that we are not responsible for the content or privacy practices of such other sites.',
            ),
            _buildSection(
              'For our Mobile App Users',
              'When you download or use apps created by RHSPL, we may receive information about your location and your mobile device, including a unique identifier. We may use this information to provide you with location-based services, such as advertising, search results, and other personalized content. We also process technical data such as your IP-address, Device ID, Device Contacts, and operating system to enable functionalities and resolve technical difficulties.',
            ),
            _buildSection(
              'Storage, Security & Access',
              'Storage and security: RHSPL endeavours to take all reasonable steps to keep secure any information which we hold about you. We use a sophisticated computer data network, and all access is password controlled.\n\nTransfer overseas: As a global business, RHSPL may use overseas facilities to process or back up information. We will only transfer information overseas as authorized by the applicable Privacy laws.\n\nAccessing & Changing: You are welcome to access your record or ask to change/delete inaccurate data by contacting us. For security purposes, confirmation of your identity will be required.',
            ),
            _buildSection(
              'Data Grievance & Contact',
              'Any complaints, requests, or concerns with regards to the use, processing, or disclosure of information provided by you may be taken up with our designated grievance redressal officer.\n\nEmail: membership@ownholidayclub.com\nDataGrievanceOfficer@mahindraholidays.com\n\nPhone: +91-96675 52445\nMon - Sat: 9.30 AM to 6.30 PM\n\nAddress:\nGrievance Redressal Team\n27 C, Block A, Kailash Colony,\nExtension, New Delhi,\nDelhi - 110048, India',
            ),
            
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Future changes: From time to time, our policies will be reviewed and may be revised. Changes to RHSPL\'s Privacy Policy will be made by posting an updated version of the policy on our website.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
