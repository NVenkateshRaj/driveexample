import 'dart:io';
import 'package:driveexample/appState.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DataBaseHelper{



  static final dbName="expence.db";
  static final dbVersion=1;
  static Database db;
  static final tableName="expenceTable";
  static final columnId='id';
  static final columnName="amount";
  static final mailColumn="mailId";
  static final tableName1="expenceTable";
  static final amountColumn="amount";
  static final dateColumn='date';
  static final categoryColumn='category';
  static final noteColumn='notes';
  static final typeColumn='type';






  DataBaseHelper.constructor();

  static final DataBaseHelper instance= DataBaseHelper.constructor();


  Future<Database> get dataBase async{
    if(db!=null){
      return db;
    }
    else{
      db=await initDataBase();
      return db;
    }
  }


  initDataBase()async{

    Directory directory=await getExternalStorageDirectory();

    String path=join(directory.path,dbName);
    print(path);
    return await openDatabase(path,version: dbVersion,onCreate: onCreate);
  }


  Future onCreate(Database database,int version)async{
    //Create a table with columns
    // three comma  is used to assume multiple lines of strings as a single line string
    print("Enter");
    return await database.execute(
        ''' 
      CREATE TABLE $tableName1(
      $columnId INTEGER PRIMARY KEY ,
      $mailColumn TEXT ,
      $amountColumn TEXT NOT NULL ,
      $dateColumn TEXT NOT NULL ,
      $categoryColumn TEXT NOT NULL ,
      $noteColumn TEXT NOT NULL ,
      $typeColumn TEXT NOT NULL
      )
     '''
    );
  }


  Future<int> insert(Map<String,dynamic> row)async{
    Database db=await instance.dataBase;
    return await db.insert(tableName, row);
  }


  Future<List<Map<String,dynamic>>> query()async{
    Database db=await instance.dataBase;
    return await db.query(tableName);
  }



  Future<List<Map<String,dynamic>>> filterQuery(String formattedDates)async{
    String mail=googleSignIn.currentUser.email.toString();
    Database db=await instance.dataBase;
    return  await db.rawQuery("SELECT * FROM $tableName WHERE $mailColumn=? and date=?",[mail,formattedDates]);
  }


  Future<int> update(Map<String,dynamic> row)async{
    Database db=await instance.dataBase;
    int id=row[columnId];
    print("Update");
    print(row[columnId]);
    return await db.update(tableName, row,where: '$columnId=?',whereArgs: [id]);
  }


  Future<int> delete(int id)async{
    print("delete called");
    print("id is.... $id");
    Database db=await instance.dataBase;
    return await db.delete(tableName, where: '$columnId=?',whereArgs: [id]);
  }

}
