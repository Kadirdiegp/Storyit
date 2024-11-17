import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  final String _premiumSubscriptionId = 'story_it_premium_monthly';

  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) return;

    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Error: $error'),
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final Set<String> ids = {_premiumSubscriptionId};
    final ProductDetailsResponse response = 
        await _inAppPurchase.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      print('Produkte nicht gefunden: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  Future<void> purchasePremium() async {
    if (!_isAvailable) return;

    final ProductDetails? product = _products.firstWhere(
      (product) => product.id == _premiumSubscriptionId,
      orElse: () => null,
    );

    if (product == null) {
      print('Premium-Produkt nicht gefunden');
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Zeige Ladeindikator
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Zeige Fehlermeldung
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Aktiviere Premium-Features
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
} 