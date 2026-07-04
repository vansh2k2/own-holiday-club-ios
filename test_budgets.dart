import 'package:http/http.dart' as http;

void main() async {
  final destUrl = 'https://api.ownholidayclub.com/api/destination-budgets';
  final servUrl = 'https://api.ownholidayclub.com/api/service-budgets';
  
  final res1 = await http.get(Uri.parse(destUrl));
  print('Dest Status: ${res1.statusCode}');
  print('Dest Body: ${res1.body}');
  
  final res2 = await http.get(Uri.parse(servUrl));
  print('Serv Status: ${res2.statusCode}');
  print('Serv Body: ${res2.body}');
}
