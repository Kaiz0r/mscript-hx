package;
using StringTools;
class GolemParser {
  public var commands = new Map<String, String->Void>();
  public var flags = new Map<String, String>();
  public var output:String->Void;
  public var err:String->Void;
  public var buffer = new Array<String>();
  public var inLine:Int = 0;
  public var VERSION:String = "a0.2.3";
  public function defaultOutput(message){
	buffer.push('$message');
	Sys.println('$message');
  }
  
  public function defaultErr(message){
	buffer.push('${this.inLine} -> $message');
	Sys.println('${this.inLine} -> $message');
  }
  
  public function new(){
	this.flags["version"] = this.VERSION;
	this.output = this.defaultOutput;
	this.err = this.defaultErr;
	
	registerFn("echo", function(message:String) {this.output(message);});
	registerFn("unset", function(message:String) {this.flags.remove(message);});
	
	registerFn("set", function(message:String){
		var parts = message.split(" ");
		var key = parts.shift();
		var value:String = "";
		
		if (parts[0] == "to" || parts[0] == "="){
		  parts.shift();
		  value = parts.join(" ");
		}else{this.err("Invalid format for SET");return;}
		flags[key] = value;
	  });
	
	registerFn("add", function(message:String){
		var parts = message.split(" ");
		var inc = parts.shift();
		var value:String = "";
		var varname:String = "";
		if (parts[0] == "to"){
		  if(!flags.exists(parts[1])){this.err("Param not found: "+parts[1]);return;}
		  varname = parts[1];
		  value = flags[parts[1]];
		}else{this.err("Invalid format for ADD");return;}
		if(Std.parseInt(inc) == null){this.err("Invalid inc for ADD "+inc);return;}
		if(Std.parseInt(value) == null){this.err("Invalid value for ADD "+value);return;}
		if(Std.parseInt(flags[varname]) == null){this.err("Invalid target for ADD "+flags[varname]);return;}
		flags[varname] = Std.string(Std.parseInt(flags[varname]) + Std.parseInt(inc));
	  });
	registerFn("subtract", function(message:String){
		var parts = message.split(" ");
		var inc = parts.shift();
		var value:String = "";
		var varname:String = "";
		if (parts[0] == "from"){
		  if(!flags.exists(parts[1])){this.err("Param not found: "+parts[1]);return;}
		  varname = parts[1];
		  value = flags[parts[1]];
		}else{this.err("Invalid format for SUB");return;}
		if(Std.parseInt(inc) == null){this.err("Invalid inc for SUB "+inc);return;}
		if(Std.parseInt(value) == null){this.err("Invalid value for SUB "+value);return;}
		if(Std.parseInt(flags[varname]) == null){this.err("Invalid target for SUB "+flags[varname]);return;}
		flags[varname] = Std.string(Std.parseInt(flags[varname]) - Std.parseInt(inc));
	  });	
  }

  public function process(text:String):String{
	var out = text;

	for (word in out.split(" ")){
	  if(word.startsWith("$")){
		var t = word.replace("$", "");
		out = out.replace(word, this.flags[t]);
	  }
	}
	return out;
  }
  
  public function parse(text:String){
	this.inLine = 0;
	for (line in text.split(";")){
	  line = line.replace("\n", "");
	  if(line == ""){continue;}
	  var l = line.split(" ");
	  var fn = l.shift();
	  var message = this.process(l.join(" "));

	  if(commands.get(fn) != null){
		commands[fn](message);
	  }else{
		this.err("Bad command: "+fn);
	  }
	  this.inLine = this.inLine + 1;
	}
  }
  
  public function registerFn(name:String, fn:String->Void) {
    commands[name] = fn;
  }
}