abstract class Mentionable {
  String get mention;
}

abstract class Message {
  String get content;
  User get author;
  List<User> get mentions;
}

abstract class User extends Mentionable {
  String get name;
  String get id;
  List<Permission> get permissions;
}

enum Permission {
  ADMIN,
  BAN_USERS,
  KICK_USERS,
  DELETE_MESSAGES,
}
