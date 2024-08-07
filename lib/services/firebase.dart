import 'package:diplomski_rad/interfaces/estate.dart';
import 'package:diplomski_rad/interfaces/category.dart' as localCategory;
import 'package:diplomski_rad/interfaces/user.dart' as localUser;
import 'package:diplomski_rad/interfaces/element.dart' as localElement;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:diplomski_rad/interfaces/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';


class FirebaseStorageService {
  var storage = FirebaseStorage.instance.ref();

  void setStorageInstace(String? instance) {
    if (instance == null || instance.isEmpty) return;
    storage = FirebaseStorage.instance.ref(instance);
  }

  // TODO: comment
  Future<void> uploadImageForCustomer(Customer customer, String name, Uint8List bytes, bool isAvatarImage) async {
    try {
      final Reference folder = storage.child("${customer.id}/$name");
      await folder.putData(bytes).whenComplete(() async {
        String url = await folder.getDownloadURL();

        Map<String, dynamic> updateObject = {
          (isAvatarImage ? "avatarImage" : "backgroundImage"): url
        };

        bool success = await UserRepository.updateUser(customer.id, updateObject);
        // TODO: give feedback
      });
    } catch (err) {

    }
  }

  // TODO: comment
  Future<void> uploadImageForEstate(Estate estate, String name, Uint8List bytes) async {
    try {
      final Reference folder = storage.child("${estate.id}/$name");
      await folder.putData(bytes).whenComplete(() async {
        String url = await folder.getDownloadURL();

        Map<String, dynamic> updateObject = {"image": url};

        bool success = await EstateRepository.updateEstate(estate.id, updateObject);
        // TODO: give feedback
      });
    } catch (err) {
      return;
    }
  }

  // TODO: comment
  Future<void> uploadImageForCategory(localCategory.Category category, String name, Uint8List bytes) async {
    try {
      final Reference folder = storage.child("${category.id}/$name");
      await folder.putData(bytes).whenComplete(() async {
        String url = await folder.getDownloadURL();

        Map<String, dynamic> updateObject = {"image": url};

        bool success = await CategoryRepository.updateCategory(category.id, updateObject);
        // TODO: give feedback
      });
    } catch (err) {
      return;
    }
  }

  Future<void> uploadBackgroundForElement(String elementId, String name, Uint8List bytes) async {
    try {
      final Reference folder = storage.child("$elementId/$name");
      await folder.putData(bytes).whenComplete(() async {
        String url = await folder.getDownloadURL();

        Map<String, dynamic> updateObject = {"background": url};

        bool success = await ElementRepository.updateElement(elementId, updateObject);
        // TODO: give feedback
      });
    } catch (err) {
      return;
    }
  }
  
  Future<void> deleteOldImagesForElement(String elementId, dynamic toRemoveUrl) async {
    if (elementId.isEmpty || toRemoveUrl.isEmpty) return;

    try {
      String name = extractFileName(toRemoveUrl);
      final Reference folder = storage.child("$elementId/$name");
      await folder.delete();
    } catch (err) {
      return;
    }
    return;
  }

  Future<void> uploadNewImageForElement(String elementId, dynamic toUploadName, Uint8List? toUploadBytes, List<String> images) async {
    if (toUploadBytes == null) return;

    try {
      final Reference folder = storage.child("$elementId/$toUploadName");
      await folder.putData(toUploadBytes).whenComplete(() async {
        String url = await folder.getDownloadURL();

        images.add(url);

        Map<String, dynamic> updateObject = {"images": images};

        bool success = await ElementRepository.updateElement(elementId, updateObject);
        // TODO: give feedback
      });
    } catch (err) {
      return;
    }
  }


  // TODO: comment
  Future<void> deleteImageForCustomer(String id, String url, bool isAvatarImage) async {
    String name = extractFileName(url);
    Map<String, dynamic> updateObject = {
      (isAvatarImage ? "avatarImage" : "backgroundImage"): ""
    };

    try {
      bool success = await UserRepository.updateUser(id, updateObject);
      if (success) {
        final Reference folder = storage.child("$id/$name");
        await folder.delete();
        // TODO: give feedback
      }
    } catch (err) {
      return;
    }
  }

