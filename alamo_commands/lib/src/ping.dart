import "package:alamo_core/alamo_core.dart";

@Command("ping")
void ping(Context ctx) {
  ctx.send(", pong!", mention: true);
}
