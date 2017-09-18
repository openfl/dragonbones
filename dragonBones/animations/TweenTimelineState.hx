package dragonBones.animations;

import openfl.Vector;
	
import dragonBones.core.DragonBones;
import dragonBones.objects.TweenFrameData;


/**
 * @private
 */
@:allow(dragonBones) class TweenTimelineState extends TimelineState
{
	private static inline var TWEEN_TYPE_NONE:Int = 0;
	private static inline var TWEEN_TYPE_ONCE:Int = 1;
	private static inline var TWEEN_TYPE_ALWAYS:Int = 2;
	
	static function _getEasingValue(progress:Float, easing:Float):Float
	{
		if (progress <= 0.0) 
		{
			return 0.0;
		} 
		else if (progress >= 1.0) 
		{
			return 1.0;
		}
		
		var value:Float = 1.0;
		if (easing > 2.0)
		{
			return progress;
		}
		else if (easing > 1.0) // Ease in out
		{
			value = 0.5 * (1.0 - Math.cos(progress * Math.PI));
			easing -= 1.0;
		}
		else if (easing > 0.0) // Ease out
		{
			value = 1.0 - Math.pow(1.0 - progress, 2.0);
		}
		else if (easing >= -1) // Ease in
		{
			easing *= -1.0;
			value = Math.pow(progress, 2.0);
		}
		else if (easing >= -2.0) // Ease out in
		{
			easing *= -1.0;
			value = Math.acos(1.0 - progress * 2.0) / Math.PI;
			easing -= 1.0;
		}
		else
		{
			return progress;
		}
		
		return (value - progress) * easing + progress;
	}
	
	static function _getCurveEasingValue(progress:Float, samples:Vector<Float>):Float
	{
		if (progress <= 0.0) 
		{
			return 0.0;
		} 
		else if (progress >= 1.0) 
		{
			return 1.0;
		}
		
		var segmentCount:UInt = samples.length + 1; // + 2 - 1
		var valueIndex:UInt = Math.floor(progress * segmentCount);
		var fromValue:Float = valueIndex == 0 ? 0.0 : samples[valueIndex - 1];
		var toValue:Float = (valueIndex == segmentCount - 1) ? 1.0 : samples[valueIndex];
		
		return fromValue + (toValue - fromValue) * (progress * segmentCount - valueIndex);
	}
	
	private var _tweenProgress:Float;
	private var _tweenEasing:Float;
	private var _curve:Vector<Float>;
	
	private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		_tweenProgress = 0.0;
		_tweenEasing = DragonBones.NO_TWEEN;
		_curve = null;
	}
	
	override private function _onArriveAtFrame():Void
	{
		if (
			_keyFrameCount > 1 &&
			(
				_currentFrame.next != _timelineData.frames[0] ||
				_animationState.playTimes == 0 ||
				_animationState.currentPlayTimes < _animationState.playTimes - 1
			)
		) 
		{
			var currentFrame:TweenFrameData = cast _currentFrame;
			_tweenEasing = currentFrame.tweenEasing;
			_curve = currentFrame.curve;
		}
		else 
		{
			_tweenEasing = DragonBones.NO_TWEEN;
			_curve = null;
		}
		
	}
	
	override private function _onUpdateFrame():Void
	{
		if (_tweenEasing != DragonBones.NO_TWEEN)
		{
			_tweenProgress = (_currentTime - _currentFrame.position + _position) / _currentFrame.duration;
			if (_tweenEasing != 0.0)
			{
				_tweenProgress = _getEasingValue(_tweenProgress, _tweenEasing);
			}
		}
		else if (_curve != null)
		{
			_tweenProgress = (_currentTime - _currentFrame.position + _position) / _currentFrame.duration;
			_tweenProgress = _getCurveEasingValue(_tweenProgress, _curve);
		}
		else
		{
			_tweenProgress = 0.0;
		}
	}
}