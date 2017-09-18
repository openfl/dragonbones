package;

import haxe.Json;

import openfl.Assets;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;

import dragonBones.objects.DragonBonesData;
import dragonBones.flixel.FlixelTextureAtlasData;
import dragonBones.flixel.FlixelArmatureDisplay;
import dragonBones.flixel.FlixelFactory;
import dragonBones.flixel.FlixelEvent;
import dragonBones.events.EventObject;
import dragonBones.animations.WorldClock;

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

		armatureGroup = _factory.buildArmatureDisplay(dragonBonesData.armatureNames[0]);
		
		// Add animation listener.
		armatureGroup.members[0].addEvent(EventObject.START, _animationHandler);

		armatureGroup.forEach(_setAnimationProps);
		armatureGroup.forEach(_playAnimation);
        
		add(armatureGroup);
	}
	
	private function _setAnimationProps(display:FlixelArmatureDisplay):Void
	{
		display.antialiasing = true;
		display.gScaleX = 0.50;
		display.gScaleX = 0.50;
		display.gScaleY = 0.50;
		display.globalX = 300;
		display.globalY = 300;
	}

	private function _playAnimation(display:FlixelArmatureDisplay):Void
	{
		display.animations.play(display.animations.animationNames[0]);
        
	}

    private function _animationHandler(event:FlixelEvent): Void 
	{
        trace(event);
		var eventObject:EventObject = event.eventObject;
	}

	override public function update(elapsed:Float):Void
	{
		WorldClock.clock.advanceTime(-1);
		super.update(elapsed);
	}
}
