import "package:alamo_core/alamo_core.dart";

enum TokenType { LPAREN, RPAREN, NUMBER, ID, STRING, EOF }

class Token {
  TokenType kind;
  num num_val;
  String str_val;

  Token(this.kind, this.num_val, this.str_val);
  Token.LPAREN() {this.kind = TokenType.LPAREN;}
  Token.RPAREN() {this.kind = TokenType.RPAREN;}
  Token.EOF() {this.kind = TokenType.EOF;}
  Token.NUMBER(this.num_val){this.kind = TokenType.NUMBER;}
  Token.SYMBOL(this.str_val){this.kind = TokenType.ID;}
  Token.STRING(this.str_val){this.kind = TokenType.STRING;}

  String toString() {
    const names = ["(", ")", "NUM", "ID", "STR", "EOF"];
    return 'Token[${names[this.kind.index]}]: ${this.num_val ?? ''}${this.str_val ?? ''}';
  }
}

enum ExprType { NUM, STR, SYM, LIST, PAIR, FUNC }

class Expr {
  ExprType kind;
  num num_val;
  String str_val;
  List<Expr> list_val;
  List<String> args;
  CallFrame acess;

  Expr(this.kind, this.num_val, this.str_val, this.list_val);
  Expr.NUM(this.num_val) { this.kind = ExprType.NUM;}
  Expr.SYM(this.str_val) { this.kind = ExprType.SYM;}
  Expr.STR(this.str_val) { this.kind = ExprType.STR;}
  Expr.LIST(this.list_val) { this.kind = ExprType.LIST;}
  Expr.PAIR(this.list_val) { this.kind = ExprType.PAIR;}
  Expr.FUNC(this.args, this.list_val, this.acess) { this.kind = ExprType.FUNC;}

  bool isNil() {
    return this.kind == ExprType.LIST && this.list_val.length == 0;
  }

  num get as_num{
    if(this.kind != ExprType.NUM) throw "TypeError: Expression `${this.toDebug()}` is not a number";
    return num_val;
  }

  String get as_str{
    if(this.kind != ExprType.STR) throw "TypeError: Expression `${this.toDebug()}` is not a string";
    return str_val;
  }

  String get as_sym{
    if(this.kind != ExprType.SYM) throw "TypeError: Expression `${this.toDebug()}` is not a symbol";
    return str_val;
  }

  bool equal(Expr e){
    if(this.kind != e.kind) return false;
    switch (this.kind) {
      case ExprType.NUM:
        return this.num_val == e.num_val;
      case ExprType.STR:
      case ExprType.SYM:
        return this.str_val == e.str_val;
      case ExprType.LIST:
        for(var i = 0; i < this.list_val.length; i++){
          if(!this.list_val[i].equal(e.list_val[i])) return false;
        }
        return true;
      case ExprType.PAIR:
        return this.list_val[0].equal(this.list_val[1]);
      case ExprType.FUNC:
        return false;
    }
  }

  String toString() {
    switch (this.kind) {
      case ExprType.NUM:
        return '${this.num_val}';
      case ExprType.STR:
        return '${this.str_val}';
      case ExprType.SYM:
        return this.str_val;
      case ExprType.LIST:
        return '(${this.list_val.join(" ")})';
      case ExprType.PAIR:
        return '(${this.list_val[0]} . ${this.list_val[1]})';
      case ExprType.FUNC:
        return '${this.args} -> ${this.list_val[0]}';
    }
  }

  String toDebug() {
    switch (this.kind) {
      case ExprType.NUM:
        return '#${this.num_val}';
      case ExprType.STR:
        return '"${this.num_val}"';
      case ExprType.SYM:
        return '\'${this.str_val}';
      case ExprType.LIST:
        return '\'(${this.list_val.map((a) => a.toDebug()).join(" ")})';
      case ExprType.PAIR:
        return '\'(${this.list_val[0].toDebug()} . ${this.list_val[1].toDebug()})';
      case ExprType.FUNC:
        return '${this.args} -> ${this.list_val[0].toDebug()}';
    }
  }
}

final NUMBER_RE = RegExp(r"[0-9]+(\.[0-9]+)?");
final STRING_RE = RegExp(r'"[^"]*"');
final SYMBOL_RE = RegExp(r"[a-zA-Z_@#\$´.:?+\-\*/\\%><&\^~|=!][a-zA-Z0-9_@#\$´.:?+\-\*/\\%><&\^~|=!]*");

