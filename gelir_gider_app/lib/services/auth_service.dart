import 'package:gelir_gider_app/models/app_user.dart';
import 'package:gelir_gider_app/services/api_service.dart';
import 'package:gelir_gider_app/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends GetxService {
  late final StorageService _storageService;
  late final ApiService _apiService;
  late final GoogleSignIn _googleSignIn;

  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);

  Future<AuthService> init() async {
    _storageService = Get.find<StorageService>();
    _apiService = Get.find<ApiService>();
    _googleSignIn = GoogleSignIn(serverClientId: ApiConstants.serverClientId);
    return this;
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();
      if (_googleUser == null) return null;

      final GoogleSignInAuthentication _googleAuthentication =
          await _googleUser.authentication;

      final response = await _apiService.post(
        ApiConstants.login,
        data: {'idToken': _googleAuthentication.idToken},
      );

      if (response.statusCode == 200) {
        await _storageService.setValue<String>(
          StorageKeys.userToken,
          response.data['token'],
        );

        print(response.data['token']);

        var user = AppUser.fromJson(response.data['user']);
        currentUser.value = user;
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      currentUser.value = null;
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _storageService.remove(StorageKeys.userToken);
    } catch (e) {
      print('Google Sign-Out error: $e');
    }
  }

  Future<AppUser?> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      if (response.statusCode == 200) {
        currentUser.value = AppUser.fromJson(response.data);
        return currentUser.value;
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final token = _storageService.getValue<String>(StorageKeys.userToken);
      if (token == null) {
        currentUser.value = null;
        return false;
      }

      final response = await getProfile();
      if (response != null) {
        currentUser.value = response;
        return true;
      }

      return false;
    } catch (e) {
      await _storageService.remove(StorageKeys.userToken);
      currentUser.value = null;
      return false;
    }
  }
}
