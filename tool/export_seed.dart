// Prints the demo catalogue as JSON so it can be uploaded to Firestore.
//
// Run with:  dart run tool/export_seed.dart > seed.json
//
// Using the real `kSeedProperties` constant rather than a hand-written copy
// means the uploaded documents can never drift from the models the app reads
// them back into.
import 'dart:convert';

import 'package:houslice/features/property/data/seed_properties.dart';

void main() {
  final docs = [
    for (final property in kSeedProperties)
      {'id': property.id, ...property.toMap()},
  ];
  print(const JsonEncoder.withIndent('  ').convert(docs));
}
