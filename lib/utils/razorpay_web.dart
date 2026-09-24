import 'dart:js_util' as js_util;
import 'dart:html' as html;

typedef RazorpayWebSuccess = void Function(Map<String, dynamic> response);
typedef RazorpayWebError = void Function(String message);

void openRazorpayWeb(
  Map<String, dynamic> options,
  RazorpayWebSuccess onSuccess,
  RazorpayWebError onError,
) {
  final razorpayConstructor = js_util.getProperty(html.window, 'Razorpay');
  if (razorpayConstructor == null) {
    onError('Razorpay Web Checkout did not load. Please refresh the page.');
    return;
  }

  final webOptions = <String, dynamic>{
    ...options,
    'handler': js_util.allowInterop((dynamic response) {
      onSuccess({
        'razorpay_payment_id':
            js_util.getProperty(response, 'razorpay_payment_id'),
        'razorpay_order_id':
            js_util.getProperty(response, 'razorpay_order_id'),
        'razorpay_signature':
            js_util.getProperty(response, 'razorpay_signature'),
      });
    }),
    'modal': {
      'ondismiss': js_util.allowInterop(() {
        onError('Payment window was closed.');
      }),
    },
  };

  try {
    final checkout = js_util.callConstructor(
      razorpayConstructor,
      [js_util.jsify(webOptions)],
    );
    js_util.callMethod(checkout, 'open', const []);
  } catch (error) {
    onError('Unable to open Razorpay checkout.');
  }
}
