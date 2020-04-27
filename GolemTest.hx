package;

import MScript;

class GolemTest{
  static function main(){
	var parser = new MScript.GolemParser();
	Sys.println("GOLEM: "+parser.VERSION);
	while(true){
	  Sys.print("> ");
	  var ans = Sys.stdin().readLine();
	  parser.parse(ans);
	}
  }
}