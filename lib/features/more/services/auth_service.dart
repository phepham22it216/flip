import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user_model.dart';
import 'user_database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserDatabaseService _db = UserDatabaseService();

  // ------------------------------
  // SIGN UP (EMAIL/PASSWORD)
  // ------------------------------
  Future<UserModel?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;
      final hash = BCrypt.hashpw(password, BCrypt.gensalt());

      UserModel user = UserModel(
        userId: uid,
        fullName: fullName,
        email: email,
        passwordHash: hash,
        avatarUrl: "",
        role: null,
        status: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.saveUser(user);

      return user;
    } catch (e) {
      print("❌ SignUp error: $e");
      return null;
    }
  }

  // ------------------------------
  // SIGN IN WITH EMAIL
  // ------------------------------
  Future<UserModel?> loginWithEmail({
      required String email,
      required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel? user =
      await _db.getUser(result.user!.uid);

      if (user == null) return null;

      // Check password hash manually
      bool isValid = BCrypt.checkpw(password, user.passwordHash);

      if (!isValid) return null;

      return user;
    } catch (e) {
      print("❌ Login error: $e");
      return null;
    }
  }

  // ------------------------------
  // SIGN IN WITH GOOGLE
  // ------------------------------
  Future<UserModel?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential result =
      await _auth.signInWithCredential(credential);

      String uid = result.user!.uid;

      UserModel? user = await _db.getUser(uid);

      if (user == null) {
        user = UserModel(
          userId: uid,
          fullName: googleUser.displayName ?? "",
          email: googleUser.email,
          passwordHash: "",
          avatarUrl: googleUser.photoUrl ?? "",
          role: null,
          status: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _db.saveUser(user);
      }

      return user;
    } catch (e) {
      print("Google Login error: $e");
      return null;
    }
  }
}
