import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final AuthService authService = AuthService();
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  // Create a document when user registers if no document exists for that user

  Future<void> addUser(String name, String email, [String? number]) async {
    // get user ID

    final userId = authService.currentUser!.uid;

    // reference to the document of the current user
    final docRef = users.doc(userId);

    // actual document of the current user
    final docSnapshot = await docRef.get();

    // check if user has already document
    // If not, create one

    if (!docSnapshot.exists) {
      docRef.set
      (
        {
          'name' : name,
          'email' : email, 
          'number': number,
          'role' : 'user'
        }
      );
    }
  }
  Future<String> getUsersRole() async {
  try {
    final user = authService.currentUser;
    if (user == null) return '';

    final docSnapshot = await users.doc(user.uid).get();
    if (docSnapshot.exists) {
      return docSnapshot['role'] as String;
    }
  } catch (e) {
    print("Fehler in getUsersRole: $e");
  }
  return '';
}

  Future <bool> checkIfUserIsAdmin() async{
    final usersRole = await getUsersRole();
    return usersRole == 'admin';
  }
}
