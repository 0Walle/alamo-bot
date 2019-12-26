import "package:alamo_core/alamo_core.dart";

enum EventType {
  OnMessage,
  OnUserNameChange,
  OnUserPermissionUpdate,
  Raw,
}

class Listener {
  void onMessage(Context ctx) {}
  void onUserNameChange(User old, User _new) {}
  void onUserPermissionUpdate(User old, User _new) {}
  void raw(EventType event, List<dynamic> args) {}
}

extension ListenerCaller on Listener {
  void callOnMessage(Context ctx) {
    raw(EventType.OnMessage, [ctx]);
    onMessage(ctx);
  }

  void callOnUserNameChange(User old, User _new) {
    raw(EventType.OnUserNameChange, [old, _new]);
    onUserNameChange(old, _new);
  }

  void callOnUserPermissionUpdate(User old, User _new) {
    raw(EventType.OnUserPermissionUpdate, [old, _new]);
    onUserNameChange(old, _new);
  }
}
