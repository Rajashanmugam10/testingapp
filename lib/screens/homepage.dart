import 'package:air/screens/chats.dart';
import 'package:air/services/firestoreauth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'public.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final User? user = Auth().currentUser;
  TextEditingController clubname = TextEditingController();
//  Text(user?.email ?? 'user email'),
  String datetime = DateTime.now().toString();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('userdetails')
                .doc(user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Error Occured");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasData) {
                Map<String, dynamic>? data =
                    snapshot.data!.data() as Map<String, dynamic>?;
                final uid = user!.uid;
                final name = data?['name'];
                final profileimg = data?['profileimage'];
                final List clubs = data?['group'];
                Map map = clubs.asMap();

                return CustomScrollView(
                  // A list of sliver widgets.
                  slivers: <Widget>[
                    CupertinoSliverNavigationBar(
                        largeTitle: Text(
                          'hi' + " " + name,
                          style: const TextStyle(fontSize: 19),
                        ),
                        trailing: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                CupertinoPageRoute(
                                    builder: ((context) =>
                                        const SlidingSegmentedControlDemo()))),
                            child: CircleAvatar(
                              radius: 25,
                              child: ClipOval(
                                child: Image.network(
                                  profileimg,
                                  width: 70,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ))),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CupertinoButton(
                                  child: const Text('create club'),
                                  onPressed: () {
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoPopupSurface(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      2,
                                                ),
                                                const Text(
                                                  'create club',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                const SizedBox(
                                                  height: 30,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: CupertinoTextField(
                                                    controller: clubname,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                CupertinoButton.filled(
                                                    child: const Text(
                                                        'create club'),
                                                    onPressed: () async {
                                                      // await FirebaseFirestore.instance.collection('circle').doc('clubs').
                                                      //club name added to main db
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('clubs')
                                                          .doc(clubname.text)
                                                          .set({
                                                        "clubname":
                                                            clubname.text,
                                                        "owner": name,
                                                        "uid": uid,
                                                        "date": datetime,
                                                        'request': []
                                                      });
                                                      //add to admin club array
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'userdetails')
                                                          .doc(uid)
                                                          .update({
                                                        'clubs': FieldValue
                                                            .arrayUnion(
                                                                [clubname.text])
                                                      });
                                                      //
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'userdetails')
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        'admin': FieldValue
                                                            .arrayUnion(
                                                                [clubname.text])
                                                      });
                                                      //
                                                      FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        'group': FieldValue
                                                            .arrayUnion(
                                                                [clubname.text])
                                                      });
                                                    })
                                              ],
                                            ),
                                          );
                                        });
                                  }),
                              CupertinoButton(
                                  child: const Text('post'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(
                                            builder: (BuildContext context) =>
                                                Public(
                                                  username: name,
                                                  profile: profileimg,
                                                  uid: uid,
                                                )));
                                  }),
                            ],
                          ),
                          //  clubs[index].toString()

                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 2,
                                  width:
                                      MediaQuery.of(context).size.width / 4.6,
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: ListView.builder(
                                    itemCount: map.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            height: 30,
                                            color: Colors.white,
                                            child: Center(
                                                child: Text(clubs[index]))),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const Text('no data');
            }),
      ),
    );
  }
}
