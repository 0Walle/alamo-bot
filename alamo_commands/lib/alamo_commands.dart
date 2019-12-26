/// Support for doing something awesome.
///
/// More dartdocs go here.
library alamo_commands;

import "package:alamo_core/alamo_core.dart";

export 'src/ping.dart';
import "src/ping.dart";

export 'src/roll.dart';
import "src/roll.dart";

void registerAll(Bot bot) {
  bot.addCommand(ping);
  bot.addCommand(roll);
}