  // TODO: comment
  Future<void> deleteImageForEstate(String id, String url) async {
    String name = extractFileName(url);
    Map<String, dynamic> updateObject = {
      "image": ""
    };

    try {
      bool success = await EstateRepository.updateEstate(id, updateObject);
      if (success) {
        final Reference folder = storage.child("$id/$name");
        await folder.delete();
        // TODO: give feedback
      }
    } catch (err) {
      return;
    }
  }

    // TODO: comment
  Future<void> deleteImageForCategory(String id, String url) async {
    String name = extractFileName(url);
    Map<String, dynamic> updateObject = {
      "image": ""
    };

    try {
      bool success = await EstateRepository.updateEstate(id, updateObject);
      if (success) {
        final Reference folder = storage.child("$id/$name");
        await folder.delete();
        // TODO: give feedback
      }
    } catch (err) {
      return;
    }
  }

  // TODO: comment
  Future<void> deleteImagesForElement(String id, String url, List<String> images) async {
    String name = extractFileName(url);

    int index = images.indexWhere((element) => element == url);
    if (index == -1) return;

    images = [...images.sublist(0, index), ...images.sublist(index + 1, images.length)];

    try {
      bool success = await ElementRepository.updateElement(id, {"images": images});
      if (success) {
        final Reference folder = storage.child("$id/$name");
        await folder.delete();
        // TODO: give feedback
      }
    } catch (err) {
      return;
    }
  }

    // TODO: comment
  Future<void> deleteBackgroundForElement(String id, String url) async {
    String name = extractFileName(url);

    try {
      bool success = await ElementRepository.updateElement(id, {"background": ""});
      if (success) {
        final Reference folder = storage.child("$id/$name");
        await folder.delete();
        // TODO: give feedback
      }
    } catch (err) {
      return;
    }
  }

    // TODO: comment
  Future<String> downloadImage(String id, String name) async {
    try {
      final Reference folder = storage.child(id);
      final Reference fileRef = folder.child(name);
      String url = await fileRef.getDownloadURL();
      return url;
    } catch (err) {
      return "";
    }
  }

  String extractFileName(String url) {
    String substring = url.substring(url.indexOf('%2F', 98) + 3, url.indexOf('?', 98));
    return substring;
  } 
}

class GoogleAuthService {
  static final firebase.FirebaseAuth firebaseAuth =
      firebase.FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          "236389351601-0q6kgflcvpferc94od95bk5o79385q8m.apps.googleusercontent.com",
      scopes: []);

  /*Firebase.User? userFromFirebase(Firebase.UserCredential? credentials) {
    if (credentials == null) return null;
credentials.user.

    return  Firebase.User(uid: credentials.user!.uid);
  }*/

  /*Stream<Firebase.User> get onAuthStateChanged {
    return firebaseAuth.
  }*/

  // Future<Firebase.User?> signInWithGoogle() async {
  static Future<firebase.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await googleSignIn.signInSilently();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final firebase.AuthCredential credential =
          firebase.GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final firebase.UserCredential authResult =
          await firebaseAuth.signInWithCredential(credential);

      return authResult.user;
    } catch (err) {
      return null;
    }
    // return userFromFirebase(authResult);
  }

  static Future<void> signOut() async {
    return firebaseAuth.signOut();
  }

  static Future<firebase.User?> currentUser() async {
    final firebase.User? user = firebaseAuth.currentUser;
    // return userFromFirebase(user);
    return user;
  }
}

// TODO: comment
class UserRepository {
  static final users = FirebaseFirestore.instance.collection("users");
  
