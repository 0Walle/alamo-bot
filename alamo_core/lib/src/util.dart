import "dart:mirrors" show ClosureMirror;

import "package:alamo_core/alamo_core.dart";

final whitespaceRegex = RegExp(" +");

List<String> getNames(ClosureMirror m) {
  for (final meta in m.function.metadata) {
    if (meta.reflectee is Command) {
      final Command r = meta.reflectee;
      return r.aliases.toList()..add(r.name);
    }
  }
  throw Exception(
      "The command you tryed to use, isn't tagged as a command, so it's not a command :/");
}

class InputListener extends Listener {
  String id;
  int index;
  void Function(Message) callback;
  int timeout;
  String timeoutMessage;
  InputListener(this.id, this.index, this.callback, Duration timeout,
      this.timeoutMessage) {
    this.timeout = DateTime.now().add(timeout).millisecondsSinceEpoch;
  }

  @override
  void onMessage(Context ctx) {
    if (DateTime.now().millisecondsSinceEpoch >= timeout) {
      ctx.bot.listeners.removeAt(index);
      ctx.send(timeoutMessage, mention: true);
    } else if (ctx.message.author.id == id) {
      ctx.bot.listeners.removeAt(index);

      callback(ctx.message);
    }
  }
}
