package;

import haxe.Json;

import openfl.errors.Error;
import openfl.Assets;
import openfl.Vector;

// Starling render
import starling.display.Sprite;
import starling.events.Event;

import dragonBones.events.EventObject;
import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingFactory;
import dragonBones.starling.StarlingArmatureDisplay;

class StarlingRender extends starling.display.Sprite
{
	public static var instance: StarlingRender = null;

	public var dragonBonesData: DragonBonesData = null;

	private var _armatureIndex: Int = 0;
	private var _animationIndex: Int = 0;
	private var _armatureDisplay: StarlingArmatureDisplay = null;

	public function new()
	{
		super();
		
		instance = this;
		
		this.addEventListener(starling.events.Event.ADDED_TO_STAGE, _addToStageHandler);
	}

	public var armatureDisplay(get, never):StarlingArmatureDisplay;
	private function get_armatureDisplay(): StarlingArmatureDisplay
	{
		return _armatureDisplay;
	}

	private function _addToStageHandler(event: starling.events.Event): Void
	{
		// Parse data.
		dragonBonesData = StarlingFactory.factory.parseDragonBonesData(
			Json.parse(Assets.getText("assets/DragonBoy.json"))
		);
		StarlingFactory.factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/DragonBoy_texture_1.json")),
			Assets.getBitmapData("assets/DragonBoy_texture_1.png")
		);
		
		if (dragonBonesData != null)
		{
			// Add armature.
			changeArmature();
		}
		else
		{
			throw new Error();
		}
	}

	/** 
	 * Change armature.
	 */
	public function changeArmature(): Void
	{
		var armatureNames: Vector<String> = dragonBonesData.armatureNames;
		if (armatureNames.length == 0)
		{
			return;
		}
		
		// Remove prev armature.
		if (_armatureDisplay != null)
		{
			// Remove listeners.
			_armatureDisplay.removeEventListener(EventObject.START, _animationHandler);
			_armatureDisplay.removeEventListener(EventObject.LOOP_COMPLETE, _animationHandler);
			_armatureDisplay.removeEventListener(EventObject.COMPLETE, _animationHandler);
			_armatureDisplay.removeEventListener(EventObject.FRAME_EVENT, _frameEventHandler);
			
			_armatureDisplay.dispose();
			this.removeChild(_armatureDisplay);
		}
		
		// Get next armature name.
		_animationIndex = 0;
		_armatureIndex++;
		if (_armatureIndex >= armatureNames.length)
		{
			_armatureIndex = 0;
		}
		
		var armatureName: String = armatureNames[_armatureIndex];
		
		// Build armature display. (buildArmatureDisplay will advanceTime animation by Armature Display)
		_armatureDisplay = StarlingFactory.factory.buildArmatureDisplay(armatureName);
		// _armatureDisplay.armature.cacheFrameRate = 24; // Cache animation.
		
		// Add animation listener.
		_armatureDisplay.addEventListener(EventObject.START, _animationHandler);
		_armatureDisplay.addEventListener(EventObject.LOOP_COMPLETE, _animationHandler);
		_armatureDisplay.addEventListener(EventObject.COMPLETE, _animationHandler);
		// Add frame event listener.
		_armatureDisplay.addEventListener(EventObject.FRAME_EVENT, _frameEventHandler);
		
		// Add armature display.
		_armatureDisplay.x = this.stage.stageWidth * 0.5 + 200;
		_armatureDisplay.y = this.stage.stageHeight * 0.5 + 100;
		this.addChild(_armatureDisplay);
	}

	/** 
	 * Change armature animation.
	 */
	public function changeAnimation(): Void
	{
		if (_armatureDisplay == null) 
		{
			return;
		}
		
		var animationNames: Vector<String> = _armatureDisplay.animation.animationNames;
		if (animationNames.length == 0)
		{
			return;
		}
		
		// Get next animation name.
		_animationIndex++;
		if (_animationIndex >= animationNames.length)
		{
			_animationIndex = 0;
		}
		
		var animationName: String = animationNames[_animationIndex];
		
		// Play animation.
		_armatureDisplay.animation.play(animationName);
	}

	/** 
	 * Animation listener.
	 */
	private function _animationHandler(event:starling.events.Event): Void 
	{
		var eventObject:EventObject = cast(event.data, EventObject);
		trace(event.type, eventObject.animationState.name);
	}

	/** 
	 * Frame event listener. (If animation has frame event)
	 */
	private function _frameEventHandler(event: starling.events.Event): Void 
	{
		var eventObject:EventObject = cast(event.data, EventObject);
		trace(event.type, eventObject.animationState.name, eventObject.name);
	}
}