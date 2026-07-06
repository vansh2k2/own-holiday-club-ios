import re

with open('lib/modules/home/view/destination_details_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. State Variables
old_state = """  final _locationCtrl = TextEditingController();
  List<String> _locationSuggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;"""
new_state = """  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  List<String> _fromSuggestions = [];
  List<String> _toSuggestions = [];
  bool _isLoadingFromSuggestions = false;
  bool _isLoadingToSuggestions = false;
  Timer? _fromDebounceTimer;
  Timer? _toDebounceTimer;"""
content = content.replace(old_state, new_state)

# 2. Dispose
content = content.replace("_locationCtrl.dispose();", "_fromController.dispose();\n    _toController.dispose();\n    _fromDebounceTimer?.cancel();\n    _toDebounceTimer?.cancel();")

# 3. Location Fetching Logic
old_fetch = """  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _locationSuggestions = [];
      });
      return;
    }
    setState(() {
      _isLoadingSuggestions = true;
    });
    try {
      final suggestions = await Get.find<HomeController>().fetchLocationSuggestions(query);
      if (mounted) {
        setState(() {
          _locationSuggestions = suggestions
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationSuggestions = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  void _onLocationChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchLocationSuggestions(val);
    });
  }"""
new_fetch = """  Future<void> _fetchFromSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _fromSuggestions = []);
      return;
    }
    setState(() => _isLoadingFromSuggestions = true);
    try {
      final suggestions = await Get.find<HomeController>().fetchLocationSuggestions(query);
      if (mounted) {
        setState(() {
          _fromSuggestions = suggestions.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _fromSuggestions = []);
    } finally {
      if (mounted) setState(() => _isLoadingFromSuggestions = false);
    }
  }

  Future<void> _fetchToSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _toSuggestions = []);
      return;
    }
    setState(() => _isLoadingToSuggestions = true);
    try {
      final suggestions = await Get.find<HomeController>().fetchLocationSuggestions(query);
      if (mounted) {
        setState(() {
          _toSuggestions = suggestions.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _toSuggestions = []);
    } finally {
      if (mounted) setState(() => _isLoadingToSuggestions = false);
    }
  }

  void _onFromChanged(String val) {
    if (_fromDebounceTimer?.isActive ?? false) _fromDebounceTimer!.cancel();
    _fromDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchFromSuggestions(val);
    });
  }

  void _onToChanged(String val) {
    if (_toDebounceTimer?.isActive ?? false) _toDebounceTimer!.cancel();
    _toDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchToSuggestions(val);
    });
  }"""
content = content.replace(old_fetch, new_fetch)


# 4. Location Fields UI
old_ui = """  Widget _buildLocationAutocompleteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("SPECIFIC LOCATION"),
        TextFormField(
          controller: _locationCtrl,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D1321),
          ),
          decoration: InputDecoration(
            hintText: "Search precise location...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: Colors.grey,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
            constraints: const BoxConstraints(maxHeight: 44),
            suffixIcon: _isLoadingSuggestions
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF000000),
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFFCED4DA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFFCED4DA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
            ),
          ),
          onChanged: _onLocationChanged,
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        if (_locationSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFFCED4DA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _locationSuggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEDEFF2)),
              itemBuilder: (context, index) {
                final suggestion = _locationSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    suggestion,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF0D1321),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _locationCtrl.text = suggestion;
                      _locationSuggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }"""
new_ui = """  Widget _buildLocationAutocompleteField(
    String label,
    String hint,
    TextEditingController controller,
    bool isLoading,
    List<String> suggestions,
    Function(String) onChanged,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D1321),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 11.5),
            prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
            constraints: const BoxConstraints(maxHeight: 44),
            suffixIcon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF000000)),
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFFCED4DA))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFFCED4DA))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5)),
          ),
          onChanged: onChanged,
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFFCED4DA)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEDEFF2)),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(suggestion, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF0D1321))),
                  onTap: () => onSelected(suggestion),
                );
              },
            ),
          ),
        ],
      ],
    );
  }"""
content = content.replace(old_ui, new_ui)

# 5. Usage in build
old_usage = """                // Specific Location Autocomplete
                _buildLocationAutocompleteField(),"""
new_usage = """                _buildLocationAutocompleteField(
                  "FROM LOCATION",
                  "Where are you now?",
                  _fromController,
                  _isLoadingFromSuggestions,
                  _fromSuggestions,
                  _onFromChanged,
                  (val) {
                    setState(() {
                      _fromController.text = val;
                      _fromSuggestions = [];
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildLocationAutocompleteField(
                  "TO LOCATION",
                  "Search destination...",
                  _toController,
                  _isLoadingToSuggestions,
                  _toSuggestions,
                  _onToChanged,
                  (val) {
                    setState(() {
                      _toController.text = val;
                      _toSuggestions = [];
                    });
                  },
                ),"""
content = content.replace(old_usage, new_usage)

# 6. Submit logic validation
content = content.replace("if (_locationCtrl.text.isEmpty) {", "if (_fromController.text.isEmpty || _toController.text.isEmpty) {")
content = content.replace("'location': _locationCtrl.text,", "'location': '${_fromController.text} to ${_toController.text}',")

with open('lib/modules/home/view/destination_details_view.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Done python script")
