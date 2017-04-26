package;

import haxe.Json;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Assets;

import dragonBones.openfl.OpenFLArmatureDisplay;
import dragonBones.openfl.OpenFLFactory;

class OpenFLRender extends openfl.display.Sprite
{
	public function new()
	{
		super();
		
		this.addEventListener(openfl.events.Event.ADDED_TO_STAGE, _addToStageHandler);
	}

	private function _addToStageHandler(event: openfl.events.Event): Void
	{
		OpenFLFactory.factory.parseDragonBonesData(
			Json.parse(Assets.getText("assets/DragonBoy.json")), "DBData"
		);
		
		// HD
		OpenFLFactory.factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/DragonBoy_texture_1_HD.json")),
			Assets.getBitmapData("assets/DragonBoy_texture_1_HD.png"), "HD", 2
		);
		
		// NORM
		OpenFLFactory.factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/DragonBoy_texture_1.json")),
			Assets.getBitmapData("assets/DragonBoy_texture_1.png"), "NORM"
		);
		
		// SD
		OpenFLFactory.factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/DragonBoy_texture_1_SD.json")),
			Assets.getBitmapData("assets/DragonBoy_texture_1_SD.png"), "SD", 0.5
		);
		
		var armatureDisplay:OpenFLArmatureDisplay = null;
		
		// HD
		armatureDisplay = OpenFLFactory.factory.buildArmatureDisplay("DragonBoy", "DBData", null, "HD");
		armatureDisplay.x = this.stage.stageWidth * 0.5 - 200;
		armatureDisplay.y = this.stage.stageHeight * 0.5;
		armatureDisplay.animation.play();
		this.addChild(armatureDisplay);
		
		// NORM
		armatureDisplay = OpenFLFactory.factory.buildArmatureDisplay("DragonBoy", "DBData", null, "NORM");
		armatureDisplay.x = this.stage.stageWidth * 0.5;
		armatureDisplay.y = this.stage.stageHeight * 0.5;
		armatureDisplay.animation.play();
		this.addChild(armatureDisplay);
		
		// SD
		armatureDisplay = OpenFLFactory.factory.buildArmatureDisplay("DragonBoy", "DBData", null, "SD");
		armatureDisplay.x = this.stage.stageWidth * 0.5 + 200;
		armatureDisplay.y = this.stage.stageHeight * 0.5;
		armatureDisplay.animation.play();
		this.addChild(armatureDisplay);
	}
}