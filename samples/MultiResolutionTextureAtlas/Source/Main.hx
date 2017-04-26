package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;

import starling.core.Starling;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		// Render init.
		_openFLInit();
		_starlingInit();
		
		// Add infomation.
		var text:TextField = new TextField();
		text.width = this.stage.stageWidth;
		text.height = 60;
		text.x = 0;
		text.y = this.stage.stageHeight - 60;
		text.autoSize = "center";
		text.text = "Multi Resolution TextureAtlas.\nHD (2X) / NORM (1X) / SD (0.5X)";
		this.addChild(text);
	}
	
	private function _openFLInit(): Void
	{
		var openFLRender: OpenFLRender = new OpenFLRender();
		this.addChild(openFLRender);
	}
	
	private function _starlingInit(): Void
	{
		var starling: Starling = new Starling(StarlingRender, this.stage);
		starling.start();
	}
}