void main() {
  final features = ["3 Nights / 4 Days for 3 Years", "4 Nights / 5 Days for 2 Years", "Valid for 5 Years"];
  int slotIndex = 1;
  for (final feature in features) {
    final f = feature.toLowerCase();
    if (f.contains("nights") && f.contains("for") && f.contains("year")) {
      final parts = f.split(" for ");
      if (parts.length == 2) {
        final lengthOfStayMatch = RegExp(r'(.*? for)', caseSensitive: false).firstMatch(feature);
        String lengthOfStay = feature;
        if (lengthOfStayMatch != null) {
          lengthOfStay = lengthOfStayMatch.group(1)!.replaceAll(RegExp(r'\s*for$', caseSensitive: false), '').trim();
        } else {
          lengthOfStay = parts[0].trim();
        }
        final yearsStr = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        final years = int.tryParse(yearsStr) ?? 0;
        for (int i = 0; i < years; i++) {
          print("Slot: ${slotIndex++}, Length: $lengthOfStay");
        }
      }
    }
  }
}
