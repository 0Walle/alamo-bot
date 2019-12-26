import "package:alamo_core/alamo_core.dart";

abstract class Context {
  bool dm;
  Message message;
  Bot bot;
  List<String> arguments;

  Context(this.message, this.bot, {this.arguments = const [], dm = false});

  Future<Context> send(String msg, {bool mention = false, bool dm = false});

  Future<Context> edit(String msg, {bool mention = false});

  void delete();

  void input(String ask, void Function(Message) callback,
      {Duration timeout = const Duration(seconds: 5)}); // ask for input
}
