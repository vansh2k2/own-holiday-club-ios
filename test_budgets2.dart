import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://api.ownholidayclub.com/api/budgets';
  
  final res = await http.get(Uri.parse(url));
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
