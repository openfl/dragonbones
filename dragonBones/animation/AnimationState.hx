package dragonBones.animation;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.events.AnimationEvent;
import dragonBones.objects.AnimationData;
import dragonBones.objects.Frame;
import dragonBones.objects.TransformTimeline;

/**
 * The AnimationState gives full control over animation blending.
 * In most cases the Animation interface is sufficient and easier to use. Use the AnimationState if you need full control over the animation blending any playback process.
 */
class AnimationState
{
	private static var _pool:Array<AnimationState> = new Array<AnimationState>();

	/** @private */
	public static function borrowObject():AnimationState
	{
		if(_pool.length == 0)
		{
			return new AnimationState();
		}
		return _pool.pop();
	}

	/** @private */
	public static function returnObject(animationState:AnimationState):Void
	{
		if(_pool.indexOf(animationState) < 0)
		{
			_pool.push(animationState);
		}

		animationState.clear();
	}

	/** @private */
	public static function clearPool():Void
	{
		var i:Int = _pool.length;
		while(i -- > 0)
		{
			_pool[i].clear();
		}
		_pool = new Array<AnimationState>();

		TimelineState.clearPool();
	}

	/**
	 * Sometimes, we want slots controlled by a spedific animation state when animation is doing mix or addition.
	 * It determine if animation's color change, displayIndex change, visible change can apply to its display
	 */
	public var displayControl:Bool;

	/**
	 * If animation mixing use additive blending.
	 */
	public var additiveBlending:Bool;
	public function setAdditiveBlending(value:Bool):AnimationState
	{
		additiveBlending = value;
		return this;
	}

	/**
	 * If animation auto fade out after play complete.
	 */
	public var autoFadeOut:Bool;
	/**
	 * Duration of fade out. By default, it equals to fade in time.
	 */
	public var fadeOutTime:Float;
	public function setAutoFadeOut(value:Bool, fadeOutTime:Float = -1):AnimationState
	{
		autoFadeOut = value;
		if(fadeOutTime >= 0)
		{
			this.fadeOutTime = fadeOutTime * _timeScale;
		}
		return this;
	}

	/**
	 * The weight of animation.
	 */
	public var weight:Float;
	public function setWeight(value:Float):AnimationState
	{
		if(Math.isNaN(value) || value < 0)
		{
			value = 1;
		}
		weight = value;
		return this;
	}

	/**
	 * If auto genterate tween between keyframes.
	 */
	public var autoTween:Bool;
	/**
	 * If generate tween between the lastFrame to the first frame for loop animation.
	 */
	public var lastFrameAutoTween:Bool;
	public function setFrameTween(autoTween:Bool, lastFrameAutoTween:Bool):AnimationState
	{
		this.autoTween = autoTween;
		this.lastFrameAutoTween = lastFrameAutoTween;
		return this;
	}

	private var _armature:Armature;
	private var _timelineStateList:Array<TimelineState>;
	private var _mixingTransforms:Array<String>;

	private var _isPlaying:Bool;
	private var _time:Float;
	private var _currentFrameIndex:Int;
	private var _currentFramePosition:Int;
	private var _currentFrameDuration:Int;

	private var _pausePlayheadInFade:Bool;
	private var _isFadeOut:Bool;
	private var _fadeTotalWeight:Float;
	private var _fadeCurrentTime:Float;
	private var _fadeBeginTime:Float;

	private var _name:String;
	/**
	 * The name of the animation state.
	 */
    public var name(get, null):String;
	public function get_name():String
	{
		return _name;
	}

	/** @private */
	public var _layer:Int;
	/**
	 * The layer of the animation. When calculating the final blend weights, animations in higher layers will get their weights.
	 */
    public var layer(get, null):Int;
	public function get_layer():Int
	{
		return _layer;
	}

	/** @private */
	public var _group:String;
	/**
	 * The group of the animation.
	 */
    public var group(get, null):String;
	public function get_group():String
	{
		return _group;
	}

