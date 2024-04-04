import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/widgets/Event_item.dart';

final _firestore = FirebaseFirestore.instance;

class EventType {
  String Name; //Name the Event
  List<String> ServiceType = []; //ServiceType belongs to the event
  String Classification; //Classification of the event.
  String? imageUrl;

  EventType({
    required this.Name,
    required this.ServiceType,
    required this.Classification,
    required this.imageUrl,
  });

//Method to add this object's data to the Firebase database.
  Future<void> addToFirestore() async {
    await _firestore.collection('EventType').add({
      'Name': this.Name,
      'ServiceType': this.ServiceType,
      'Classification': this.Classification,
      'imageUrl': this.imageUrl,
    });
  }
}
