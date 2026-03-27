import 'package:flutter_ecommerce/features/products/presentation/screens/account_settings_screen.dart';
import 'package:flutter_ecommerce/features/products/presentation/screens/coupons_screen.dart';
import 'package:flutter_ecommerce/features/products/presentation/screens/help_support_screen.dart';
import 'package:flutter_ecommerce/features/products/presentation/screens/notification_preferences_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- MODEL İMPORTLARI ---
import '../../features/products/domain/models/product_model.dart';
import '../../features/products/presentation/providers/address_provider.dart'; // AddressModel için
import '../../features/products/presentation/providers/payment_provider.dart'; // CreditCardModel/PaymentMethod modeli için

// --- EKRAN (SCREEN) İMPORTLARI ---
// Auth
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';

// Ana Sayfa & Ürünler & Cart
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/products/presentation/screens/favorites_screen.dart';

// Checkout & Siparişler
import '../../features/products/presentation/screens/checkout_screen.dart';
import '../../features/products/presentation/screens/order_success_screen.dart';
import '../../features/products/presentation/screens/order_screen.dart';
import '../../features/products/presentation/screens/order_details_screen.dart';
import '../../features/products/presentation/screens/reorder_config_screen.dart'; // YENİ EKLENEN REORDER EKRANI

// Profil & Adres
import '../../features/products/presentation/screens/profile_screen.dart';
import '../../features/products/presentation/screens/address_screen.dart';
import '../../features/products/presentation/screens/add_address_screen.dart';
import '../../features/products/presentation/screens/address_detail_screen.dart';

// Ödeme (Cüzdan)
import '../../features/products/presentation/screens/payment_methods_screen.dart';
import '../../features/products/presentation/screens/add_payment_method_screen.dart';
// PaymentDetailsScreen ve PaymentCardSettingsScreen'i birleştirip tek bir settings ekranı kullandık
import '../../features/products/presentation/screens/payment_card_settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login', // Uygulamanın başlangıç noktası
    routes: [
      // KÖK DİZİN YÖNLENDİRMESİ
      GoRoute(
        path: '/',
        redirect: (context, state) =>
            '/home', // Loginden sonra veya ana root'da home'a at (Kendi mantığına göre /login de yapabilirsin)
      ),

      // --- AUTH ---
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // --- ANA AKIŞ ---
      GoRoute(
        path: '/home',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          // Tıklanan ürünü ekstra parametre olarak yakala
          final product = state.extra as ProductModel;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),

      // --- CHECKOUT & SİPARİŞ SÜREÇLERİ ---
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order-detail',
        builder: (context, state) {
          // URL yerine extra üzerinden id yolluyoruz
          final String orderId = state.extra as String;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      // Tekrar sipariş etmek için ürünlerin düzenlendiği sayfa
      GoRoute(
        path: '/reorder-config',
        builder: (context, state) => const ReorderConfigScreen(),
      ),

      // --- PROFİL VE YÖNETİM ---
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // --- ADRES YÖNETİMİ ---
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        path: '/add-address',
        builder: (context, state) {
          // Güncelleme için gelirse dolu AddressModel, yeni ekleme için gelirse null olur
          final address = state.extra as AddressModel?;
          return AddAddressScreen(editAddress: address);
        },
      ),
      GoRoute(
        path: '/address-detail',
        builder: (context, state) {
          final String addressId = state.extra as String;
          return AddressDetailScreen(addressId: addressId);
        },
      ),

      // --- CÜZDAN & ÖDEME YÖNTEMLERİ ---
      GoRoute(
        path: '/payments', // Cüzdan listesi
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/add-payment', // Kart Ekleme Formu
        builder: (context, state) {
          // state.extra doluysa güncelleme modu, boşsa yeni kart modu
          final editCard = state.extra as CreditCardModel?;
          return AddPaymentMethodScreen(editCard: editCard);
        },
      ),
      GoRoute(
        path: '/payment-details', // Tıklanan kartın yönetim sayfası
        builder: (context, state) {
          // PaymentMethodsScreen'den sadece kart ID'si yolluyoruz
          final cardId = state.extra as String;
          return PaymentCardSettingsScreen(cardId: cardId);
        },
      ),

      // Edit Card rotası (Card settings içindeki "Bilgileri Güncelle" butonu için)
      GoRoute(
        path: '/edit-card',
        builder: (context, state) {
          final editCard = state.extra as CreditCardModel;
          return AddPaymentMethodScreen(editCard: editCard);
        },
      ),
      GoRoute(
        path: '/account-settings',
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/coupons',
        builder: (context, state) => const CouponsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
    ],
  );
});
