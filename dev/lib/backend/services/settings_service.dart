import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  final AuthService authService = AuthService();
  // get collection of settings
  final CollectionReference settings = FirebaseFirestore.instance.collection(
    'settings',
  );

  // Create a documentation when user registers 
  Future<void> addSettings () async
  {
    // get the userId 
    final userId = authService.currentUser!.uid;

    // reference to the documents of the current user
    final docRef = settings.doc(userId);

    // get the document of the user 
    final docSnapshot = await docRef.get();


    // If there is no document under the user ids name, create a new document 
    // which id is the user id
    // This is necessary to have explicitely access to the document of the current user
    // in order to read or update it 
    if(!docSnapshot.exists)
    {
      docRef.set
      (
        {
          'mode' : 'light',
        }
      );
    }

  }
  
  // Update a certain collection via id of the collection. 
  // Since we dont want do hardcode the id, we get the id of the collection through the current User.
  // Once we know the collection of the current User we can get Access to the id of the collection to update it. 
 Future<void> updateTheme(String mode) async {
  
  // current User
  final user = authService.currentUser;
  if (user == null) return;

  // document of current User 
  final docRef = settings.doc(user.uid);

  // update document of current User
  await docRef.update(
    {
      'mode' : mode,
    }
  );
  }

 Future<String> getUserThemeMode() async {

  // get user Id
  final userId = authService.currentUser!.uid;

  // users document
  final docSnapshot = await settings.doc(userId).get();
  // get themeMode field from document of current User
  if(docSnapshot.exists)
  {
    return docSnapshot['mode'] as String;
  }
  else
  {
    return 'light';
  }
 }
}

