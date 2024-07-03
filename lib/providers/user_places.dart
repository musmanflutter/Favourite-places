import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
//this package helps in setting path in system acc to system
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

//these two packages are used to create an sql data base in operating system
//where we can store our data.
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:favourite_places/models/place.dart';

//this function setsup the sql database.
Future<Database> _getDataBase() async {
  //getDatabasesPath: Get the default databases location.
  final dbPath = await sql.getDatabasesPath();
  //openDatabase: Open the database at a given path
  //join: helps in constructing a path
  //since dbpath doesnt point at a database, insted just to the directory where we can create
  //database, we provided dbpath as a first argu, because .join needs a path, and then the name of db 'places.db'
  //.db after name is necessary
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    //oncreate: this method is executed once a db is created for the first time
    //it allows to perform some initial setup work
    onCreate: (database, version) {
      //.execute: executes a sql query, it takes a query which should be executed
      //we just write a query by create a table of name user_places having columns likeid, title, image
      //we define ther type as well like id will n=be of type text and its primarykey as well
      //we set image type as TEXT because we will just store the path of the image.
      return database.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT)');
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);
  //this method will load data from os db
  Future<void> loadPlaces() async {
    final db = await _getDataBase();
    //query: gets the data from query, it requires table name
    final data = await db.query('user_places');
    //now we are converting the lust maps(rows) got by data to a suitable form
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
          ),
        )
        .toList();
    state = places;
  }

//we are using async/await because syspaths.getApplicationDocumentsDirectory()
//gives a future value object.
  void addPlace(String title, File image) async {
    //getApplicationDocumentsDirectory: gets Path to a directory where the application may place data that is user-generated
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    //basename; Gets the part of [path] after the last separator.(file)
    final fileName = path.basename(image.path);
    //image.copy copies image in a path
    //we define path be setting pathdirectory like aplocationdata/filename etc.
    //since .copy gives a future value, we store it in a variable.
    final copiedImage = await image.copy('${appDir.path}/$fileName');

    final newPlace = Place(title: title, image: copiedImage);

    final db = await _getDataBase();
    //insert. inserts in an object(db in this case)
    //it requires table name user_places  and values to it
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
    });
    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
