package dragonBones.animation;

import dragonBones.Armature;
import dragonBones.Slot;
import dragonBones.objects.AnimationData;

/**
 * An Animation instance is used to control the animation state of an Armature.
 * @see dragonBones.Armature
 * @see dragonBones.animation.Animation
 * @see dragonBones.animation.AnimationState
 */
class Animation
{
	public static var NONE:String = "none";
	public static var SAME_LAYER:String = "sameLayer";
	public static var SAME_GROUP:String = "sameGroup";
	public static var SAME_LAYER_AND_GROUP:String = "sameLayerAndGroup";
	public static var ALL:String = "all";

	/**
	* Unrecommended API. Recommend use animationList.
	*/
    public var movementList(get, null):Array<String>;
	public function get_movementList():Array<String>
	{
		return _animationList;
	}

	/**
	* Unrecommended API. Recommend use lastAnimationName.
	*/
    public var movementID(get, null):String;
	public function get_movementID():String
	{
		return lastAnimationName;
	}


	/**
	 * Whether animation tweening is enabled or not.
	 */
	public var tweenEnabled:Bool;

	private var _armature:Armature;

	private var _animationStateList:Array<AnimationState>;

	/** @private */
	public var _lastAnimationState:AnimationState;

	/** @private */
	public var _isFading:Bool;

	/** @private */
	public var _animationStateCount:Int;

	/**
	 * The last AnimationState this Animation played.
	 * @see dragonBones.objects.AnimationData.
	 */
    public var lastAnimationState(get, null):AnimationState;
	public function get_lastAnimationState():AnimationState
	{
		return _lastAnimationState;
	}
	/**
	 * The name of the last AnimationData played.
	 * @see dragonBones.objects.AnimationData.
	 */
    public var lastAnimationName(get, null):String;
	public function get_lastAnimationName():String
	{
		return _lastAnimationState != null ?_lastAnimationState.name:null;
	}

	private var _animationList:Array<String>;
	/**
	 * An vector containing all AnimationData names the Animation can play.
	 * @see dragonBones.objects.AnimationData.
	 */
    public var animationList(get, null):Array<String>;
	public function get_animationList():Array<String>
	{
		return _animationList;
	}

	private var _isPlaying:Bool;
	/**
	 * Is the animation playing.
	 * @see dragonBones.animation.AnimationState.
	 */
    public var isPlaying(get, null):Bool;
	public function get_isPlaying():Bool
	{
		return _isPlaying && !isComplete;
	}

	/**
	 * Is animation complete.
	 * @see dragonBones.animation.AnimationState.
	 */
    public var isComplete(get, null):Bool;
	public function get_isComplete():Bool
	{
		if(_lastAnimationState != null)
		{
			if(!_lastAnimationState.isComplete)
			{
				return false;
			}
			var i:Int = _animationStateList.length;
			while(i -- > 0)
			{
				if(!_animationStateList[i].isComplete)
				{
					return false;
				}
			}
			return true;
		}
		return true;
	}

	private var _timeScale:Float;
	/**
	 * The amount by which passed time should be scaled. Used to slow down or speed up animations. Defaults to 1.
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

	private var _animationDataList:Array<AnimationData>;
	/**
	 * The AnimationData list associated with this Animation instance.
	 * @see dragonBones.objects.AnimationData.
	 */
    public var animationDataList(get, set):Array<AnimationData>;
	public function get_animationDataList():Array<AnimationData>
	{
		return _animationDataList;
	}
	public function set_animationDataList(value:Array<AnimationData>):Array<AnimationData>
	{
		_animationDataList = value;
		_animationList = new Array<String>();
		for (animationData in _animationDataList)
		{
			_animationList.push(animationData.name);
		}
		return _animationDataList;
	}

	/**
	 * Creates a new Animation instance and attaches it to the passed Armature.
	 * @param An Armature to attach this Animation instance to.
	 */
	public function new(armature:Armature)
	{
		_armature = armature;
		_animationList = new Array<String>();
		_animationStateList = new Array<AnimationState>();

		_timeScale = 1;
		_isPlaying = false;

		tweenEnabled = true;
	}

