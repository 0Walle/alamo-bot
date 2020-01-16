import "util.dart" show rand;
import "package:alamo_core/alamo_core.dart";

@Command("roll")
void roll(Context ctx) {
  ctx.send(", seu dado rolou ${rand.nextInt(5) + 1}!", mention: true);
}
