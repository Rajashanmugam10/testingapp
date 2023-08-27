import 'dart:typed_data';

import 'package:air/services/firestoreauth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/imagepicker.dart';

class Public extends StatefulWidget {
  final profile, username, uid;
  const Public({
    super.key,
    required this.username,
    required this.profile,
    required this.uid,
  });
  @override
  State<Public> createState() => _PublicState();
}

class _PublicState extends State<Public> {
  TextEditingController info = TextEditingController();
  Uint8List? _image;
  void SelectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('public')),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CupertinoTextField(
              controller: info,
            ),
          ),
          CupertinoButton(
              onPressed: () {
                SelectImage();
              },
              child: const Icon(
                CupertinoIcons.add_circled_solid,
                size: 100,
              )),
          CupertinoButton.filled(
              child: const Text('data'),
              onPressed: () {
                Auth().uploatpost(
                    uid: widget.uid,
                    username: widget.username,
                    profile: widget.profile,
                    info: info.text,
                    file: _image!);
              }),
          Container(
            height: 300,
            width: 400,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('publicposts')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error Occured");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    final data = snapshot.requireData;
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Container(
                              height: 300,
                              width: 300,
                              child: Image.network(data.docs[index]['post']));
                        });
                  }
                  return const Text('data');
                }),
          )
        ],
      ),
    );
  }
}
