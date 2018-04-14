package;

import haxe.Json;

import openfl.Assets;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;

import dragonBones.objects.DragonBonesData;
import dragonBones.flixel.FlixelTextureAtlasData;
import dragonBones.flixel.FlixelArmatureDisplay;
import dragonBones.flixel.FlixelArmatureCollider;
import dragonBones.flixel.FlixelFactory;
import dragonBones.flixel.FlixelEvent;
import dragonBones.events.EventObject;
import dragonBones.animation.WorldClock;

class FlixelRender extends FlxState
{
  private var _factory:FlixelFactory = new FlixelFactory();
	private var armatureGroup:FlxTypedGroup<FlixelArmatureDisplay>;

	override public function create():Void
	{
    FlxG.cameras.bgColor = 0x666666;

		var dragonBonesData : DragonBonesData = _factory.parseDragonBonesData(
			Json.parse(Assets.getText("assets/dragonboy_flixel_ske.json"))
		);

		_factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/dragonboy_flixel_tex.json")),
			Assets.getBitmapData("assets/dragonboy_flixel_tex.png")
		);

		armatureGroup = _factory.buildArmatureDisplay(new FlixelArmatureCollider(250, 250, 27, 25, 13, 8), dragonBonesData.armatureNames[0]);
		
		// Add animation listener.
		armatureGroup.members[0].addEvent(EventObject.START, _animationHandler);

		armatureGroup.forEach(_setAnimationProps);
		armatureGroup.forEach(_playAnimation);
        
		add(armatureGroup);
	}
	
	private function _setAnimationProps(display:FlixelArmatureDisplay):Void
	{
		display.antialiasing = true;
		display.x = 100;
		display.y = 100;
		display.scaleX = 0.50;
		display.scaleY = 0.50;
	}

	private function _playAnimation(display:FlixelArmatureDisplay):Void
	{
		display.animation.play(display.animation.animationNames[0]);
        
	}

  private function _animationHandler(event:FlixelEvent): Void 
	{
		var eventObject:EventObject = event.eventObject;
	}

	override public function update(elapsed:Float):Void
	{
		FlixelFactory._clock.advanceTime(-1);
		super.update(elapsed);
	}
}