	/**
	 * Qualifies all resources used by this Animation instance for garbage collection.
	 */
	public function dispose():Void
	{
		if(_armature == null)
		{
			return;
		}
		var i:Int = _animationStateList.length;
		while(i -- > 0)
		{
			AnimationState.returnObject(_animationStateList[i]);
		}

		_armature = null;
		_animationDataList = null;
		_animationList = null;
		_animationStateList = null;
	}

	/**
	 * Fades the animation with name animation in over a period of time seconds and fades other animations out.
	 * @param animationName The name of the AnimationData to play.
	 * @param fadeInTime A fade time to apply (>= 0), -1 means use xml data's fadeInTime.
	 * @param duration The duration of that Animation. -1 means use xml data's duration.
	 * @param playTimes Play times(0:loop forever, >=1:play times, -1~-∞:will fade animation after play complete), 默认使用AnimationData.loop.
	 * @param layer The layer of the animation.
	 * @param group The group of the animation.
	 * @param fadeOutMode Fade out mode (none, sameLayer, sameGroup, sameLayerAndGroup, all).
	 * @param pauseFadeOut Pause other animation playing.
	 * @param pauseFadeIn Pause this animation playing before fade in complete.
	 * @return AnimationState.
	 * @see dragonBones.objects.AnimationData.
	 * @see dragonBones.animation.AnimationState.
	 */
	public function gotoAndPlay(
		animationName:String,
		fadeInTime:Float = -1,
		duration:Float = -1,
		playTimes:Float = 0,
		layer:Int = 0,
		group:String = null,
		fadeOutMode:String = "sameLayerAndGroup",
		pauseFadeOut:Bool = true,
		pauseFadeIn:Bool = true
	):AnimationState
	{
		if (_animationDataList == null)
		{
			return null;
		}
		var i:Int = _animationDataList.length;
		var animationData:AnimationData = null;
		while(i -- > 0)
		{
			if(_animationDataList[i].name == animationName)
			{
				animationData = _animationDataList[i];
				break;
			}
		}
		if (animationData == null)
		{
			return null;
		}
		_isPlaying = true;
		_isFading = true;

		//
		fadeInTime = fadeInTime < 0?(animationData.fadeTime < 0?0.3:animationData.fadeTime):fadeInTime;
		var durationScale:Float;
		if(duration < 0)
		{
			durationScale = animationData.scale < 0?1:animationData.scale;
		}
		else
		{
			durationScale = duration * 1000 / animationData.duration;
		}

		playTimes = (playTimes == 0)?animationData.playTimes:playTimes;

		var animationState:AnimationState;
		if (fadeOutMode == NONE) {
		}
		else if (fadeOutMode == SAME_LAYER) {
			i = _animationStateList.length;
			while (i -- > 0) {
				animationState = _animationStateList[i];
				if (animationState.layer == layer) {
					animationState.fadeOut(fadeInTime, pauseFadeOut);
				}
			}
		}
		else if (fadeOutMode == SAME_GROUP) {
			i = _animationStateList.length;
			while (i -- > 0) {
				animationState = _animationStateList[i];
				if (animationState.group == group) {
					animationState.fadeOut(fadeInTime, pauseFadeOut);
				}
			}
		}
		else if (fadeOutMode == ALL) {
			i = _animationStateList.length;
			while (i -- > 0) {
				animationState = _animationStateList[i];
				animationState.fadeOut(fadeInTime, pauseFadeOut);
			}
		}
		else {
			i = _animationStateList.length;
			while (i -- > 0) {
				animationState = _animationStateList[i];
				if (animationState.layer == layer && animationState.group == group) {
					animationState.fadeOut(fadeInTime, pauseFadeOut);
				}
			}
		}

		_lastAnimationState = AnimationState.borrowObject();
		_lastAnimationState._layer = layer;
		_lastAnimationState._group = group;
		_lastAnimationState.autoTween = tweenEnabled;
		_lastAnimationState.fadeIn(_armature, animationData, fadeInTime, 1 / durationScale, playTimes, pauseFadeIn);

		addState(_lastAnimationState);

		var slotList:Array<Slot> = _armature.getSlots(false);
		i = slotList.length;
		while(i -- > 0)
		{
			var slot:Slot = slotList[i];
			if(slot.childArmature != null)
			{
				slot.childArmature.animation.gotoAndPlay(animationName, fadeInTime);
			}
		}

		return _lastAnimationState;
	}

