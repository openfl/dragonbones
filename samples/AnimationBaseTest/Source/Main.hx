package;


import openfl.display.Sprite;
import starling.core.Starling;


class Main extends Sprite {
	
	
	private var starling:Starling;
	
	
	public function new () {
		
		super ();
		
		starling = new Starling (StarlingRender, stage);
		starling.showStats = true;
		starling.start ();
		
	}
	
	
}