package dragonBones.animation;

import dragonBones.Armature;
import dragonBones.core.BaseObject;
import dragonBones.core.DragonBones;
import dragonBones.objects.FrameData;
import dragonBones.objects.TimelineData;

/**
 * @private
 */
class TimelineState extends BaseObject
{
	@:allow("dragonBones.animation") private var _playState:Int; // -1 start 0 play 1 complete
	@:allow("dragonBones.animation") private var _currentPlayTimes:UInt;
	@:allow("dragonBones.animation") private var _currentTime:Float;
	@:allow("dragonBones.animation") private var _timelineData:TimelineData;
	
	private var _frameRate:UInt;
	private var _keyFrameCount:UInt;
	private var _frameCount:UInt;
	private var _position:Float;
	private var _duration:Float;
	private var _animationDutation:Float;
	private var _timeScale:Float;
	private var _timeOffset:Float;
	private var _currentFrame:FrameData;
	private var _armature:Armature;
	private var _animationState:AnimationState;
	private var _mainTimeline:AnimationTimelineState;
	
	private function new() {}
	
	override private function _onClear():Void
	{
		_playState = -1;
		_currentPlayTimes = 0;
		_currentTime = -1;
		_timelineData = null;
		
		_frameRate = 0;
		_keyFrameCount =0;
		_frameCount = 0;
		_position = 0.0;
		_duration = 0.0
		_animationDutation = 0.0
		_timeScale = 1.0
		_timeOffset = 0.0
		_currentFrame = null;
		_armature = null;
		_animationState = null;
		_mainTimeline = null;
	}
	
	private function _onUpdateFrame():Void {}
	private function _onArriveAtFrame():Void {}
	
	private function _setCurrentTime(passedTime:Float):Bool
	{
		var prevState:Int = _playState;
		var currentPlayTimes:UInt = 0;
		var currentTime:Float = 0.0;
		
		if (_mainTimeline != null && _keyFrameCount === 1) 
		{
			_playState = _animationState._timeline._playState >= 0 ? 1 : -1;
			currentPlayTimes = 1;
			currentTime = _mainTimeline._currentTime;
		}
		else if (_mainTimeline == null || _timeScale !== 1.0 || _timeOffset !== 0.0)  // Scale and offset.
		{
			var playTimes:UInt = _animationState.playTimes;
			var totalTime:Float = playTimes * _duration;
			
			passedTime *= _timeScale;
			if (_timeOffset !== 0.0) 
			{
				passedTime += _timeOffset * _animationDutation;
			}
			
			if (playTimes > 0 && (passedTime >= totalTime || passedTime <= -totalTime)) 
			{
				if (_playState <= 0 && _animationState._playheadState === 3) 
				{
					_playState = 1;
				}
				
				currentPlayTimes = playTimes;
				
				if (passedTime < 0.0) 
				{
					currentTime = 0.0;
				}
				else 
				{
					currentTime = _duration;
				}
			}
			else 
			{
				if (_playState !== 0 && _animationState._playheadState === 3) 
				{
					_playState = 0;
				}
				
				if (passedTime < 0.0) 
				{
					passedTime = -passedTime;
					currentPlayTimes = Math.floor(passedTime / _duration);
					currentTime = _duration - (passedTime % _duration);
				}
				else 
				{
					currentPlayTimes = Math.floor(passedTime / _duration);
					currentTime = passedTime % _duration;
				}
			}
		}
		else 
		{
			_playState = _animationState._timeline._playState;
			currentPlayTimes = _animationState._timeline._currentPlayTimes;
			currentTime = _mainTimeline._currentTime;
		}
		
		currentTime += _position;
		
		if (_currentPlayTimes === currentPlayTimes && _currentTime === currentTime) 
		{
			return false;
		}
		
		// Clear frame flag when timeline start or loopComplete.
		if (
			(prevState < 0 && _playState !== prevState) ||
			(_playState <= 0 && _currentPlayTimes !== currentPlayTimes)
		) 
		{
			_currentFrame = null;
		}
		
		_currentPlayTimes = currentPlayTimes;
		_currentTime = currentTime;
		
		return true;
	}
	
	public function _init(armature: Armature, animationState: AnimationState, timelineData: TimelineData):Void 
	{
		_armature = armature;
		_animationState = animationState;
		_timelineData = timelineData;
		_mainTimeline = _animationState._timeline;
		
		if (this == _mainTimeline)
		{
			_mainTimeline = null;
		}
		
		_frameRate = _armature.armatureData.frameRate;
		_keyFrameCount = _timelineData.frames.length;
		_frameCount = _animationState.animationData.frameCount;
		_position = _animationState._position;
		_duration = _animationState._duration;
		_animationDutation = _animationState.animationData.duration;
		_timeScale = !_mainTimeline ? 1.0 : (1.0 / _timelineData.scale);
		_timeOffset = !_mainTimeline ? 0.0 : _timelineData.offset;
	}
	
	public function fadeOut():Void {}
	
	public function invalidUpdate():Void
	{
		_timeScale = this == _animationState._timeline? 1: (1 / _timelineData.scale);
		_timeOffset = this == _animationState._timeline? 0: _timelineData.offset;
	}
	
	public function update(passedTime:Float):Void
	{
		if (_playState <= 0 && _setCurrentTime(passedTime)) 
		{
			var currentFrameIndex:UInt = _keyFrameCount > 1 ? uint(_currentTime * _frameRate) : 0;
			var currentFrame:FrameData = _timelineData.frames[currentFrameIndex];
			
			if (_currentFrame != currentFrame) 
			{
				_currentFrame = currentFrame;
				_onArriveAtFrame();
			}
			
			_onUpdateFrame();
		}
	}
}