import "dart:mirrors" as mirror;

import "util.dart" show getNames, whitespaceRegex;

import "package:alamo_core/alamo_core.dart";

class Bot {
  String prefix;
  User botUser;
  List<Listener> listeners = [];
  Map<String, CommandFun> commands = {};

  Bot(this.prefix, this.botUser);

  void addCommand(CommandFun f) {
    final names = getNames(mirror.reflect(f));

    names.forEach((name) {
      commands.putIfAbsent(name, () => f);
    });
    print("Command \"${names[0]}\" added with ${names.length - 1} aliases");
  }

  void runCommand(String msg, Context ctx) {
    listeners.forEach((f) => f.callOnMessage(ctx));
    if (!msg.startsWith(prefix)) return;
    final m = msg.replaceFirst(prefix, "").split(whitespaceRegex);
    if (m.isEmpty) return;
    final name = m[0];
    if (!commands.containsKey(name)) return;
    ctx.arguments = m..removeAt(0);
    commands[name](ctx);
  }

  void addListener(Listener listener) {
    listeners.add(listener);
    print("Listener added");
  }
}
