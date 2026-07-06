import re

with open('lib/modules/home/view/destination_details_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_fetch = """  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _locationSuggestions = [];
      });
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    try {
      final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': 'AIzaSyDarNwOH5Gfi1KseDZ82fkh2b0wn66uudg',
        },
        body: jsonEncode({'input': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['suggestions'] != null) {
          final List suggestions = data['suggestions'];
          setState(() {
            _locationSuggestions = suggestions
                .map((s) => s['placePrediction']['text']['text'].toString())
                .toList();
          });
        } else {
          setState(() {
            _locationSuggestions = [];
          });
        }
      } else {
        setState(() {
          _locationSuggestions = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
      setState(() {
        _locationSuggestions = [];
      });
    } finally {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  void _onLocationChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchLocationSuggestions(val);
    });
  }"""
new_fetch = """  Future<void> _fetchFromSuggestions(String query) async {
    if (query.length < 2) {
      setState(() => _fromSuggestions = []);
      return;
    }
    setState(() => _isLoadingFromSuggestions = true);
    try {
      final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': 'AIzaSyDarNwOH5Gfi1KseDZ82fkh2b0wn66uudg',
        },
        body: jsonEncode({'input': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['suggestions'] != null) {
          final List suggestions = data['suggestions'];
          setState(() {
            _fromSuggestions = suggestions.map((s) => s['placePrediction']['text']['text'].toString()).toList();
          });
        } else {
          setState(() => _fromSuggestions = []);
        }
      } else {
        setState(() => _fromSuggestions = []);
      }
    } catch (e) {
      setState(() => _fromSuggestions = []);
    } finally {
      setState(() => _isLoadingFromSuggestions = false);
    }
  }

  Future<void> _fetchToSuggestions(String query) async {
    if (query.length < 2) {
      setState(() => _toSuggestions = []);
      return;
    }
    setState(() => _isLoadingToSuggestions = true);
    try {
      final response = await http.post(
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': 'AIzaSyDarNwOH5Gfi1KseDZ82fkh2b0wn66uudg',
        },
        body: jsonEncode({'input': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['suggestions'] != null) {
          final List suggestions = data['suggestions'];
          setState(() {
            _toSuggestions = suggestions.map((s) => s['placePrediction']['text']['text'].toString()).toList();
          });
        } else {
          setState(() => _toSuggestions = []);
        }
      } else {
        setState(() => _toSuggestions = []);
      }
    } catch (e) {
      setState(() => _toSuggestions = []);
    } finally {
      setState(() => _isLoadingToSuggestions = false);
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

# Also fix the validation in case it's missed
content = content.replace("if (_locationCtrl.text.isEmpty) {", "if (_fromController.text.isEmpty || _toController.text.isEmpty) {")
content = content.replace("'location': _locationCtrl.text,", "'location': '${_fromController.text} to ${_toController.text}',")
content = content.replace("bool _isLoadingSuggestions = false;", "")
content = content.replace("List<String> _locationSuggestions = [];", "")
content = content.replace("Timer? _debounceTimer;", "")

with open('lib/modules/home/view/destination_details_view.dart', 'w', encoding='utf-8') as f:
    f.write(content)
