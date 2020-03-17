import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
     return new MaterialApp(
       debugShowCheckedModeBanner: false,
       title: 'Flutter Demo',
       theme: new ThemeData(
         primarySwatch:Colors.blue,
       ),
      home:new MyHomePage(),
      );
}
}

class MyHomePage extends StatefulWidget {
 @override
 MyHomePageState createState(){
   return new MyHomePageState();
 }
 
}
class MyHomePageState extends State<MyHomePage>{
  String MyText=null;
  StreamSubscription<DocumentSnapshot>subscription;
  final DocumentReference documentReference =Firestore.instance.document("myData/dummy");
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final GoogleSignIn googleSignIn=new GoogleSignIn();
  Future<FirebaseUser> _signIn() async{
    GoogleSignInAccount googleSignInAccount=await googleSignIn.signIn();
     final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    print("User name: ${user.displayName}");
    return user;
    
  }
  void _signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }
  void add(){
    Map<String,String> data=<String,String>{
      "name": "Harsh ",
      "desc": "Full  stack Webdeveloper",
    };
    documentReference.setData(data).whenComplete((){
      print("Document added");
    }).catchError((e)=>print(e));
  }
  void update(){
    Map<String,String> data=<String,String>{
      "name": "Harsh Tyagi",
      "desc": "App Developer and Full  stack Webdeveloper",
    };
    documentReference.updateData(data).whenComplete((){
      print("Document Updated");
    }).catchError((e)=>print(e));
  }
  void delete(){
    documentReference.delete().whenComplete((){
      print("Document deleted");
      setState(() {});
    }).catchError((e)=>print(e));
  }
  void fetch(){
    documentReference.get().then((datasnapshot){
      if (datasnapshot.exists){
        setState(() {
          MyText=datasnapshot.data['name']+" "+datasnapshot.data['desc'];
        });
        
      }

    });
  }
  @override
  void iniState(){
    super.initState();
    subscription=documentReference.snapshots().listen((datasnapshot){
      if (datasnapshot.exists){
        setState(() {
          MyText=datasnapshot.data['name']+" "+datasnapshot.data['desc'];
        });
        
      }

    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }
   @override
  Widget build(BuildContext context) {
     return new Scaffold(
      appBar: new AppBar(
        title:new Text("Firebase Demo"),
      ),
      body: new Padding(
        padding: EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment:MainAxisAlignment.center,
          crossAxisAlignment:CrossAxisAlignment.stretch,
          children:<Widget>[
            new RaisedButton(onPressed:()=> _signIn().then((FirebaseUser user)=>print(user)).catchError((e)=>print(e)),
            child: new Text("sign In"),
            color: Colors.green,
            ),
            new Padding(
            padding:EdgeInsets.all(10.0),
            ),
            new RaisedButton(onPressed: _signOutGoogle,
            child:new Text("Sign Out"),
            color: Colors.red,
            ),

             new Padding(
            padding:EdgeInsets.all(10.0),
            ),
            new RaisedButton(onPressed:add,
            child:new Text("Add"),
            color: Colors.cyan,
            ),

             new Padding(
            padding:EdgeInsets.all(10.0),
            ),
            new RaisedButton(onPressed: update,
            child:new Text("Update"),
            color: Colors.lightGreenAccent,
            ),
             new Padding(
            padding:EdgeInsets.all(10.0),
            ),
            new RaisedButton(onPressed: delete,
            child:new Text("Delete"),
            color: Colors.limeAccent,
            ),
             new Padding(
            padding:EdgeInsets.all(10.0),
            ),
            new RaisedButton(onPressed:fetch,
            child:new Text("Fetch"),
            color: Colors.lightBlueAccent,
            ),
            new Padding(
            padding:EdgeInsets.all(10.0),
            ),
            MyText==null?new Container() : new Text(MyText,style: new TextStyle(color:Colors.green,fontSize:20),),
            
          ]
        ),
      ),
    );
  }
}

