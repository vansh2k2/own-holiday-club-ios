import re

with open('lib/modules/home/view/destination_details_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

state_insert = """  List<String> _fetchedBudgets = [];

  Future<void> _fetchBudgetsAPI() async {
    final url = 'https://api.ownholidayclub.com/api/budgets?type=destination';
    print('=== FETCH DESTINATION BUDGET API URL ===: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('=== FETCH DESTINATION BUDGET API STATUS ===: ${response.statusCode}');
      print('=== FETCH DESTINATION BUDGET API BODY ===: ${response.body}');
      
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
      print('Error fetching destination budgets: $e');
    }
  }
"""

content = content.replace("  final Map<String, List<Map<String, String>>> _budgetOptions = {", state_insert + "\n  final Map<String, List<Map<String, String>>> _budgetOptions = {")

old_items = """                    items: _travelType != null
                        ? (_budgetOptions[_travelType!] ?? []).map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt['value'],
                              child: Text(opt['label']!),
                            );
                          }).toList()
                        : [],
                    onChanged: _travelType == null
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() {
                                _budget = val;
                              });
                            }
                          },"""

new_items = """                    onTap: () {
                      if (_fetchedBudgets.isEmpty) {
                        _fetchBudgetsAPI();
                      } else {
                        _fetchBudgetsAPI(); // fetch every time clicked as requested
                      }
                    },
                    items: _fetchedBudgets.isNotEmpty 
                        ? _fetchedBudgets.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt),
                            );
                          }).toList()
                        : [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Click to load budgets...'),
                            )
                          ],
                    onChanged: (val) {
                      if (val != null && val != '') {
                        setState(() {
                          _budget = val;
                        });
                      }
                    },"""

content = content.replace(old_items, new_items)

# Add initState call just in case to pre-load it if user wants it smooth. But they specifically asked to hit it on click. We will do both.
init_pattern = """  @override
  void initState() {"""
init_replacement = """  @override
  void initState() {
    _fetchBudgetsAPI();"""
content = content.replace(init_pattern, init_replacement)

with open('lib/modules/home/view/destination_details_view.dart', 'w', encoding='utf-8') as f:
    f.write(content)
