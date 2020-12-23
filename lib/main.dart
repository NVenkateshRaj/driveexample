
import 'dart:io';

import 'package:driveexample/appState.dart';
import 'package:driveexample/database.dart';
import 'package:driveexample/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
List<ExpenseEntryModel> lists=List();
GoogleSignInAccount googleSignInAccount;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  ga.FileList list;
  final storage = new FlutterSecureStorage();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  call()async{
    await hitFilterQuery();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drive"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: RaisedButton(
                  child: Text("Click"),
                  onPressed: (){
                    handleSign();
                    // getStorage();
                  },
                ),
              ),
              Center(
                child: RaisedButton(
                  child: Text("upload"),
                  onPressed: (){
                    _uploadFileToGoogleDrive();

                  },
                ),
              ),
              Center(
                child: RaisedButton(
                  child: Text("Delete"),
                  onPressed: (){
                    deleteDrive();
                   setState(() {});
                  },
                ),
              ),
              Center(
                child: RaisedButton(
                  child: Text("List"),
                  onPressed: (){
                    _listGoogleDriveFiles();
                  },
                ),
              ),
              Center(
                child: RaisedButton(
                  child: Text("SignOut"),
                  onPressed: (){
                    handleSignOut();
                  },
                ),
              ),
              Container(
                child: Column(
                  children: generateFilesWidget(),
                ),
              ),
              Container(
                child: RaisedButton(
                  child: Text("Click to view db file"),
                  onPressed: (){
                    setState(() {
                     call();
                    });
                  },
                ),
              ),
              Container(
                child: FutureBuilder(
                  future: DataBaseHelper.instance.query(),
                  builder: (context,snapShot){
                    if(!snapShot.hasData){
                      return Container(
                        child: Text("No Data"),
                      );
                    }
                    else{
                      return Container(
                        child: ListView.builder(
                          primary: false,
                          itemBuilder:
                              (context, index) {
                            return Container(
                                margin: EdgeInsets.only(top: 20, bottom: 10),
                                child: ListTile(
                                  leading: Container(
                                    decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.green, borderRadius: BorderRadius.circular(10),),
                                    width: 42,
                                    height: 42,
                                    child: Center(child: Icon(Icons.all_inclusive),
                                    ),
                                  ),
                                  title: Text(lists[index].amount.toString()),
                                ),
                            );
                          },
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: lists.length,
                        ),
                      );
                    }
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  deleteDrive()async{
    var response;
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    await drive.files.list().then((value) async {
      setState(() {
        list = value;
      });
      for (var i = 0; i < list.files.length; i++) {
        print("Id: ${list.files[i].id} File Name:${list.files[i].name}");
        response= await drive.files.delete(list.files[i].id);
        print(response);
        print("SuccessFully Deleted");
      }
      list.files.remove(value);
    });
    //_uploadFileToGoogleDrive();
  }

  List<Widget> generateFilesWidget() {
    List<Widget> listItem = List<Widget>();
    if (list != null) {
      for (var i = 0; i < list.files.length; i++) {
        listItem.add(
            Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Text('${i + 1}'),
            ),
            Expanded(
              child: Text(list.files[i].name),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: FlatButton(
                child: Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.indigo,
                onPressed: () {
                  _downloadGoogleDriveFile(list.files[i].name, list.files[i].id);
                },
              ),
            ),
          ],
        ));
      }
    }
    return listItem;
  }


  Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.Media file = await drive.files.get(gdID, downloadOptions: ga.DownloadOptions.FullMedia);
    final directory = await getExternalStorageDirectory();
    final saveFile = File('${directory.path}/$fName');
    List<int> dataStore = [];
    file.stream.listen((data) {
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      saveFile.writeAsBytes(dataStore);
    }, onError: (error) {
    });
  }


  _uploadFileToGoogleDrive() async {
    print(googleSignInAccount.authHeaders);
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.File fileToUpload = ga.File();
    //fileToUpload.parents=["appDataFolder"];
    var response;
    print(response);
    var root = await getExternalStorageDirectory();
    var files = await FileManager(root: root).walk().toList();
    for(var i = 0;i<files.length;i++) {
      File fileName=File(files[i].path);
      fileToUpload.name = path.basename(fileName.absolute.path);
      response= await drive.files.create(fileToUpload,uploadMedia: ga.Media(fileName.openRead(), fileName.lengthSync()));
    }
    print(response);
  }


    Future<void> _listGoogleDriveFiles() async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    drive.files.list().then((value) {
      setState(() {
        list = value;
      });
      for (var i = 0; i < list.files.length; i++) {
        print("Id: ${list.files[i].id} File Name:${list.files[i].name}");
      }
    });
  }
}




class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;
  GoogleHttpClient(this._headers) : super();
  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));
  @override
  Future<http.Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}
