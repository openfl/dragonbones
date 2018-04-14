package dragonBones.flixel;

import haxe.Constraints;

import flixel.FlxStrip;
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

using Lambda;

@:allow(dragonBones) @:final class FlixelMeshDisplay extends FlxStrip implements IArmatureDisplay {
	/**
	 * @private
	 */

	private var _armature:Armature;

	/**
	 * @private
	 */
	@:keep private function new()
	{
		super();
		this.solid = false;
	}
	/**
	 * @private
	 */
	private function _onClear():Void
	{
		_armature = null;
	}
	/**
	 * @private
	 */
	private function _debugDraw(isEnabled:Bool):Void
	{

	}
	/**
	 * @public
	 */
	public function updatePosition():Void 
	{
		for (i in 0...this._armature._slots.length) {
			(cast this._armature._slots[i]:FlixelSlot).updatePosition();
		}
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
	 * @private
	 */
	private function _dispatchEvent(type:String, eventObject:EventObject):Void
	{
		var event:FlixelEvent = new FlixelEvent(type, eventObject);
		FlxG.stage.dispatchEvent(event);
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

	public var scaleX(default, set):Float = 1;
	private function set_scaleX(x:Float):Float
	{
		return scaleX = x;
	}

	public var scaleY(default, set):Float = 1;
	private function set_scaleY(y:Float):Float
	{
		return scaleY = y;
	}

	public var zOrder(default, set):Int = 0;
	private function set_zOrder(pos:Int):Int
	{
		return zOrder = pos;
	}
}