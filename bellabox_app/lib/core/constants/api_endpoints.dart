/// All endpoints match the frozen Phase 1 API contract.
/// Base URL is prepended by DioClient.
class ApiEndpoints {
  ApiEndpoints._();

  // Health / config
  static const String ping = '/ping';
  static const String settings = '/settings';
  static const String page = '/pages'; // /pages/{slug}
  static const String shippingMethods = '/shipping/methods';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String socialApple = '/auth/social/apple';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Products / catalog
  static const String products = '/products';
  static String productBySlug(String slug) => '/products/$slug';
  static const String productSearch = '/products/search';
  static const String productsFeatured = '/products/featured';
  static const String productsNewArrivals = '/products/new-arrivals';
  static const String productsBestSellers = '/products/best-sellers';
  static String productRelated(int id) => '/products/$id/related';
  static String productReviews(int id) => '/products/$id/reviews';

  static const String categories = '/categories';
  static String categoryBySlug(String slug) => '/categories/$slug';

  static const String brands = '/brands';
  static String brandBySlug(String slug) => '/brands/$slug';

  static const String banners = '/banners';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(int id) => '/cart/items/$id';
  static const String cartApplyCoupon = '/cart/apply-coupon';
  static const String cartRemoveCoupon = '/cart/coupon';
  static const String cartMerge = '/cart/merge';

  // Orders
  static const String orders = '/orders';
  static String order(String orderNumber) => '/orders/$orderNumber';
  static String orderCancel(String orderNumber) => '/orders/$orderNumber/cancel';
  static String orderReorder(String orderNumber) => '/orders/$orderNumber/reorder';
  static String orderTrack(String orderNumber) => '/orders/$orderNumber/track';

  // Payments
  static const String paymentInitiate = '/payments/initiate';
  static String paymentStatus(int orderId) => '/payments/$orderId/status';
  static const String paymentApplePayValidate = '/payments/apple-pay/validate-merchant';

  // Wishlist
  static const String wishlist = '/wishlist';
  static const String wishlistToggle = '/wishlist/toggle';
  static String wishlistItem(int productId) => '/wishlist/$productId';

  // Profile & addresses
  static const String profile = '/profile';
  static const String profileAvatar = '/profile/avatar';
  static const String addresses = '/addresses';
  static String address(int id) => '/addresses/$id';
  static String addressSetDefault(int id) => '/addresses/$id/set-default';

  // Notifications & devices
  static const String notifications = '/notifications';
  static const String notificationsMarkRead = '/notifications/mark-read';
  static const String devicesRegister = '/devices/register';
  static const String devicesUnregister = '/devices/unregister';
}