final native_scope = {
  "*": (arr) => new Expr.NUM(arr[0].as_num * arr[1].as_num),
  "+": (arr) => new Expr.NUM(arr[0].as_num + arr[1].as_num),
  "-": (arr) => new Expr.NUM(arr[0].as_num - arr[1].as_num),
  "/": (arr) => new Expr.NUM(arr[0].as_num / arr[1].as_num),
  "//": (arr) => new Expr.NUM( arr[0].as_num ~/ arr[1].as_num),
  "%": (arr) => new Expr.NUM(arr[0].as_num % arr[1].as_num),
  "<": (arr) => new Expr.NUM(arr[0].as_num < arr[1].as_num),
  ">": (arr) => new Expr.NUM(arr[0].as_num > arr[1].as_num),
  "<=": (arr) => new Expr.NUM(arr[0].as_num <= arr[1].as_num),
  ">=": (arr) => new Expr.NUM(arr[0].as_num >= arr[1].as_num),
  "..": (arr) => new Expr.STR(arr[0].as_str + arr[1].as_str),
  "str.len": (arr) => new Expr.NUM(arr[0].as_str.length),
  "str.slice": (arr) => new Expr.STR(arr[0].as_str.substring(arr[1].as_num,arr[2].as_num)),
  "str.tail": (arr) => new Expr.STR(arr[0].as_str.substring(arr[1].as_num)),
  "str.char": (arr) => new Expr.STR(arr[0].as_str[arr[1].as_num]),
  "==": (arr) =>
      arr[0].equal(arr[1]) ? new Expr.SYM("t") : new Expr.LIST([]),
  "!=": (arr) =>
      !arr[0].equal(arr[1]) ? new Expr.SYM("t") : new Expr.LIST([]),
};

class LispVM{

  var source;
  var _expr;
  static final nil = new Expr.LIST([]);

  Map<String, Expr> global_scope = {
    "nil": nil
  };

  List<CallFrame> stack = [];

  LispVM(this.source){
    _expr = parseExpr(nextToken());
    print(_expr);
  }

  Expr eval(){
    return evaluate(_expr);
  }

  Token nextToken() {
    source = source.trimLeft();
    if (source == "") return new Token.EOF();
    Match match;
    if (source[0] == "(") {
      source = source.substring(1);
      source = source.trimLeft();
      return new Token.LPAREN();
    } else if (source[0] == ")") {
      source = source.substring(1);
      source = source.trimLeft();
      return new Token.RPAREN();
    } else if ((match = NUMBER_RE.matchAsPrefix(source)) != null) {
      final n = match[0];
      source = source.substring(n.length);
      source = source.trimLeft();
      return new Token.NUMBER(double.parse(n));
    } else if ((match = STRING_RE.matchAsPrefix(source)) != null) {
      final n = match[0];
      source = source.substring(n.length);
      source = source.trimLeft();
      return new Token.STRING(n.substring(1,n.length-1));
    } else if ((match = SYMBOL_RE.matchAsPrefix(source)) != null) {
      final n = match[0];
      source = source.substring(n.length);
      source = source.trimLeft();
      return new Token.SYMBOL(n);
    } else {
      return null;
    }
  }

  Expr parseExpr(look) {
    if (look.kind == TokenType.LPAREN) {
      List<Expr> list_val = [];
      Token tok;
      while ((tok = nextToken())?.kind != TokenType.RPAREN) {
        if (tok == null) throw "ParseError: Invalid Syntax";
        if (tok.kind == TokenType.EOF) throw "ParseError: Unexpected End of Input";
        list_val.add(parseExpr(tok));
      }
      return new Expr.LIST(list_val);
    } else if (look.kind == TokenType.NUMBER) {
      return new Expr.NUM(look.num_val);
    } else if (look.kind == TokenType.STRING) {
      return new Expr.STR(look.str_val);
    } else if (look.kind == TokenType.ID) {
      return new Expr.SYM(look.str_val);
    } else {
      throw "ParseError: Invalid Syntax";
    }
  }

  Expr getSymbol(String sym){
    for(var frame in stack.reversed){
      var e = frame.gets(sym);
      if(e != null) return e;
    }
    if(global_scope[sym] != null) return global_scope[sym];
    return null;
  }

