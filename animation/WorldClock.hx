package dragonBones.animation;

import openfl.Lib;

/**
 * A WorldClock instance lets you conveniently update many number of Armature instances at once. You can add/remove Armature instance and set a global timescale that will apply to all registered Armature instance animations.
 * @see dragonBones.Armature
 * @see dragonBones.animation.Animation
 */
class WorldClock implements IAnimatable
{
	/**
	 * A global static WorldClock instance ready to use.
	 */
	public static var clock:WorldClock = new WorldClock();

	private var _animatableList:Array<IAnimatable>;

	private var _time:Float;
	public var time(get, null):Float;
	public function get_time():Float
	{
		return _time;
	}

	private var _timeScale:Float;
	/**
	 * The time scale to apply to the number of second passed to the advanceTime() method.
	 * @param A Number to use as a time scale.
	 */
    public var timeScale(get, set):Float;
	public function get_timeScale():Float
	{
		return _timeScale;
	}
	public function set_timeScale(value:Float):Float
	{
		if(Math.isNaN(value) || value < 0)
		{
			value = 1;
		}
		_timeScale = value;
		return value;
	}

	/**
	 * Creates a new WorldClock instance. (use the static var WorldClock.clock instead).
	 */
	public function new(time:Float = -1, timeScale:Float = 1)
	{
		_time = time >= 0?time:Lib.getTimer() * 0.001;
		_timeScale = Math.isNaN(timeScale)?1:timeScale;
		_animatableList = new Array<IAnimatable>();
	}

	/**
	 * Returns true if the IAnimatable instance is contained by WorldClock instance.
	 * @param An IAnimatable instance (Armature or custom)
	 * @return true if the IAnimatable instance is contained by WorldClock instance.
	 */
	public function contains(animatable:IAnimatable):Bool
	{
		return _animatableList.indexOf(animatable) >= 0;
	}

	/**
	 * Add a IAnimatable instance (Armature or custom) to this WorldClock instance.
	 * @param An IAnimatable instance (Armature, WorldClock or custom)
	 */
	public function add(animatable:IAnimatable):Void
	{
		if (animatable != null && _animatableList.indexOf(animatable) == -1)
		{
			_animatableList.push(animatable);
		}
	}

	/**
	 * Remove a IAnimatable instance (Armature or custom) from this WorldClock instance.
	 * @param An IAnimatable instance (Armature or custom)
	 */
	public function remove(animatable:IAnimatable):Void
	{
		var index:Int = _animatableList.indexOf(animatable);
		if (index >= 0)
		{
			_animatableList[index] = null;
		}
	}

	/**
	 * Remove all IAnimatable instance (Armature or custom) from this WorldClock instance.
	 */
	public function clear():Void
	{
		_animatableList = new Array<IAnimatable>();
	}

	/**
	 * Update all registered IAnimatable instance animations using this method typically in an ENTERFRAME Event or with a Timer.
	 * @param The amount of second to move the playhead ahead.
	 */
	public function advanceTime(passedTime:Float):Void
	{
		if(passedTime < 0)
		{
			passedTime = Lib.getTimer() * 0.001 - _time;
		}
		passedTime *= _timeScale;

		_time += passedTime;

		var length:Int = _animatableList.length;
		if(length == 0)
		{
			return;
		}
		var currentIndex:Int = 0;
        var lastI = 0;
		for(i in 0...length)
		{
			var animatable:IAnimatable = _animatableList[i];
			if(animatable != null)
			{
				if(currentIndex != i)
				{
					_animatableList[currentIndex] = animatable;
					_animatableList[i] = null;
				}
				animatable.advanceTime(passedTime);
				currentIndex ++;
			}
			lastI = i;
		}
		lastI++;

 		if (currentIndex != lastI)
		{
			length = _animatableList.length;
			while(lastI < length)
			{
				_animatableList[currentIndex ++] = _animatableList[lastI ++];
			}
			_animatableList.splice(currentIndex, _animatableList.length);
		}
	}
}