  // TODO: comment
  static Future<localUser.User?> createCustomer(Map<String, dynamic> userMap) async {
    try {
      QuerySnapshot<Map<String, dynamic>> res = await users.where("email", isEqualTo: userMap["email"]).get();

      if (res.docs.isEmpty) {
        DocumentSnapshot<Map<String, dynamic>> docSnapshot = await (await users.add(userMap)).get();
        Map<String, dynamic>? res = docSnapshot.data();

        res?["id"] = docSnapshot.id;

        if (res != null) return localUser.User.toUser(res);
      }
      
      return null;
    } catch (err) {
      return null;
    }
  }

  static Future<void> addEstate(String userId) async {
    if (userId.isEmpty) return;

    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await users.doc(userId).get();
      Map<String, dynamic>? userMap = documentSnapshot.data();
      if (userMap == null) return;

      int numOfEstates = userMap['numOfEstates'];

      await users.doc(userId).update({"numOfEstates": (numOfEstates + 1)});
    } catch (err) {
      return;
    }
  }
  
  static Future<void> removeEstate(String userId) async {
    if (userId.isEmpty) return;

    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await users.doc(userId).get();
      Map<String, dynamic>? userMap = documentSnapshot.data();
      if (userMap == null) return;

      int numOfEstates = userMap['numOfEstates'];

      if (numOfEstates > 0) {
        await users.doc(userId).update({"numOfEstates": (numOfEstates - 1)});
      }
    } catch (err) {
      return;
    }
  }

  // TODO: comment
  static Future<Map<String, dynamic>?> readUserWithId(String? id) async {
    if (id == null || id.isEmpty) return null;

    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await users.doc(id).get();
      Map<String, dynamic>? userMap = docSnapshot.data();
      if (userMap == null) return null;

      userMap["id"] = docSnapshot.id;
      return userMap;
    } catch (err) {
        return null;
    }
  }

  // TODO: Front-end shouldn't check if there are more docs with the same email
  // TODO: comment
  static Future<User?> loginUser(String email, String password) async {
    if (password.length < 8) return null;

    password = sha256.convert(utf8.encode(password)).toString();

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await users
          .where("email", isEqualTo: email)
          .where("password", isEqualTo: password)
          .where("blocked", isEqualTo: false)
          .where("banned", isEqualTo: false)
          .get();

      if (querySnapshot.docs.length == 1) {
        Map<String, dynamic> userMap = querySnapshot.docs[0].data();
        userMap["id"] = querySnapshot.docs[0].id;

        User? user = User.toUser(userMap);
        if (user == null) return null;

        return user;
      }
    } catch (err) {
      return null;
    }
    return null;
  }

  // TODO: comment
  static Future<bool> updateUser(String id, Map<String, dynamic> JSONCustomer) async {
    bool success = false;

    try {
      await users.doc(id).update(JSONCustomer);
      success = true;
    } catch (err) {
      success = false;
    }
    return success;
  }

  // TODO: comment
  static Future<bool> deleteUser(String userId, String password) async {
    if (password.length < 8) return false;

    try {
      DocumentSnapshot<Map<String, dynamic>> res = await users.doc(userId).get();
      Map<String, dynamic>? userMap = res.data();
      if (userMap == null) return false;

      if (userMap["password"] != null && userMap["password"] == password) {
        await users.doc(userId).delete();
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  // TODO: comment
  static Future<bool> blockUser(String id, bool wantedState) async {
    if (id.isEmpty) return false;

    try {
      DocumentSnapshot<Map<String, dynamic>> res = await users.doc(id).get();

      if (res["blocked"] == wantedState) {
        return true;
      } else {
        await users.doc(id).update({"blocked": wantedState});
        return true;
      }
    } catch (err) {
      return false;
    }
  }

  // TODO: comment
  static Future<bool?> banUser(String id) async {
    if (id.isEmpty) return false;

    try {
      DocumentSnapshot<Map<String, dynamic>> res = await users.doc(id).get();

      if (res["banned"] == true) {
        return null;
      } else if (res["banned"] == false) {
        await users.doc(id).update({
          "avatarImage": "",
          "backgroundImage": "",
          "banned": true,
          "birthday": "",
          "blocked": true,
          "city": "",
          "companyName": "",
          "coordinates": null,
          "country": "",
          "dateFormat": "",
          "distance": "",
          "email": res["email"],
          "firstname": "",
          "language": "",
          "lastname": "",
          "numOfEstates": 0,
          "ownerFirstname": "",
          "ownerLastname": "",
          "password": "",
          "phone": "",
          "street": "",
          "temperature": "",
          "typeOfUser": res["typeOfUser"],
          "zip": ""
        });
        return true;
      }
    } catch (err) {
      return false;
    }
  }

  static Future<bool> checkPasswordMatching(String userId, String oldPassword) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await users.doc(userId).get();
    Map<String, dynamic>? res = docSnapshot.data();
    if (res == null) return false;

    return res['password'] == oldPassword;
  }
}

// TODO: comment
class EstateRepository {
  static final estates = FirebaseFirestore.instance.collection("estates");

  // TODO: comment
  static Future<Estate?> createEstate(Map<String, dynamic> estateMap) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await (await estates.add(estateMap)).get();
      Map<String, dynamic>? res = docSnapshot.data();
      if (res == null) return null;

      res["id"] = docSnapshot.id;
      return Estate.toEstate(res);
    } catch (err) {
      return null;
    }
  }

  // TODO: comment
  static Future<bool> updateEstate(String estateId, Map<String, dynamic> estateMap) async {
    bool success = false;

    try {
      await estates.doc(estateId).update(estateMap);
      success = true;
    } catch (err) {
      success = false;
    }
    return success;
  }

  // TODO: comment
  static Future<bool> deleteEstate(String estateId) async {
    bool success = false;

    try {
      await estates.doc(estateId).delete();
      success = true;
    } catch (err) {
      success = false;
    }
    return success;
  }
}

