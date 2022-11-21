import 'package:gakujo_task/models/subject.dart';

class Message {
  Subject subject;
  String lastMessage;
  String lastTime;
  bool isContinue;

  Message(this.subject, this.lastMessage, this.lastTime,
      {this.isContinue = false});

  static List<Message> generateMessages() {
    return [
      Message(subjects[0], 'lastMessage\nlastMessagelastMessage\nlastMessage',
          'lastTime'),
      Message(subjects[1], 'lastMessage', 'lastTime'),
      Message(subjects[2], 'lastMessage', 'lastTime'),
      Message(subjects[3], 'lastMessage', 'lastTime'),
      Message(subjects[4], 'lastMessage', 'lastTime'),
      Message(subjects[5], 'lastMessage', 'lastTime'),
      Message(subjects[0], 'lastMessage\nlastMessagelastMessage\nlastMessage',
          'lastTime'),
      Message(subjects[1], 'lastMessage', 'lastTime'),
      Message(subjects[2], 'lastMessage', 'lastTime'),
      Message(subjects[3], 'lastMessage', 'lastTime'),
      Message(subjects[4], 'lastMessage', 'lastTime'),
      Message(subjects[5], 'lastMessage', 'lastTime'),
    ];
  }
}

var subjects = Subject.generateSubjects();
