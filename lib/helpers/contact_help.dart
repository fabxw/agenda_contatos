import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String id_column = "id_column";
final String name_column = "name_column";
final String email_column = "email_column";
final String phone_column = "phone_column";
final String image_column = "image_column";

final String contactTable = "ContactTable";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final dataBasePath = await getDatabasesPath();
    final path = join(dataBasePath, "contacts.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE $contactTable($id_column INTEGER PRIMARY KEY, $name_column TEXT, "
            "$email_column TEXT, $phone_column TEXT, $image_column TEXT)");
      },
    );
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
      contactTable,
      columns: [
        id_column,
        name_column,
        email_column,
        phone_column,
        image_column
      ],
      where: "$id_column = ?",
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContacts(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable,
      where: "$id_column = ? ",
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$id_column = ?",
      whereArgs: [contact.id],
    );
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT (*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact();

  Contact.fromMap(Map map) {
    id = map[id_column];
    name = map[name_column];
    email = map[email_column];
    phone = map[phone_column];
    image = map[image_column];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      name_column: name,
      email_column: email,
      phone_column: phone,
      image_column: image
    };
    if (id != null) {
      map[id_column] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone,image: $image)";
  }
}
