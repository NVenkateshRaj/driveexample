import 'package:driveexample/database.dart';
import 'package:driveexample/entry.dart';
import 'package:driveexample/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn=GoogleSignIn(
    scopes: <String>[
      'email',
       'https://www.googleapis.com/auth/drive.readonly',
      'https://www.googleapis.com/auth/drive.appdata',
      "https://www.googleapis.com/auth/drive.metadata",
      "https://www.googleapis.com/auth/drive.activity",
      "https://www.googleapis.com/auth/drive",
    ]
);

isAlreadyLogin() {
  googleSignIn.onCurrentUserChanged.listen((event) async{
    if(event==null){

    }
    else {

      print(googleSignIn.currentUser.email);
    }
  });

  googleSignIn.signInSilently().then((event) async{
    if(event==null){} else{}
  });
}



Future handleSign()async{
  try
  {
    await googleSignIn.signIn();
    googleSignInAccount=await googleSignIn.signIn();
    print(googleSignIn.currentUser.email);

    //below condition is used to control the navigation to dashboard if user login then redirect to dashboard otherwise present in the login page
    if(googleSignIn.currentUser!=null){
      return true;
    }
    else{
      return false;
    }
  }

  catch(e){
    print(e.toString());
    return false;
  }

}

void hitFilterQuery()async{
  lists=[];
  await DataBaseHelper.instance.query().then((value) => {
    value.forEach((element) {
      print("Entered for loop");
      lists.add(ExpenseEntryModel(amount: element["amount"],date: element['date'],category: element['category'],note: element['notes'],type: element['type'],id: element['id'],mailID: element['mailId']));
    })

  });
}




Future handleSignOut()async{
  await googleSignIn.signOut();
}
