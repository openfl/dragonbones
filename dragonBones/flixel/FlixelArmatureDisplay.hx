package dragonBones.flixel;

import haxe.Constraints;

import openfl.display.Sprite;
import openfl.events.EventDispatcher;
import openfl.Vector;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxG;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.animations.Animation;
import dragonBones.core.IArmatureDisplay;
import dragonBones.enums.BoundingBoxType;
import dragonBones.events.EventObject;
import dragonBones.objects.BoundingBoxData;

@:allow(dragonBones) @:final class FlixelArmatureDisplay extends FlxSprite implements IArmatureDisplay {
	/**
	 * @private
	 */

	private var _armature:Armature;
	
	private var _debugDrawer:Sprite;

	/**
	 * @private
	 */
	private function new()
	{
		super();
	}
	/**
	 * @private
	 */
	private function _onClear():Void
	{
		_armature = null;
		_debugDrawer = null;
	}
	/**
	 * @private
	 */
	private function _dispatchEvent(type:String, eventObject:EventObject):Void
	{
		var event:FlixelEvent = new FlixelEvent(type, eventObject);
		FlxG.stage.dispatchEvent(event);
	}
	/**
	 * @private
	 */
	private function _debugDraw(isEnabled:Bool):Void
	{

	}
	/**
	 * @inheritDoc
	 */
	public function dispose():Void
	{
		if (_armature != null)
		{
			_armature.dispose();
			_armature = null;
		}
	}
	/**
	 * @inheritDoc
	 */
	public function hasEvent(type:String):Bool
	{
		return FlxG.stage.hasEventListener(type);
	}
	/**
	 * @inheritDoc
	 */
	public function addEvent(type:String, listener:Function):Void
	{
		FlxG.stage.addEventListener(type, cast listener);
	}
	/**
	 * @inheritDoc
	 */
	public function removeEvent(type:String, listener:Function):Void
	{
		FlxG.stage.removeEventListener(type, cast listener);
	}
	
	public var armature(get, never):Armature;
	private function get_armature():Armature
	{
		return _armature;
	}

	public var animations(get, never):Animation;
	private function get_animations():Animation
	{
		return _armature.animations;
	}

	public var globalX(default, set):Float = 0;
	private function set_globalX(x:Float):Float
	{
		return globalX = x;
	}

	public var globalY(default, set):Float = 0;
	private function set_globalY(y:Float):Float
	{
		return globalY = y;
	}

	public var gScaleX(default, set):Float = 1;
	private function set_gScaleX(x:Float):Float
	{
		return gScaleX = x;
	}

	public var gScaleY(default, set):Float = 1;
	private function set_gScaleY(y:Float):Float
	{
		return gScaleY = y;
	}

	public var zOrder(default, set):Int = 0;
	private function set_zOrder(order:Int):Int
	{
		return zOrder = order;
	}
	
	/**
	 * @deprecated
	 */
	@:deprecated public function advanceTimeBySelf(on:Bool):Void
	{
		if (on)
		{
			_armature._clock = FlixelFactory._clock;
		} 
		else 
		{
			_armature._clock = null;
		}
	}
}