import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {

  final TextEditingController noteController = TextEditingController();

  Future<void> addNote() async {
    await FirebaseFirestore.instance.collection('notes').add({
      'note': noteController.text,
      'createdAt': Timestamp.now(),
    });

    noteController.clear();
  }

  Future<void> deleteNote(String id) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Notes"),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: "Enter Note",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          ElevatedButton(
            onPressed: addNote,
            child: const Text("Add Note"),
          ),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('notes')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var notes = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {

                    var note = notes[index];

                    return ListTile(
                      title: Text(note['note']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteNote(note.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
