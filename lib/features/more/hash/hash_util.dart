import 'package:bcrypt/bcrypt.dart';

String hashPassword(String plainPassword) {
  return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
}

bool verifyPassword(String plainPassword, String hashed) {
  return BCrypt.checkpw(plainPassword, hashed);
}
