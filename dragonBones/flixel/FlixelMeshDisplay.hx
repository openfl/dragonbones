package dragonBones.flixel;

import haxe.Constraints;

import openfl.display.BlendMode;

import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.FlxBasic;
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

@:allow(dragonBones) @:final class FlixelMeshDisplay extends FlxBasic implements IArmatureDisplay {
	/**
	 * @private
	 */
	private var _armature:Armature;
	/**
	 * @private
	 */
	public var flxProxy:FlxStrip;
	/**
	 * @private
	 */
	public var offset:FlxPoint;
	/**
	 * @private
	 */
	public var scale:FlxPoint;

	@:keep private function new()
	{
		super();
		flxProxy = new FlxStrip();
		flxProxy.solid = false;
		offset = flxProxy.offset;
		scale = flxProxy.scale;
	}
	/**
	 * @private
	 */
	override public function draw() {
		flxProxy.draw();
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
	
	public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite {
		return flxProxy.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
	}

	public function setColorTransform(redMultiplier:Float = 1.0, greenMultiplier:Float = 1.0, blueMultiplier:Float = 1.0, alphaMultiplier:Float = 1.0, redOffset:Int = 0, greenOffset:Int = 0, blueOffset:Int = 0, alphaOffset:Int = 0):Void {
		flxProxy.setColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
	}

	public var x(get, set):Float;
	private function get_x():Float
	{
		return flxProxy.x;
	}
	private function set_x(x:Float):Float
	{
		return flxProxy.x = x;
	}

	public var y(get, set):Float;
	private function get_y():Float
	{
		return flxProxy.y;
	}
	private function set_y(y:Float):Float
	{
		return flxProxy.y = y;
	}

	public var angle(get, set):Float;
	private function get_angle():Float
	{
		return flxProxy.angle;
	}
	private function set_angle(angle:Float):Float
	{
		return flxProxy.angle = angle;
	}

	public var antialiasing(get, set):Bool;
	private function get_antialiasing():Bool
	{
		return flxProxy.antialiasing;
	}
	private function set_antialiasing(isTrue:Bool):Bool
	{
		return flxProxy.antialiasing = isTrue;
	}

	public var blend(get, set):BlendMode;
	private function get_blend():BlendMode
	{
		return flxProxy.blend;
	}
	private function set_blend(blendMode:BlendMode):BlendMode
	{
		return flxProxy.blend = blendMode;
	}

	public var armature(get, never):Armature;
	private function get_armature():Armature
	{
		return _armature;
	}

	public var animation(get, never):Animation;
	private function get_animation():Animation
	{
		return _armature.animation;
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