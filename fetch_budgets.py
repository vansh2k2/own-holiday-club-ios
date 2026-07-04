import re

def update_file(filename, url, type_name):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add API fetch method
    fetch_method = f"""  Future<void> _fetchBudgetsAPI() async {{
    final url = '{url}';
    print('=== FETCH {type_name.upper()} BUDGET API URL ===: $url');
    try {{
      final response = await http.get(Uri.parse(url));
      print('=== FETCH {type_name.upper()} BUDGET API STATUS ===: ${{response.statusCode}}');
      print('=== FETCH {type_name.upper()} BUDGET API BODY ===: ${{response.body}}');
      
      if (response.statusCode == 200) {{
        final data = jsonDecode(response.body);
        if (data['success'] == true) {{
          final List budgetsList = data['data'];
          List<String> newBudgets = [];
          // Collect all budgets from the array (or match it to current item if needed, but let's just collect all or match by title)
          // Actually if we just want a flat list of budgets for the dropdown:
          for (var item in budgetsList) {{
             if (item['budgets'] != null) {{
                 newBudgets.addAll(List<String>.from(item['budgets']));
             }}
          }}
          // Remove duplicates
          newBudgets = newBudgets.toSet().toList();
          
          if (mounted) {{
            setState(() {{
              _fetchedBudgets = newBudgets;
            }});
          }}
        }}
      }}
    }} catch (e) {{
      print('Error fetching {type_name} budgets: $e');
    }}
  }}"""

    # Add _fetchedBudgets state variable and replace _budgetOptions
    # Look for _budgetOptions definition
    pattern = r"final Map<String, List<Map<String, String>>> _budgetOptions = \{[\s\S]*?\};\n"
    new_state = f"""List<String> _fetchedBudgets = [];\n\n{fetch_method}\n\n"""
    
    # We shouldn't completely remove _budgetOptions if it's used elsewhere, but we can if it's only in the dropdown.
    # Actually, the user says "budget wale input me budget desatination budgte wali api se fetch honge".
    # Let's replace the items logic in DropdownButtonFormField.

    # Find the budget dropdown in destination
    # items: _travelType != null ? (_budgetOptions[_travelType!] ?? []).map...
    items_pattern = r"items: _travelType != null\s*\?\s*\(_budgetOptions\[_travelType!\] \?\? \[\]\)\.map\(\(opt\) \{\s*return DropdownMenuItem<String>\(\s*value: opt\['value'\],\s*child: Text\(opt\['label'\]!\),\s*\);\s*\}\)\.toList\(\)\s*: \[\],"
    new_items = r"""items: _fetchedBudgets.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt),
                            );
                          }).toList(),
                    onTap: () {
                      _fetchBudgetsAPI();
                    },"""

    if "destination_details_view.dart" in filename:
        content = re.sub(items_pattern, new_items, content)
        # Also need to fix onChanged which checks _travelType
        onchanged_pattern = r"onChanged: _travelType == null\s*\?\s*null\s*:\s*\(val\) \{"
        new_onchanged = r"onChanged: (val) {"
        content = re.sub(onchanged_pattern, new_onchanged, content)
        
        # Add the fetch method to the class
        content = re.sub(r"(final List<String> _travelTypes = \['Holiday', 'Events', 'Wedding', 'Outing'\];)", r"\1\n" + new_state, content)

    elif "service_details_view.dart" in filename:
        items_pattern_serv = r"items: _selectedService != null\s*\?\s*\(.*?\)\.map\(\(opt\) \{\s*return DropdownMenuItem<String>\(\s*value: opt\['value'\],\s*child: Text\(opt\['label'\]!\),\s*\);\s*\}\)\.toList\(\)\s*: \[\],"
        new_items_serv = r"""items: _fetchedBudgets.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt),
                            );
                          }).toList(),
                    onTap: () {
                      _fetchBudgetsAPI();
                    },"""
        # content = re.sub(items_pattern_serv, new_items_serv, content, flags=re.DOTALL)
        # It's better to use a simple string replace for the items.
        pass

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

update_file('lib/modules/home/view/destination_details_view.dart', 'https://api.ownholidayclub.com/api/budgets?type=destination', 'destination')
update_file('lib/modules/home/view/service_details_view.dart', 'https://api.ownholidayclub.com/api/budgets?type=service', 'service')
print("Done")
