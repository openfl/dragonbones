package;

import haxe.Json;

import openfl.errors.Error;
import openfl.Assets;
import openfl.Vector;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingFactory;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;

class StarlingRender extends Sprite
{
	private var _addingArmature: Bool = false;
	private var _removingArmature: Bool = false;
	private var _text:TextField = null;
	private var _armatures: Vector<Armature> = new Vector<Armature>();

	public function new()
	{
		super();
		
		this.addEventListener(Event.ADDED_TO_STAGE, _addToStageHandler);
	}

	private function _addToStageHandler(event: Event): Void
	{
		_text = new TextField(800, 60, "");
		_text.x = 0;
		_text.y = this.stage.stageHeight - 60;
		_text.autoSize = "center";
		this.addChild(_text);
		
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, _enterFrameHandler);
		this.stage.addEventListener(TouchEvent.TOUCH, _touchHandler);
		
		//
		for (i in 0...100) {
			_addArmature();
		}
		
		_resetPosition();
	}

	private function _enterFrameHandler(event: EnterFrameEvent): Void
	{
		if (_addingArmature)
		{
			_addArmature();
			_addArmature();
			_addArmature();
			_addArmature();
			_addArmature();
			_addArmature();
			_addArmature();
			_addArmature();
			_addArmature();
			_addArmature();
			_resetPosition();
			_updateText();
		}

		if (_removingArmature)
		{
			_removeArmature();
			_removeArmature();
			_removeArmature();
			_removeArmature();
			_removeArmature();
			_removeArmature();
			_removeArmature();
			_removeArmature();
			_removeArmature();
			_removeArmature();
			_resetPosition();
			_updateText();
		}
		
		WorldClock.clock.advanceTime(-1);
	}

	private function _touchHandler(event: TouchEvent): Void
	{
		var touch: Touch = event.getTouch(this.stage);
		if (touch != null)
		{
			if (touch.phase == TouchPhase.BEGAN)
			{
				var touchRight:Bool = touch.globalX > this.stage.stageWidth * 0.5;
				_addingArmature = touchRight;
				_removingArmature = !touchRight;
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				_addingArmature = false;
				_removingArmature = false;
			}
		}
	}

	private function _addArmature(): Void
	{
		if (_armatures.length == 0)
		{
			StarlingFactory.factory.parseDragonBonesData(
				Json.parse(Assets.getText("assets/DragonBoy.json"))
			);
			StarlingFactory.factory.parseTextureAtlasData(
				Json.parse(Assets.getText("assets/DragonBoy_texture_1.json")),
				Assets.getBitmapData("assets/DragonBoy_texture_1.png")
			);
		}
		
		var armature: Armature = StarlingFactory.factory.buildArmature("DragonBoy");
		var armatureDisplay: StarlingArmatureDisplay = cast armature.display;

		armatureDisplay.scaleX = armatureDisplay.scaleY = 0.7;
		this.addChild(armatureDisplay);

		armature.cacheFrameRate = 24;
		var animationName:String = armature.animation.animationNames[0];
		//const animationName:String = armature.animation.animationNames[Math.floor(Math.random() * armature.animation.animationNames.length)];
		armature.animation.play(animationName, 0);
		WorldClock.clock.add(armature);

		_armatures.push(armature);
	}

	private function _removeArmature(): Void
	{
		if (this._armatures.length == 0) 
		{
			return;
		}
			
		var armature: Armature = _armatures.pop();
		var armatureDisplay: StarlingArmatureDisplay = cast armature.display;
		this.removeChild(armatureDisplay);
		WorldClock.clock.remove(armature);
		armature.dispose();
		armature.dispose();
		armature.dispose();
		armature.dispose();
		armature.dispose();
		armature.dispose();
		armature.dispose();

		if (this._armatures.length == 0) 
		{
			StarlingFactory.factory.clear();
		}
	}

	private function _resetPosition(): Void
	{
		var count: UInt = _armatures.length;
		if (count == 0)
		{
			return;
		}
		
		var paddingH: UInt = 50;
		var paddingV: UInt = 150;
		var columnNum: UInt = 10;
		var dX: Float = (this.stage.stageWidth - paddingH * 2) / columnNum;
		var dY: Float = (this.stage.stageHeight - paddingV * 2) / Math.ceil(count / columnNum);

		var armature:Armature, armatureDisplay:StarlingArmatureDisplay, lineY:UInt;
		var l:UInt = _armatures.length;
		for (i in 0...l)
		{
			armature = _armatures[i];
			armatureDisplay = cast armature.display;
			lineY = Math.floor(i / columnNum);

			armatureDisplay.x = (i % columnNum) * dX + paddingH;
			armatureDisplay.y = lineY * dY + paddingV;
		}
	}

	private function _updateText(): Void
	{
		_text.text = "Count: " + _armatures.length + " \nTouch screen left to decrease count / right to increase count.";
	}
}