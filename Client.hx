import flash.display.MovieClip;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.text.TextField;
import flash.net.XMLSocket;
import flash.text.TextFieldType;
import flash.events.Event;
import flash.text.TextFormat;

class ServerApiImpl extends haxe.remoting.AsyncProxy<ServerApi> {}

class Client implements ClientApi 
{
	var api : ServerApiImpl;
	var name : String;
	var tf : TextField;
	var log : TextField;
	var msgText:TextField;

	private function initUI():Void 
	{
		log = new TextField();
		log.x = 60;
		log.y = 5;
		log.height = Lib.current.stage.stageHeight - 170;
		log.width = Lib.current.stage.stageWidth - 120;
		log.border = true;
		log.background = true;
		log.backgroundColor = 0xEEEEEE;
		log.multiline = true;
		Lib.current.stage.addChild(log);

		msgText = new TextField();
		msgText.setTextFormat(new TextFormat('Arial', 16));
		msgText.text = 'Login:';
		msgText.x = 5;
		msgText.y = Lib.current.stage.stageHeight - 95;
		Lib.current.stage.addChild(msgText);

		tf = new TextField();
		tf.setTextFormat(new TextFormat('Arial', 14));
		tf.type = TextFieldType.INPUT; 
		tf.text = '';
		tf.x = 60;
		tf.y =  Lib.current.stage.stageHeight - 100;
		tf.height = 30;
		tf.width = Lib.current.stage.stageWidth - 120;
		tf.border = true;
		tf.background = true;
		tf.backgroundColor = 0xEEEEEE;
		Lib.current.stage.addChild(tf);
	}
	
	function new() 
	{
		var s = new XMLSocket();
		s.addEventListener(Event.CONNECT, onConnect);
		s.connect("localhost",1024);
		var context = new haxe.remoting.Context();
		context.addObject("client",this);
		var scnx = haxe.remoting.SocketConnection.create(s,context);
		api = new ServerApiImpl(scnx.api);
	}

	function onConnect( success : Bool ) 
	{
		if( !success ) {
			trace("Failed to connect on server !");
			return;
		}
		initUI();
		display("Please enter your name in the bottom textfield to login and press ENTER");
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	function onKeyDown(e:KeyboardEvent) 
	{
		if ( e.keyCode == 13 ) {
			var text = tf.text;
//			tf.text = "";  // Erase old message
			send(text);
		}
	}

	function send( text : String ) 
	{
		if ( name == null ) 
		{
			msgText.text = 'Message:';
			name = text;
			api.identify(name);
		}
		else
		{
			api.say(text);
		}
	}

	public function userJoin( name ) {
		display("User join <b>"+name+"</b>");
	}

	public function userLeave( name ) {
		display("User leave <b>"+name+"</b>");
	}

	public function userSay( name : String, text : String ) {
		display("<b>"+name+ " :</b> "+text.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;"));
	}

	function display( line : String ) {
		log.htmlText += line + "<br>";
		if( log.scrollV < log.maxScrollV)
			log.scrollV = log.maxScrollV;
	}

	static var c : Client;

	static function main() {
		c = new Client();
	}

}
