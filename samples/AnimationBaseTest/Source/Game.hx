package;

import haxe.Json;

import openfl.errors.Error;
import openfl.Assets;

// Starling render
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.events.Event;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingFactory;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.events.EventObject;

class Game extends Sprite
{
	private var _isTouched:Bool = false;
	private var _armatureDisplay: StarlingArmatureDisplay = null;
	private var _factory: StarlingFactory = new StarlingFactory();

	public function new()
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, _addToStageHandler);
	}

	private function _addToStageHandler(event: Event): Void
	{
		// Load DragonBones Data
		var dragonBonesData: DragonBonesData = _factory.parseDragonBonesData(
			Json.parse(Assets.getText("assets/AnimationBaseTest.json"))
		);
		_factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/texture.json")),
			Assets.getBitmapData("assets/texture.png")
		);
		
		if (dragonBonesData != null)
		{
			_armatureDisplay = _factory.buildArmatureDisplay(dragonBonesData.armatureNames[0]);

			_armatureDisplay.x = 400;
			_armatureDisplay.y = 300;
			_armatureDisplay.scaleX = _armatureDisplay.scaleY = 1;
			this.addChild(_armatureDisplay);

			// Test animation event
			_armatureDisplay.addEventListener(EventObject.START, _animationEventHandler);
			_armatureDisplay.addEventListener(EventObject.LOOP_COMPLETE, _animationEventHandler);
			_armatureDisplay.addEventListener(EventObject.COMPLETE, _animationEventHandler);
			_armatureDisplay.addEventListener(EventObject.FADE_IN, _animationEventHandler);
			_armatureDisplay.addEventListener(EventObject.FADE_IN_COMPLETE, _animationEventHandler);
			_armatureDisplay.addEventListener(EventObject.FADE_OUT, _animationEventHandler);
			_armatureDisplay.addEventListener(EventObject.FADE_OUT_COMPLETE, _animationEventHandler);

			// Test frame event
			_armatureDisplay.addEventListener(EventObject.FRAME_EVENT, _animationEventHandler);

			// Test animation API
			this.stage.addEventListener(
				TouchEvent.TOUCH,
				function (event: TouchEvent): Void
				{
					var touch: Touch = event.getTouch(stage);
					if (touch != null)
					{
						var progress: Float = Math.min(Math.max((touch.globalX - _armatureDisplay.x + 300) / 600, 0), 1);
						
						switch (touch.phase)
						{
							case TouchPhase.BEGAN:
								_isTouched = true;
							
								//_armatureDisplay.animation.gotoAndPlayByTime("idle", 0.5, 1);
								//_armatureDisplay.animation.gotoAndStopByTime("idle", 1);
							
								//_armatureDisplay.animation.gotoAndPlayByFrame("idle", 25, 2);
								//_armatureDisplay.animation.gotoAndStopByFrame("idle", 50);
							
								_armatureDisplay.animation.gotoAndPlayByProgress("idle", progress, 3);
								//_armatureDisplay.animation.gotoAndStopByProgress("idle", progress);
							
							case TouchPhase.ENDED:
								_isTouched = false;
							
							case TouchPhase.MOVED:
								if (_isTouched && _armatureDisplay.animation.getState("idle") != null && !_armatureDisplay.animation.getState("idle").isPlaying)
								{
									_armatureDisplay.animation.gotoAndStopByProgress("idle", progress);
								}
						}
					}
				}
			);
		}
		else
		{
			throw new Error();
		}
	}

	private function _animationEventHandler(event: Event): Void
	{
		var eventObject: EventObject = cast(event.data, EventObject);

		trace(eventObject.animationState.name, event.type, eventObject.name != null ? eventObject.name : "");
	}
}