	private var _clip:AnimationData;
	/**
	 * The clip that is being played by this animation state.
	 * @see dragonBones.objects.AnimationData.
	 */
    public var clip(get, null):AnimationData;
	public function get_clip():AnimationData
	{
		return _clip;
	}

	private var _isComplete:Bool;
	/**
	 * Is animation complete.
	 */
    public var isComplete(get, null):Bool;
	public function get_isComplete():Bool
	{
		return _isComplete;
	}
	/**
	 * Is animation playing.
	 */
    public var isPlaying(get, null):Bool;
	public function get_isPlaying():Bool
	{
		return (_isPlaying && !_isComplete);
	}

	private var _currentPlayTimes:Int;
	/**
	 * Current animation played times
	 */
	public var currentPlayTimes(get, null):Int;
	public function get_currentPlayTimes():Int
	{
		return _currentPlayTimes < 0 ? 0 : _currentPlayTimes;
	}

	private var _totalTime:Int;
	/**
	 * The length of the animation clip in seconds.
	 */
	public var totalTime(get, null):Float;
	public function get_totalTime():Float
	{
		return _totalTime * 0.001;
	}

	private var _currentTime:Int;
	/**
	 * The current time of the animation.
	 */
	public var currentTime(get, null):Float;
	public function get_currentTime():Float
	{
		return _currentTime < 0 ? 0 : _currentTime * 0.001;
	}
	public function setCurrentTime(value:Float):AnimationState
	{
		if(value < 0 || Math.isNaN(value))
		{
			value = 0;
		}
		_time = value;
		_currentTime = Std.int(_time * 1000);
		return this;
	}

	private var _fadeWeight:Float;
	public var fadeWeight(get, null):Float;
	public function get_fadeWeight():Float
	{
		return _fadeWeight;
	}

	private var _fadeState:Int;
	public var fadeState(get, null):Int;
	public function get_fadeState():Int
	{
		return _fadeState;
	}

	private var _fadeTotalTime:Float;
	public var fadeTotalTime(get, null):Float;
	public function get_fadeTotalTime():Float
	{
		return _fadeTotalTime;
	}

	private var _timeScale:Float;
	/**
	 * The amount by which passed time should be scaled. Used to slow down or speed up the animation. Defaults to 1.
	 */
    public var timeScale(get, null):Float;
	public function get_timeScale():Float
	{
		return _timeScale;
	}
	public function setTimeScale(value:Float):AnimationState
	{
		if(Math.isNaN(value) || value == Math.POSITIVE_INFINITY)
		{
			value = 1;
		}
		_timeScale = value;
		return this;
	}

	private var _playTimes:Int;
	/**
	 * playTimes Play times(0:loop forever, 1~+∞:play times, -1~-∞:will fade animation after play complete).
	 */
    public var playTimes(get, null):Int;
	public function get_playTimes():Int
	{
		return _playTimes;
	}
	public function setPlayTimes(value:Int):AnimationState
	{
		if(Math.round(_totalTime * 0.001 * _clip.frameRate) < 2)
		{
			_playTimes = value < 0?-1:1;
		}
		else
		{
			_playTimes = value < 0?-value:value;
		}
		autoFadeOut = value < 0?true:false;
		return this;
	}

	public function new()
	{
		_timelineStateList = new Array<TimelineState>();
		_mixingTransforms = new Array<String>();
	}

