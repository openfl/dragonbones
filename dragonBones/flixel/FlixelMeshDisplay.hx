package dragonBones.flixel;

import haxe.Constraints;

import openfl.display.Sprite;
import openfl.events.EventDispatcher;
import openfl.Vector;

import flixel.FlxStrip;
import flixel.group.FlxGroup;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.animations.Animation;
import dragonBones.core.IArmatureDisplay;
import dragonBones.enums.BoundingBoxType;
import dragonBones.events.EventObject;
import dragonBones.objects.BoundingBoxData;

@:allow(dragonBones) @:final class FlixelMeshDisplay extends FlxStrip implements IArmatureDisplay {
	/**
	 * @private
	 */

	private var _armature:Armature;
	
	private var _debugDrawer:Sprite;

	private var _eventManager:EventDispatcher;

	public var worldX:Float = 0;
	public var worldY:Float = 0;
	public var gScaleX:Float = 1;
	public var gScaleY:Float = 1;

	/**
	 * @private
	 */
	private function new()
	{
		super();
		_eventManager = new EventDispatcher();
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
		_eventManager.dispatchEvent(event);
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
		return _eventManager.hasEventListener(type);
	}
	/**
	 * @inheritDoc
	 */
	public function addEvent(type:String, listener:Function):Void
	{
		_eventManager.addEventListener(type, cast listener);
	}
	/**
	 * @inheritDoc
	 */
	public function removeEvent(type:String, listener:Function):Void
	{
		_eventManager.removeEventListener(type, cast listener);
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