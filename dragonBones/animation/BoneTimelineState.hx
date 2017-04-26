package dragonBones.animation;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.core.DragonBones;
import dragonBones.geom.Transform;
import dragonBones.objects.BoneFrameData;
import dragonBones.objects.BoneTimelineData;
import dragonBones.objects.TimelineData;


/**
 * @private
 */
@:allow(dragonBones) @:final class BoneTimelineState extends TweenTimelineState
{
	public var bone:Bone;
	
	private var _transformDirty:Bool;
	private var _tweenTransform:Int;
	private var _tweenRotate:Int;
	private var _tweenScale:Int;
	private var _transform:Transform = new Transform();
	private var _durationTransform:Transform = new Transform();
	private var _boneTransform:Transform;
	private var _originalTransform:Transform;
	
	private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		bone = null;
		
		_transformDirty = false;
		_tweenTransform = TweenTimelineState.TWEEN_TYPE_NONE;
		_tweenRotate = TweenTimelineState.TWEEN_TYPE_NONE;
		_tweenScale = TweenTimelineState.TWEEN_TYPE_NONE;
		_transform.identity();
		_durationTransform.identity();
		_boneTransform = null;
		_originalTransform = null;
	}
	
	override private function _onArriveAtFrame():Void
	{
		super._onArriveAtFrame();
		
		var currentFrame:BoneFrameData = cast(_currentFrame, BoneFrameData);
		
		_tweenTransform = TweenTimelineState.TWEEN_TYPE_ONCE;
		_tweenRotate = TweenTimelineState.TWEEN_TYPE_ONCE;
		_tweenScale = TweenTimelineState.TWEEN_TYPE_ONCE;
		
		if (_keyFrameCount > 1 && (_tweenEasing != DragonBones.NO_TWEEN || _curve != null))
		{
			var currentTransform:Transform = currentFrame.transform;
			var nextFrame:BoneFrameData = cast(currentFrame.next, BoneFrameData);
			var nextTransform:Transform = nextFrame.transform;
			
			// Transform.
			_durationTransform.x = nextTransform.x - currentTransform.x;
			_durationTransform.y = nextTransform.y - currentTransform.y;
			if (_durationTransform.x != 0.0 || _durationTransform.y != 0.0) 
			{
				_tweenTransform = TweenTimelineState.TWEEN_TYPE_ALWAYS;
			}
			
			// Rotate.
			var tweenRotate:Float = currentFrame.tweenRotate;
			if (tweenRotate != DragonBones.NO_TWEEN) 
			{
				if (tweenRotate != 0) 
				{
					if (tweenRotate > 0.0 ? nextTransform.skewY >= currentTransform.skewY : nextTransform.skewY <= currentTransform.skewY) 
					{
						tweenRotate = tweenRotate > 0.0 ? tweenRotate - 1.0 : tweenRotate + 1.0;
					}
					
					_durationTransform.skewX = nextTransform.skewX - currentTransform.skewX + DragonBones.PI_D * tweenRotate;
					_durationTransform.skewY = nextTransform.skewY - currentTransform.skewY + DragonBones.PI_D * tweenRotate;
				}
				else 
				{
					_durationTransform.skewX = Transform.normalizeRadian(nextTransform.skewX - currentTransform.skewX);
					_durationTransform.skewY = Transform.normalizeRadian(nextTransform.skewY - currentTransform.skewY);
				}
				
				if (_durationTransform.skewX != 0.0 || _durationTransform.skewY != 0.0) 
				{
					_tweenRotate = TweenTimelineState.TWEEN_TYPE_ALWAYS;
				}
			}
			else 
			{
				_durationTransform.skewX = 0.0;
				_durationTransform.skewY = 0.0;
			}
			
			// Scale.
			if (currentFrame.tweenScale) 
			{
				_durationTransform.scaleX = nextTransform.scaleX - currentTransform.scaleX;
				_durationTransform.scaleY = nextTransform.scaleY - currentTransform.scaleY;
				if (_durationTransform.scaleX != 0.0 || _durationTransform.scaleY != 0.0) 
				{
					_tweenScale = TweenTimelineState.TWEEN_TYPE_ALWAYS;
				}
			}
			else 
			{
				_durationTransform.scaleX = 0.0;
				_durationTransform.scaleY = 0.0;
			}
		}
		else 
		{
			_durationTransform.x = 0.0;
			_durationTransform.y = 0.0;
			_durationTransform.skewX = 0.0;
			_durationTransform.skewY = 0.0;
			_durationTransform.scaleX = 0.0;
			_durationTransform.scaleY = 0.0;
		}
	}
	
	override private function _onUpdateFrame():Void
	{
		super._onUpdateFrame();
		
		var tweenProgress:Float = 0.0;
		var currentTransform:Transform = cast(_currentFrame, BoneFrameData).transform;
		
		if (_tweenTransform != TweenTimelineState.TWEEN_TYPE_NONE) 
		{
			if (_tweenTransform == TweenTimelineState.TWEEN_TYPE_ONCE) 
			{
				_tweenTransform = TweenTimelineState.TWEEN_TYPE_NONE;
				tweenProgress = 0.0;
			}
			else 
			{
				tweenProgress = _tweenProgress;
			}
			
			if (_animationState.additiveBlending) // Additive blending.
			{
				_transform.x = currentTransform.x + _durationTransform.x * tweenProgress;
				_transform.y = currentTransform.y + _durationTransform.y * tweenProgress;
			}
			else // Normal blending.
			{
				_transform.x = _originalTransform.x + currentTransform.x + _durationTransform.x * tweenProgress;
				_transform.y = _originalTransform.y + currentTransform.y + _durationTransform.y * tweenProgress;
			}
			
			_transformDirty = true;
		}
		
		if (_tweenRotate != TweenTimelineState.TWEEN_TYPE_NONE) 
		{
			if (_tweenRotate == TweenTimelineState.TWEEN_TYPE_ONCE) 
			{
				_tweenRotate = TweenTimelineState.TWEEN_TYPE_NONE;
				tweenProgress = 0.0;
			}
			else 
			{
				tweenProgress = _tweenProgress;
			}
			
			if (_animationState.additiveBlending) // Additive blending.
			{
				_transform.skewX = currentTransform.skewX + _durationTransform.skewX * tweenProgress;
				_transform.skewY = currentTransform.skewY + _durationTransform.skewY * tweenProgress;
			}
			else // Normal blending.
			{
				_transform.skewX = _originalTransform.skewX + currentTransform.skewX + _durationTransform.skewX * tweenProgress;
				_transform.skewY = _originalTransform.skewY + currentTransform.skewY + _durationTransform.skewY * tweenProgress;
			}
			
			_transformDirty = true;
		}
		
		if (_tweenScale != TweenTimelineState.TWEEN_TYPE_NONE) 
		{
			if (_tweenScale == TweenTimelineState.TWEEN_TYPE_ONCE) 
			{
				_tweenScale = TweenTimelineState.TWEEN_TYPE_NONE;
				tweenProgress = 0.0;
			}
			else 
			{
				tweenProgress = _tweenProgress;
			}
			
			if (_animationState.additiveBlending) // Additive blending.
			{
				_transform.scaleX = currentTransform.scaleX + _durationTransform.scaleX * tweenProgress;
				_transform.scaleY = currentTransform.scaleY + _durationTransform.scaleY * tweenProgress;
			}
			else // Normal blending.
			{
				_transform.scaleX = _originalTransform.scaleX * (currentTransform.scaleX + _durationTransform.scaleX * tweenProgress);
				_transform.scaleY = _originalTransform.scaleY * (currentTransform.scaleY + _durationTransform.scaleY * tweenProgress);
			}
			
			_transformDirty = true;
		}
	}
	
	override public function _init(armature: Armature, animationState: AnimationState, timelineData: TimelineData):Void 
	{
		super._init(armature, animationState, timelineData);
		
		_originalTransform = cast(_timelineData, BoneTimelineData).originalTransform;
		_boneTransform = bone._animationPose;
	}
	
	override public function fadeOut():Void
	{
		_transform.skewX = Transform.normalizeRadian(_transform.skewX);
		_transform.skewY = Transform.normalizeRadian(_transform.skewY);
	}
	
	override public function update(passedTime:Float):Void	
	{
		// Blend animation state.
		var animationLayer:Int = _animationState._layer;
		var weight:Float = _animationState._weightResult;
		
		if (bone._updateState <= 0) 
		{
			super.update(passedTime);
			
			bone._blendLayer = animationLayer;
			bone._blendLeftWeight = 1.0;
			bone._blendTotalWeight = weight;
			
			_boneTransform.x = _transform.x * weight;
			_boneTransform.y = _transform.y * weight;
			_boneTransform.skewX = _transform.skewX * weight;
			_boneTransform.skewY = _transform.skewY * weight;
			_boneTransform.scaleX = (_transform.scaleX - 1.0) * weight + 1.0;
			_boneTransform.scaleY = (_transform.scaleY - 1.0) * weight + 1.0;
			
			bone._updateState = 1;
		}
		else if (bone._blendLeftWeight > 0.0) 
		{
			if (bone._blendLayer != animationLayer) 
			{
				if (bone._blendTotalWeight >= bone._blendLeftWeight) 
				{
					bone._blendLeftWeight = 0.0;
				}
				else 
				{
					bone._blendLayer = animationLayer;
					bone._blendLeftWeight -= bone._blendTotalWeight;
					bone._blendTotalWeight = 0.0;
				}
			}
			
			weight *= bone._blendLeftWeight;
			if (weight >= 0.0) 
			{
				super.update(passedTime);
				
				bone._blendTotalWeight += weight;
				
				_boneTransform.x += _transform.x * weight;
				_boneTransform.y += _transform.y * weight;
				_boneTransform.skewX += _transform.skewX * weight;
				_boneTransform.skewY += _transform.skewY * weight;
				_boneTransform.scaleX += (_transform.scaleX - 1.0) * weight;
				_boneTransform.scaleY += (_transform.scaleY - 1.0) * weight;
				
				bone._updateState++;
			}
		}
		
		if (bone._updateState > 0) 
		{
			if (_transformDirty || _animationState._fadeState != 0 || _animationState._subFadeState != 0) 
			{
				_transformDirty = false;
				
				bone.invalidUpdate();
			}
		}
	}
}