	/** @private */
	public function fadeIn(armature:Armature, clip:AnimationData, fadeTotalTime:Float, timeScale:Float, playTimes:Float, pausePlayhead:Bool):AnimationState
	{
		_armature = armature;
		_clip = clip;
		_pausePlayheadInFade = pausePlayhead;

		_name = _clip.name;
		_totalTime = _clip.duration;

		autoTween = _clip.autoTween;

		setTimeScale(timeScale);
		setPlayTimes(Std.int(playTimes));

		//reset
		_isComplete = false;
		_currentFrameIndex = -1;
		_currentPlayTimes = -1;
		if(Math.round(_totalTime * _clip.frameRate * 0.001) < 2 || timeScale == Math.POSITIVE_INFINITY)
		{
			_currentTime = _totalTime;
		}
		else
		{
			_currentTime = -1;
		}
		_time = 0;
		_mixingTransforms = new Array<String>();

		//fade start
		_isFadeOut = false;
		_fadeWeight = 0;
		_fadeTotalWeight = 1;
		_fadeState = -1;
		_fadeCurrentTime = 0;
		_fadeBeginTime = _fadeCurrentTime;
		_fadeTotalTime = fadeTotalTime * _timeScale;

		//default
		_isPlaying = true;
		displayControl = true;
		lastFrameAutoTween = true;
		additiveBlending = false;
		weight = 1;
		fadeOutTime = fadeTotalTime;

		updateTimelineStates();
		return this;
	}

	/**
	 * Fade out the animation state
	 * @param fadeOutTime
	 * @param pauseBeforeFadeOutComplete pause the animation before fade out complete
	 */
	public function fadeOut(fadeTotalTime:Float, pausePlayhead:Bool):AnimationState
	{
		if(_armature == null)
		{
			return null;
		}

		if(Math.isNaN(fadeTotalTime) || fadeTotalTime < 0)
		{
			fadeTotalTime = 0;
		}
		_pausePlayheadInFade = pausePlayhead;

		if(_isFadeOut)
		{
			if(fadeTotalTime > _fadeTotalTime / _timeScale - (_fadeCurrentTime - _fadeBeginTime))
			{
				//如果已经在淡出中，新的淡出需要更长的淡出时间，则忽略
				//If the animation is already in fade out, the new fade out will be ignored.
				return this;
			}
		}
		else
		{
			//第一次淡出
			//The first time to fade out.
			for (timelineState in _timelineStateList)
			{
				timelineState.fadeOut();
			}
		}

		//fade start
		_isFadeOut = true;
		_fadeTotalWeight = _fadeWeight;
		_fadeState = -1;
		_fadeBeginTime = _fadeCurrentTime;
		_fadeTotalTime = _fadeTotalWeight >= 0?fadeTotalTime * _timeScale:0;

		//default
		displayControl = false;

		return this;
	}

	/**
	 * Play the current animation. 如果动画已经播放完毕, 将不会继续播放.
	 */
	public function play():AnimationState
	{
		_isPlaying = true;
		return this;
	}

	/**
	 * Stop playing current animation.
	 */
	public function stop():AnimationState
	{
		_isPlaying = false;
		return this;
	}

	public function getMixingTransform(timelineName:String):Bool
	{
		return _mixingTransforms.indexOf(timelineName) >= 0;
	}

	/**
	 * Adds a transform which should be animated. This allows you to reduce the number of animations you have to create.
	 * @param timelineName Bone's timeline name.
	 * @param recursive if involved child armature's timeline.
	 */
	public function addMixingTransform(timelineName:String, recursive:Bool = true):AnimationState
	{
		if(recursive)
		{
			var boneList:Array<Bone> = _armature.getBones(false);
			var i:Int = boneList.length;
			var currentBone:Bone = null;
			while(i -- > 0)
			{
				var bone:Bone = boneList[i];
				var boneName:String = bone.name;
				if(boneName == timelineName)
				{
					currentBone = bone;
				}
				if(currentBone != null && (currentBone == bone || currentBone.contains(bone)))
				{
					if(_clip.getTimeline(boneName) != null)
					{
						if(_mixingTransforms.indexOf(boneName) < 0)
						{
							_mixingTransforms.push(boneName);
						}
					}
				}
			}
		}
		else if(_clip.getTimeline(timelineName) != null)
		{
			if(_mixingTransforms.indexOf(timelineName) < 0)
			{
				_mixingTransforms.push(timelineName);
			}
		}

		updateTimelineStates();
		return this;
	}

