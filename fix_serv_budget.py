import re

with open('lib/modules/home/view/service_details_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

state_insert = """  List<String> _fetchedBudgets = [];

  Future<void> _fetchBudgetsAPI() async {
    final url = 'https://api.ownholidayclub.com/api/budgets?type=service';
    print('=== FETCH SERVICE BUDGET API URL ===: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('=== FETCH SERVICE BUDGET API STATUS ===: ${response.statusCode}');
      print('=== FETCH SERVICE BUDGET API BODY ===: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List budgetsList = data['data'];
          List<String> newBudgets = [];
          for (var item in budgetsList) {
             if (item['budgets'] != null) {
                 newBudgets.addAll(List<String>.from(item['budgets']));
             }
          }
          newBudgets = newBudgets.toSet().toList();
          
          if (mounted) {
            setState(() {
              _fetchedBudgets = newBudgets;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching service budgets: $e');
    }
  }
"""

# Inject state and function
content = content.replace("  final Map<String, List<Map<String, String>>> _budgetOptions = {", state_insert + "\n  final Map<String, List<Map<String, String>>> _budgetOptions = {")

# Find the items and onChanged in service_details_view.dart
# Looking at grep results:
# items: _selectedService != null
#                 ? (() {
#                     String s = _selectedService!.toLowerCase();
# ...
#                   })().map((opt) { ... })

# Instead of regex, I'll use a precise replace.
# First, let's extract the exact string from the file.
EOF
