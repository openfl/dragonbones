package dragonBones.starling
{
import dragonBones.Armature;
import dragonBones.animation.Animation;
import dragonBones.core.IArmatureDisplay;
import dragonBones.core.dragonBones_internal;
import dragonBones.events.EventObject;

import starling.display.Sprite;


/**
 * @inheritDoc
 */
public final class StarlingArmatureDisplay extends Sprite implements IArmatureDisplay
{
	public static var useDefaultStarlingEvent:Bool = false;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var _armature:Armature;
	/**
	 * @private
	 */
	public function StarlingArmatureDisplay()
	{
		super();
	}
	/**
	 * @private
	 */
	public function _onClear():Void
	{
		_armature = null;
	}
	/**
	 * @private
	 */
	public function _dispatchEvent(type:String, eventObject:EventObject):Void
	{
		if (useDefaultStarlingEvent)
		{
			dispatchEventWith(type, false, eventObject);
		}
		else
		{
			inline var event:StarlingEvent = new StarlingEvent(type, eventObject);
			dispatchEvent(event);
		}
	}
	/**
	 * @private
	 */
	public function _debugDraw(isEnabled:Bool):Void
	{
	}
	/**
	 * @inheritDoc
	 */
	override public function dispose():Void
	{
		if (_armature)
		{
			_armature.dispose();
			_armature = null;
		}
		
		super.dispose();
	}
	/**
	 * @inheritDoc
	 */
	public function hasEvent(type:String):Bool
	{
		return hasEventListener(type);
	}
	/**
	 * @inheritDoc
	 */
	public function addEvent(type:String, listener:Function):Void
	{
		addEventListener(type, listener);
	}
	/**
	 * @inheritDoc
	 */
	public function removeEvent(type:String, listener:Function):Void
	{
		removeEventListener(type, listener);
	}
	/**
	 * @inheritDoc
	 */
	public function get armature():Armature
	{
		return _armature;
	}
	/**
	 * @inheritDoc
	 */
	public function get animation():Animation
	{
		return _armature.animation;
	}
	
	/**
	 * @deprecated
	 */
	public function advanceTimeBySelf(on:Bool):Void
	{
		if (on)
		{
			StarlingFactory._clock.add(_armature);
		} 
		else 
		{
			StarlingFactory._clock.remove(_armature);
		}
	}
}
}