	/**
	 * Removes a transform which was supposed be animated.
	 * @param timelineName Bone's timeline name.
	 * @param recursive If involved child armature's timeline.
	 */
	public function removeMixingTransform(timelineName:String, recursive:Bool = true):AnimationState
	{
		if(recursive)
		{
			var boneList:Array<Bone> = _armature.getBones(false);
			var currentBone:Bone = null;
			var i:Int = boneList.length;
			while(i -- > 0)
			{
				var bone:Bone = boneList[i];
				if(bone.name == timelineName)
				{
					currentBone = bone;
				}
				if(currentBone != null && (currentBone == bone || currentBone.contains(bone)))
				{
					var index1:Int = _mixingTransforms.indexOf(bone.name);
					if(index1 >= 0)
					{
						_mixingTransforms.splice(index1, 1);
					}
				}
			}
		}
		else
		{
			var index2:Int = _mixingTransforms.indexOf(timelineName);
			if(index2 >= 0)
			{
				_mixingTransforms.splice(index2, 1);
			}
		}
		updateTimelineStates();

		return this;
	}

	public function removeAllMixingTransform():AnimationState
	{
		_mixingTransforms = new Array<String>();
		updateTimelineStates();
		return this;
	}

	/** @private */
	public function advanceTime(passedTime:Float):Bool
	{
		passedTime *= _timeScale;

		advanceFadeTime(passedTime);

		if(_fadeWeight != 0)
		{
			advanceTimelinesTime(passedTime);
		}

		return _isFadeOut && _fadeState == 1;
	}

	/**
	 * @private
	 * Update timeline state based on mixing transforms and clip.
	 */
	public function updateTimelineStates():Void
	{
		var timelineState:TimelineState;
		var i:Int = _timelineStateList.length;
		while(i -- > 0)
		{
			timelineState = _timelineStateList[i];
			if(_armature.getBone(timelineState.name) == null)
			{
				removeTimelineState(timelineState);
			}
		}

		if(_mixingTransforms.length > 0)
		{
			i = _timelineStateList.length;
			while(i -- > 0)
			{
				timelineState = _timelineStateList[i];
				if(_mixingTransforms.indexOf(timelineState.name) < 0)
				{
					removeTimelineState(timelineState);
				}
			}

			for (timelineName in _mixingTransforms)
			{
				addTimelineState(timelineName);
			}
		}
		else
		{
			for (timeline in _clip.timelineList)
			{
				addTimelineState(timeline.name);
			}
		}
	}

	private function addTimelineState(timelineName:String):Void
	{
		var bone:Bone = _armature.getBone(timelineName);
		if(bone != null)
		{
			for (eachState in _timelineStateList)
			{
				if(eachState.name == timelineName)
				{
					return;
				}
			}
			var timelineState:TimelineState = TimelineState.borrowObject();
			timelineState.fadeIn(bone, this, _clip.getTimeline(timelineName));
			_timelineStateList.push(timelineState);
		}
	}

	private function removeTimelineState(timelineState:TimelineState):Void
	{
		var index:Int = _timelineStateList.indexOf(timelineState);
		_timelineStateList.splice(index, 1);
		TimelineState.returnObject(timelineState);
	}