  Expr evaluate(Expr e) {
    if (e.kind == ExprType.LIST) {
      final list = e.list_val;
      if (list[0].kind == ExprType.SYM) {
        switch (list[0].str_val) {
          case "quote":
            return list[1];
          case "head":
            if(list[1]?.kind != ExprType.LIST) throw "TypeError: Expression `${list[1]?.toDebug() ?? 'nil'}` is not a list";
            return list[1].list_val[0];
          case "tail":
            if(list[1]?.kind != ExprType.LIST) throw "TypeError: Expression `${list[1]?.toDebug() ?? 'nil'}` is not a list";
            return new Expr.LIST(list[1].list_val.sublist(1));
          case "if":
            if(list.length < 4) throw "CallError: Not enough arguments";
            return evaluate(list[1]).isNil() ? evaluate(list[3]) : evaluate(list[2]);
          case "cond":
            for(var cond in list.sublist(1)){
              if(cond.kind != ExprType.LIST) throw "TypeError: Expression `${cond.toDebug()}` is not a list";
              if(!evaluate(cond.list_val[0]).isNil()) return evaluate(cond.list_val[1]);
            }
            return nil;
          case "and":{
            Expr e = new Expr.SYM('t');
            for(var cond in list.sublist(1)){
              if((e = evaluate(cond)).isNil()) return e;
            }
            return e;
          }
          case "or":{
            Expr e = nil;
            for(var cond in list.sublist(1)){
              if(!((e = evaluate(cond)).isNil())) return e;
            }
            return e;
          }
          case "atom?":
            if(list.length < 2) throw "CallError: Not enough arguments";
            return evaluate(list[1]).kind != ExprType.LIST? new Expr.SYM('t') : nil;
          case "cons":{
            if(list.length < 3) throw "CallError: Not enough arguments";
            Expr left = evaluate(list[1]);
            Expr right = evaluate(list[2]);
            if (right.kind == ExprType.LIST)
              return new Expr.LIST([left, ...right.list_val]);
            return new Expr.PAIR([left, right]);
          }
          case "lambda":
            if(list.length < 3) throw "CallError: Not enough arguments";
            if(list[1].kind != ExprType.LIST) throw "TypeError: Expression `${list[1].toDebug()}` is not a list";
            return new Expr.FUNC(
                list[1].list_val.map((a) => a.str_val).toList(), [list[2]],stack.isEmpty? null :stack.last);
          case "global":
            if(list.length < 3) throw "CallError: Not enough arguments";
            if(list[1].kind != ExprType.LIST) throw "TypeError: Expression `${list[1].toDebug()}` is not a list";
            {
              list[1].list_val.forEach((decl) => decl.kind == ExprType.LIST?
                  global_scope[decl.list_val[0].as_sym] = evaluate(decl.list_val[1])
                : null);
              return evaluate(list[2]);
            }
          case "def":
            if(list.length < 4) throw "CallError: Not enough arguments";
            if(list[1].kind != ExprType.SYM) throw "TypeError: Expression `${list[1].toDebug()}` is not a symbol";
            if(list[2].kind != ExprType.LIST) throw "TypeError: Expression `${list[1].toDebug()}` is not a list";

            global_scope[list[1].str_val] =
              new Expr.FUNC(list[2].list_val.map((a) => a.as_sym).toList(), [list[3]],stack.isEmpty? null :stack.last);
            return nil;

          case "block":{
            Expr e = nil;
            for(var expr in list.sublist(1)){
              e = evaluate(expr);
            }
            return e;
          }
          default:
            var loc = getSymbol(list[0].str_val);
            if(loc != null){
              CallFrame local_scope = new CallFrame(loc.acess,{});
              var argn = 1;
              for (final arg in loc.args) {
                local_scope.add(arg,evaluate(list[argn]));
                argn++;
              }
              stack.add(local_scope);
              var result = evaluate(loc.list_val[0]);
              stack.removeLast();
              return result;
            }

            var glob = global_scope[list[0].str_val];
            if (glob != null) {

              CallFrame local_scope = new CallFrame(glob.acess,{});
              var argn = 1;
              for (final arg in glob.args) {
                local_scope.add(arg,evaluate(list[argn]));
                argn++;
              }
              stack.add(local_scope);
              var result = evaluate(glob.list_val[0]);
              stack.removeLast();
              return result;
            }
            var nat = native_scope[list[0].str_val];
            if(nat != null)
              return nat(list.sublist(1).map((e) => evaluate(e)).toList());
            throw "TypeError: Expression `${list[0].toDebug()}` is not a function";
        }
      } else {
        Expr callee = evaluate(list[0]);
        if (callee.kind == ExprType.FUNC) {
          CallFrame local_scope = new CallFrame(callee.acess,{});
          var argn = 1;
          for (final arg in callee.args) {
            local_scope.add(arg,evaluate(list[argn]));
            argn++;
          }
          stack.add(local_scope);
          var ret = evaluate(callee.list_val[0]);
          stack.removeLast();
          return ret;
        }
        throw "TypeError: Expression `${callee.toDebug()}` is not a function";
      }
    } else if (e.kind == ExprType.SYM) {
      return getSymbol(e.str_val) ?? e;
    } else
      return e;
  }
}

class CallFrame{
  CallFrame access;
  Map<String, Expr> scope;

  CallFrame(this.access, this.scope);

  Expr gets(String sym){
    if(scope[sym] != null) return scope[sym];
    return access?.gets(sym);
  }

  void add(String sym, Expr e){
    scope[sym] = e;
  }

  String toString(){
    return '${this.access ?? "{}"} <= ${scope}';
  }
}

@Command("lisp")
void lisp(Context ctx) {
  try{
    var vm = new LispVM(ctx.message.arguments.join(" "));
    ctx.send(vm.eval());
  }catch(e){
    ctx.send(e);
  }
}