// TODO: comment
class CategoryRepository {
  static final categories = FirebaseFirestore.instance.collection("categories");

  // TODO: comment
  static Future<localCategory.Category?> createCategory(Map<String, dynamic> categoryMap) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await (await categories.add(categoryMap)).get();
      Map<String, dynamic>? res = docSnapshot.data();
      if (res == null) return null;

      res["id"] = docSnapshot.id;
      return localCategory.Category.toCategory(res);
    } catch (err) {
      return null;
    }
  }

  // TODO: comment
  static Future<bool> updateCategory(String categoryId, Map<String, dynamic> categoryMap) async {
    bool success = false;

    try {
      await categories.doc(categoryId).update(categoryMap);
      success = true;
    } catch (err) {
      success = false;
    }
    return success;
  }

  // TODO: comment
  static Future<bool> deleteCategory(String categoryId) async {
    bool success = false;

    try {
      await categories.doc(categoryId).delete();
      success = true;
    } catch (err) {
      success = false;
    }
    return success;
  }
}

class ElementRepository {
  static final elements = FirebaseFirestore.instance.collection("elements");

  // TODO: comment
  static Future<localElement.Element?> createElement(Map<String, dynamic> elementMap) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await (await elements.add(elementMap)).get();
      Map<String, dynamic>? res = docSnapshot.data();
      if (res == null) return null;

      res["id"] = docSnapshot.id;
      return localElement.Element.toElement(res);
    } catch (err) {
      return null;
    }
  }

  // TODO: comment
  static Future<bool> updateElement(String elementId, Map<String, dynamic> elementMap) async {
    bool success = false;

    try {
      await elements.doc(elementId).update(elementMap);
      success = true;
    } catch (err) {
      success = false;
    }
    return success;
  }

  // TODO: comment
  static Future<bool> deleteElement(String elementId) async {
    bool success = false;

    try {
      await elements.doc(elementId).delete();
      success = true;
    } catch (err) {
      success = false;
    }
    return success;
  }
}