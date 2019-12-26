import "package:alamo_core/alamo_core.dart";

typedef CommandFun = void Function(Context ctx);

class Command {
  final String name;
  final String description;
  final List<String> aliases;

  const Command(this.name, {this.description = "", this.aliases = const []});
}
