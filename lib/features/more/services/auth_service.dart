import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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



  // SIGN IN WITH GOOGLE
  // ------------------------------
  Future<UserModel?> loginWithGoogle() async {
    try {
      User? firebaseUser;

      if (kIsWeb) {
        // --- Web ---
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential result = await _auth.signInWithPopup(
            googleProvider);
        firebaseUser = result.user;
      } else {
        // --- Mobile (Android/iOS) ---
        final googleUser = await GoogleSignIn.instance.authenticate();
        if (googleUser == null) return null;

        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken);

        final result = await _auth.signInWithCredential(credential);
        firebaseUser = result.user;
      }
      if (firebaseUser == null) return null;
      final uid = firebaseUser.uid;

      UserModel? user = await _db.getUser(uid);
      if (user == null) {
        user = UserModel(
          userId: uid,
          fullName: firebaseUser.displayName ?? "",
          email: firebaseUser.email ?? "",
          passwordHash: "",
          avatarUrl: firebaseUser.photoURL ?? "",
          role: null,
          status: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _db.saveUser(user);
      }

      return user;
    } catch(e){
      print("Google Login error: $e");
      return null;
    }
  }

  // ------------------------------
  // SIGN OUT
  // ------------------------------
  Future<void> signOut() async {
    await _auth.signOut();

    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
    } catch (_) {
      // Ignore if GoogleSignIn fails
    }
  }
}

// ------------------------------
void initGoogleSignIn() {
  if (!kIsWeb) {
    // Chỉ Android/iOS mới cần serverClientId
    GoogleSignIn.instance.initialize(
      clientId: null,
      serverClientId: "639479435926-23qn77ll1nb0o2jpsbbiiudsjilgubbs.apps.googleusercontent.com",
    );
  } else {
    // Web không cần serverClientId
    GoogleSignIn.instance.initialize();
  }
}
