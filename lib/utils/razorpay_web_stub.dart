typedef RazorpayWebSuccess = void Function(Map<String, dynamic> response);
typedef RazorpayWebError = void Function(String message);

void openRazorpayWeb(
  Map<String, dynamic> options,
  RazorpayWebSuccess onSuccess,
  RazorpayWebError onError,
) {
  onError('Razorpay Web Checkout is only available in a web build.');
}