	private function advanceFadeTime(passedTime:Float):Void
	{
		var fadeStartFlg:Bool = false;
		var fadeCompleteFlg:Bool = false;

		if(_fadeBeginTime >= 0)
		{
			var fadeState:Int = _fadeState;
			_fadeCurrentTime += passedTime < 0?-passedTime:passedTime;
			if(_fadeCurrentTime >= _fadeBeginTime + _fadeTotalTime)
			{
				//fade complete
				if(
					_fadeWeight == 1 ||
					_fadeWeight == 0
				)
				{
					fadeState = 1;
					if (_pausePlayheadInFade)
					{
						_pausePlayheadInFade = false;
						_currentTime = -1;
					}
				}
				_fadeWeight = _isFadeOut?0:1;
			}
			else if(_fadeCurrentTime >= _fadeBeginTime)
			{
				//fading
				fadeState = 0;
				//暂时只支持线性淡入淡出
				//Currently only support Linear fadein and fadeout
				_fadeWeight = (_fadeCurrentTime - _fadeBeginTime) / _fadeTotalTime * _fadeTotalWeight;
				if(_isFadeOut)
				{
					_fadeWeight = _fadeTotalWeight - _fadeWeight;
				}
			}
			else
			{
				//before fade
				fadeState = -1;
				_fadeWeight = _isFadeOut?1:0;
			}

			if(_fadeState != fadeState)
			{
				//_fadeState == -1 && (fadeState == 0 || fadeState == 1)
				if(_fadeState == -1)
				{
					fadeStartFlg = true;
				}

				//(_fadeState == -1 || _fadeState == 0) && fadeState == 1
				if(fadeState == 1)
				{
					fadeCompleteFlg = true;
				}
				_fadeState = fadeState;
			}
		}

		var event:AnimationEvent;

		if(fadeStartFlg)
		{
			if(_isFadeOut)
			{
				if(_armature.hasEventListener(AnimationEvent.FADE_OUT))
				{
					event = new AnimationEvent(AnimationEvent.FADE_OUT);
					event.animationState = this;
					_armature._eventList.push(event);
				}
			}
			else
			{
				hideBones();

				if(_armature.hasEventListener(AnimationEvent.FADE_IN))
				{
					event = new AnimationEvent(AnimationEvent.FADE_IN);
					event.animationState = this;
					_armature._eventList.push(event);
				}
			}
		}

		if(fadeCompleteFlg)
		{
			if(_isFadeOut)
			{
				if(_armature.hasEventListener(AnimationEvent.FADE_OUT_COMPLETE))
				{
					event = new AnimationEvent(AnimationEvent.FADE_OUT_COMPLETE);
					event.animationState = this;
					_armature._eventList.push(event);
				}
			}
			else
			{
				if(_armature.hasEventListener(AnimationEvent.FADE_IN_COMPLETE))
				{
					event = new AnimationEvent(AnimationEvent.FADE_IN_COMPLETE);
					event.animationState = this;
					_armature._eventList.push(event);
				}
			}
		}
	}

