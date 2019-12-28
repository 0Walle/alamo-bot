import 'package:alamo_core/alamo_core.dart';

abstract class MessageBuilder {
  String build();

  void text(String s);
  void bold(String s);
  void italic(String s);
  void spoiler(String s);
}

abstract class Embed {
  void author(User u);
  void description(String s);
  void field(String title, String content);
  void footer(String s);
}
