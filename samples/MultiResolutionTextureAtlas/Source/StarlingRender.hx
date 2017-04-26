package;

import haxe.Json;

import openfl.Assets;

import starling.display.Sprite;
import starling.events.Event;

import dragonBones.starling.StarlingFactory;
import dragonBones.starling.StarlingArmatureDisplay;

class StarlingRender extends starling.display.Sprite
{
	public function new()
	{
		super();
		
		this.addEventListener(starling.events.Event.ADDED_TO_STAGE, _addToStageHandler);
	}

	private function _addToStageHandler(event: starling.events.Event): Void
	{
		StarlingFactory.factory.parseDragonBonesData(
			Json.parse(Assets.getText("assets/DragonBoy.json")), "DBData"
		);
		
		// HD
		StarlingFactory.factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/DragonBoy_texture_1_HD.json")),
			Assets.getBitmapData("assets/DragonBoy_texture_1_HD.png"), "HD", 2
		);
		
		// NORM
		StarlingFactory.factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/DragonBoy_texture_1.json")),
			Assets.getBitmapData("assets/DragonBoy_texture_1.png"), "NORM"
		);
		
		// SD
		StarlingFactory.factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/DragonBoy_texture_1_SD.json")),
			Assets.getBitmapData("assets/DragonBoy_texture_1_SD.png"), "SD", 0.5
		);
		
		var armatureDisplay:StarlingArmatureDisplay = null;
		
		// HD
		armatureDisplay = StarlingFactory.factory.buildArmatureDisplay("DragonBoy", "DBData", null, "HD");
		armatureDisplay.x = this.stage.stageWidth * 0.5 - 200;
		armatureDisplay.y = this.stage.stageHeight * 0.5 + 200;
		armatureDisplay.animation.play();
		this.addChild(armatureDisplay);
		
		// NORM
		armatureDisplay = StarlingFactory.factory.buildArmatureDisplay("DragonBoy", "DBData", null, "NORM");
		armatureDisplay.x = this.stage.stageWidth * 0.5;
		armatureDisplay.y = this.stage.stageHeight * 0.5 + 200;
		armatureDisplay.animation.play();
		this.addChild(armatureDisplay);
		
		// SD
		armatureDisplay = StarlingFactory.factory.buildArmatureDisplay("DragonBoy", "DBData", null, "SD");
		armatureDisplay.x = this.stage.stageWidth * 0.5 + 200;
		armatureDisplay.y = this.stage.stageHeight * 0.5 + 200;
		armatureDisplay.animation.play();
		this.addChild(armatureDisplay);
	}
}