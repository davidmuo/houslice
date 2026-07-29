/// Maps Kigali neighbourhoods to their district.
///
/// Listing addresses are written the way students say them ("5 Vision
/// Heights, Kimihurura, Kigali"), so matching a listing to a preferred
/// district by substring fails — the district name never appears in the
/// address. This lookup bridges the two.
abstract final class KigaliDistricts {
  static const districts = <String>['Gasabo', 'Kicukiro', 'Nyarugenge'];

  /// Neighbourhood (lowercase) -> district.
  static const _byNeighbourhood = <String, String>{
    'kimihurura': 'Gasabo',
    'remera': 'Gasabo',
    'kacyiru': 'Gasabo',
    'kimironko': 'Gasabo',
    'kibagabaga': 'Gasabo',
    'nyarutarama': 'Gasabo',
    'gisozi': 'Gasabo',
    'gacuriro': 'Gasabo',
    'kicukiro': 'Kicukiro',
    'kanombe': 'Kicukiro',
    'niboye': 'Kicukiro',
    'gatenga': 'Kicukiro',
    'kagarama': 'Kicukiro',
    'kabeza': 'Kicukiro',
    'nyamirambo': 'Nyarugenge',
    'kiyovu': 'Nyarugenge',
    'muhima': 'Nyarugenge',
    'gitega': 'Nyarugenge',
    'nyakabanda': 'Nyarugenge',
    'nyabugogo': 'Nyarugenge',
  };

  /// The district an address falls in, or null when it cannot be placed.
  ///
  /// Checks the district name first so an address that already spells it out
  /// still resolves.
  static String? forAddress(String address) {
    final haystack = address.toLowerCase();
    for (final district in districts) {
      if (haystack.contains(district.toLowerCase())) return district;
    }
    for (final entry in _byNeighbourhood.entries) {
      if (haystack.contains(entry.key)) return entry.value;
    }
    return null;
  }

  /// True when [address] sits in [district].
  static bool isIn(String address, String district) =>
      forAddress(address) == district;
}
