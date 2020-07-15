import 'dart:io';

import 'package:agenda_contatos/helpers/contact_help.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  ContactPage({this.contact});

  final Contact contact;

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;
  bool _userEdited = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  await ImagePicker.pickImage(source: ImageSource.camera)
                      .then((file) {
                    if (file == null) {
                      return;
                    }
                    setState(() {
                      _editedContact.image = file.path;
                    });
                  });
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      // fit: BoxFit.cover,   se der problema no icone da foto redondo
                      image: _editedContact.image != null
                          ? FileImage(File(_editedContact.image))
                          : AssetImage("images/person.png"),
                    ),
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Nome"),
                controller: _nameController,
                focusNode: _nameFocus,
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              Divider(),
              TextField(
                decoration: InputDecoration(labelText: "Email"),
                controller: _emailController,
                onChanged: (text) {
                  _userEdited = true;

                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              Divider(),
              TextField(
                decoration: InputDecoration(labelText: "Phone"),
                controller: _phoneController,
                onChanged: (text) {
                  _userEdited = true;

                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar Alerações?"),
            content: Text("Se sair, as alterações serão perdidas"),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Sim"))
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