	/**
	 * Control the animation to stop with a specified time. If related animationState haven't been created, then create a new animationState.
	 * @param animationName The name of the animationState.
	 * @param time
	 * @param normalizedTime
	 * @param fadeInTime A fade time to apply (>= 0), -1 means use xml data's fadeInTime.
	 * @param duration The duration of that Animation. -1 means use xml data's duration.
	 * @param layer The layer of the animation.
	 * @param group The group of the animation.
	 * @param fadeOutMode Fade out mode (none, sameLayer, sameGroup, sameLayerAndGroup, all).
	 * @return AnimationState.
	 * @see dragonBones.objects.AnimationData.
	 * @see dragonBones.animation.AnimationState.
	 */
	public function gotoAndStop(
		animationName:String,
		time:Float,
		normalizedTime:Float = -1,
		fadeInTime:Float = 0,
		duration:Float = -1,
		layer:Int = 0,
		group:String = null,
		fadeOutMode:String = "all"
	):AnimationState
	{
		var animationState:AnimationState = getState(animationName, layer);
		if(animationState == null)
		{
			animationState = gotoAndPlay(animationName, fadeInTime, duration, Math.NaN, layer, group, fadeOutMode);
		}

		if(normalizedTime >= 0)
		{
			animationState.setCurrentTime(animationState.totalTime * normalizedTime);
		}
		else
		{
			animationState.setCurrentTime(time);
		}

		animationState.stop();

		return animationState;
	}

	/**
	 * Play the animation from the current position.
	 */
	public function play():Void
	{
		if (_animationDataList == null || _animationDataList.length == 0)
		{
			return;
		}
		if(_lastAnimationState == null)
		{
			gotoAndPlay(_animationDataList[0].name);
		}
		else if (!_isPlaying)
		{
			_isPlaying = true;
		}
		else
		{
			gotoAndPlay(_lastAnimationState.name);
		}
	}

	public function stop():Void
	{
		_isPlaying = false;
	}

	/**
	 * Returns the AnimationState named name.
	 * @return A AnimationState instance.
	 * @see dragonBones.animation.AnimationState.
	 */
	public function getState(name:String, layer:Int = 0):AnimationState
	{
		var i:Int = _animationStateList.length;
		while(i -- > 0)
		{
			var animationState:AnimationState = _animationStateList[i];
			if(animationState.name == name && animationState.layer == layer)
			{
				return animationState;
			}
		}
		return null;
	}

	/**
	 * check if contains a AnimationData by name.
	 * @return Boolean.
	 * @see dragonBones.animation.AnimationData.
	 */
	public function hasAnimation(animationName:String):Bool
	{
		var i:Int = _animationDataList.length;
		while(i -- > 0)
		{
			if(_animationDataList[i].name == animationName)
			{
				return true;
			}
		}

		return false;
	}

	/** @private */
	public function advanceTime(passedTime:Float):Void
	{
		if(!_isPlaying)
		{
			return;
		}

		var isFading:Bool = false;

		passedTime *= _timeScale;
		var i:Int = _animationStateList.length;
		while(i -- > 0)
		{
			var animationState:AnimationState = _animationStateList[i];
			if(animationState.advanceTime(passedTime))
			{
				removeState(animationState);
			}
			else if(animationState.fadeState != 1)
			{
				isFading = true;
			}
		}

		_isFading = isFading;
	}

	/** @private */
	public function updateAnimationStates():Void
	{
		var i:Int = _animationStateList.length;
		while(i -- > 0)
		{
			_animationStateList[i].updateTimelineStates();
		}
	}

	private function addState(animationState:AnimationState):Void
	{
		if(_animationStateList.indexOf(animationState) < 0)
		{
			_animationStateList.unshift(animationState);

			_animationStateCount = _animationStateList.length;
		}
	}

	private function removeState(animationState:AnimationState):Void
	{
		var index:Int = _animationStateList.indexOf(animationState);
		if(index >= 0)
		{
			_animationStateList.splice(index, 1);
			AnimationState.returnObject(animationState);

			if(_lastAnimationState == animationState)
			{
				if(_animationStateList.length > 0)
				{
					_lastAnimationState = _animationStateList[0];
				}
				else
				{
					_lastAnimationState = null;
				}
			}

			_animationStateCount = _animationStateList.length;
		}
	}
}

