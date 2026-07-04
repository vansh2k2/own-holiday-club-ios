import re

with open('lib/modules/home/view/destination_details_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the Column wrapping SEND OTP and SKIP with a Stack
old_col = """                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 39,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryYellow,
                                      foregroundColor: Colors.white,
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
                                            height: 14,
                                            width: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
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
                                  onTap: () =>
                                      setState(() => _isEmailSkipped = true),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      "SKIP",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),"""

new_col = """                          : Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 39,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryYellow,
                                      foregroundColor: Colors.white,
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
                                            height: 14,
                                            width: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
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
                                Positioned(
                                  bottom: -15,
                                  right: 15,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isEmailSkipped = true),
                                    child: Text(
                                      "SKIP",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),"""

content = content.replace(old_col, new_col)

# Also ensure only SizedBox(height: 8) exists between Email Address and Check-in/Check-out
# At line 1649, it has `const SizedBox(height: 8),` before Check-in section starts?
# Let's replace any extra spaces around there.
# Look for:
#                 const SizedBox(height: 8),
#                 Row(
#                   children: [
#                     Expanded(
#                       child: Column(
#                         crossAxisAlignment: CrossAxisAlignment.start,
#                         children: [
#                           _buildLabel("CHECK-IN"),

checkin_pattern = r'(\s+const SizedBox\(height: \d+\),)+(\s+)Row\(\s+children: \[\s+Expanded\(\s+child: Column\(\s+crossAxisAlignment: CrossAxisAlignment.start,\s+children: \[\s+_buildLabel\("CHECK-IN"\),'
new_checkin = r'\n                const SizedBox(height: 8),\2Row(\n                  children: [\n                    Expanded(\n                      child: Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,\n                        children: [\n                          _buildLabel("CHECK-IN"),'

content = re.sub(checkin_pattern, new_checkin, content)

with open('lib/modules/home/view/destination_details_view.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Replacement successful")