	private function advanceTimelinesTime(passedTime:Float):Void
	{
		if(_isPlaying && !_pausePlayheadInFade)
		{
			_time += passedTime;
		}

		var startFlg:Bool = false;
		var completeFlg:Bool = false;
		var loopCompleteFlg:Bool = false;
		var isThisComplete:Bool = false;
		var currentPlayTimes:Int = 0;
		var currentTime:Int = Std.int(_time * 1000);
		if(_playTimes == 0)
		{
			isThisComplete = false;
			currentPlayTimes = Std.int(Math.ceil(Math.abs(currentTime) / _totalTime));
			if (currentPlayTimes == 0) {
			    currentPlayTimes = 1;
			}
			//currentTime -= Math.floor(currentTime / _totalTime) * _totalTime;
			currentTime -= Std.int(currentTime / _totalTime) * _totalTime;

			if(currentTime < 0)
			{
				currentTime += _totalTime;
			}
		}
		else
		{
			var totalTimes:Int = _playTimes * _totalTime;
			if(currentTime >= totalTimes)
			{
				currentTime = totalTimes;
				isThisComplete = true;
			}
			else if(currentTime <= -totalTimes)
			{
				currentTime = -totalTimes;
				isThisComplete = true;
			}
			else
			{
				isThisComplete = false;
			}

			if(currentTime < 0)
			{
				currentTime += totalTimes;
			}

			currentPlayTimes = Std.int(Math.ceil(currentTime / _totalTime));
			if (currentPlayTimes == 0) {
			    currentPlayTimes = 1;
			}
			//currentTime -= Math.floor(currentTime / _totalTime) * _totalTime;
			currentTime -= Std.int(currentTime / _totalTime) * _totalTime;

			if(isThisComplete)
			{
				currentTime = _totalTime;
			}
		}

		//update timeline
		_isComplete = isThisComplete;
		var progress:Float = _time * 1000 / _totalTime;
		for (timeline in _timelineStateList)
		{
			timeline.update(progress);
			_isComplete = timeline._isComplete && _isComplete;
		}

		//update main timeline
		if(_currentTime != currentTime)
		{
			if(_currentPlayTimes != currentPlayTimes)    //check loop complete
			{
				if(_currentPlayTimes > 0 && currentPlayTimes > 1)
				{
					loopCompleteFlg = true;
				}
				_currentPlayTimes = currentPlayTimes;
			}

			if(_currentTime < 0)    //check start
			{
				startFlg = true;
			}

			if(_isComplete)    //check complete
			{
				completeFlg = true;
			}

			_currentTime = currentTime;
			/*
			if(isThisComplete)
			{
				currentTime = _totalTime * 0.999999;
			}
			//[0, _totalTime)
			*/
			updateMainTimeline(isThisComplete);
		}

		var event:AnimationEvent;
		if(startFlg)
		{
			if(_armature.hasEventListener(AnimationEvent.START))
			{
				event = new AnimationEvent(AnimationEvent.START);
				event.animationState = this;
				_armature._eventList.push(event);
			}
		}

		if(completeFlg)
		{
			if(_armature.hasEventListener(AnimationEvent.COMPLETE))
			{
				event = new AnimationEvent(AnimationEvent.COMPLETE);
				event.animationState = this;
				_armature._eventList.push(event);
			}
			if(autoFadeOut)
			{
				fadeOut(fadeOutTime, true);
			}
		}
		else if(loopCompleteFlg)
		{
			if(_armature.hasEventListener(AnimationEvent.LOOP_COMPLETE))
			{
				event = new AnimationEvent(AnimationEvent.LOOP_COMPLETE);
				event.animationState = this;
				_armature._eventList.push(event);
			}
		}
	}

	private function updateMainTimeline(isThisComplete:Bool):Void
	{
		var frameList:Array<Frame> = _clip.frameList;
		if(frameList != null && frameList.length > 0)
		{
			var prevFrame:Frame = null;
			var currentFrame:Frame = null;
			for (i in 0..._clip.frameList.length)
			{
				if(_currentFrameIndex < 0)
				{
					_currentFrameIndex = 0;
				}
				else if(_currentTime < _currentFramePosition || _currentTime >= _currentFramePosition + _currentFrameDuration)
				{
					_currentFrameIndex ++;
					if(_currentFrameIndex >= frameList.length)
					{
						if(isThisComplete)
						{
							_currentFrameIndex --;
							break;
						}
						else
						{
							_currentFrameIndex = 0;
						}
					}
				}
				else
				{
					break;
				}
				currentFrame = frameList[_currentFrameIndex];

				if(prevFrame != null)
				{
					_armature.arriveAtFrame(prevFrame, null, this, true);
				}

				_currentFrameDuration = currentFrame.duration;
				_currentFramePosition = currentFrame.position;
				prevFrame = currentFrame;
			}

			if(currentFrame != null)
			{
				_armature.arriveAtFrame(currentFrame, null, this, false);
			}
		}
	}

	private function hideBones():Void
	{
		for (timelineName in _clip.hideTimelineNameMap)
		{
			var bone:Bone = _armature.getBone(timelineName);
			if(bone != null)
			{
				bone.hideSlots();
			}
		}
	}

	private function clear():Void
	{
		var i:Int = _timelineStateList.length;
		while(i -- > 0)
		{
			TimelineState.returnObject(_timelineStateList[i]);
		}
		_timelineStateList = new Array<TimelineState>();
		_mixingTransforms = new Array<String>();

		_armature = null;
		_clip = null;
	}
}

