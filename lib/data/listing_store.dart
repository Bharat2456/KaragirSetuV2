import 'package:flutter/foundation.dart';
import '../models/product_listing.dart';

/// Deliberately simple: a singleton in-memory list. Good enough for a
/// one-day demo. Swap for a real backend (see README "Next steps") once
/// this prototype needs to persist data or support multiple users.
class ListingStore {
  ListingStore._();
  static final ListingStore instance = ListingStore._();

  final ValueNotifier<List<ProductListing>> listings = ValueNotifier([]);

  void add(ProductListing listing) {
    listings.value = [...listings.value, listing];
  }
}
