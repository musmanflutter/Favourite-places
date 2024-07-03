import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Place {
  Place({
    required this.title,
    required this.image,
    //we are saying accept id as well even though we have  a unique id already uuid
    String? id,
    //by ?? we are saying store id to the id got, if its empty then cuse uuid to create one
  }) : id = id ?? uuid.v4();
  final String title;
  final String id;
  final File image;
}
