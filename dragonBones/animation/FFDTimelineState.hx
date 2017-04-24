package dragonBones.animation
{
import dragonBones.Armature;
import dragonBones.Slot;
import dragonBones.core.DragonBones;
import dragonBones.core.dragonBones_internal;
import dragonBones.objects.ExtensionFrameData;
import dragonBones.objects.FFDTimelineData;
import dragonBones.objects.TimelineData;


/**
 * @private
 */
public final class FFDTimelineState extends TweenTimelineState
{
	public var slot:Slot;
	
	private var _ffdDirty:Bool;
	private var _tweenFFD:Int;
	private inline var _ffdVertices:Vector.<Number> = new Vector.<Number>();
	private inline var _durationFFDVertices:Vector.<Number> = new Vector.<Number>();
	private var _slotFFDVertices:Vector.<Number>;
	
	public function FFDTimelineState()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		slot = null;
		
		_ffdDirty = false;
		_tweenFFD = TWEEN_TYPE_NONE;
		_ffdVertices.fixed = false;
		_durationFFDVertices.fixed = false;
		_ffdVertices.length = 0;
		_durationFFDVertices.length = 0;
		_slotFFDVertices = null;
	}
	
	override private function _onArriveAtFrame():Void
	{
		super._onArriveAtFrame();
		
		if (slot.displayIndex >= 0 && _animationState._isDisabled(slot)) 
		{
			_tweenEasing = DragonBones.NO_TWEEN;
			_curve = null;
			_tweenFFD = TWEEN_TYPE_NONE;
			return;
		}
		
		inline var currentFrame:ExtensionFrameData = _currentFrame as ExtensionFrameData;
		
		_tweenFFD = TWEEN_TYPE_NONE;
		
		if (_tweenEasing !== DragonBones.NO_TWEEN || _curve)
		{
			inline var currentFFDVertices:Vector.<Number> = currentFrame.tweens;
			inline var nextFFDVertices:Vector.<Number> = (currentFrame.next as ExtensionFrameData).tweens;
			for (var i:UInt = 0, l:UInt = currentFFDVertices.length; i < l; ++i) 
			{
				inline var duration:Float = nextFFDVertices[i] - currentFFDVertices[i];
				_durationFFDVertices[i] = duration;
				if (duration !== 0.0) 
				{
					_tweenFFD = TWEEN_TYPE_ALWAYS;
				}
			}
		}
		
		if (_tweenFFD === TWEEN_TYPE_NONE)
		{
			_tweenFFD = TWEEN_TYPE_ONCE;
			for (i = 0, l = _durationFFDVertices.length; i < l; ++i)
			{
				_durationFFDVertices[i] = 0.0;
			}
		}
	}
	
	override private function _onUpdateFrame():Void
	{
		super._onUpdateFrame();
		
		var tweenProgress:Float = 0.0;
		
		if (_tweenFFD !== TWEEN_TYPE_NONE && slot.parent._blendLayer >= _animationState._layer)
		{
			if (_tweenFFD === TWEEN_TYPE_ONCE)
			{
				_tweenFFD = TWEEN_TYPE_NONE;
				tweenProgress = 0.0;
			}
			else
			{
				tweenProgress = _tweenProgress;
			}
			
			inline var currentFFDVertices:Vector.<Number> = (_currentFrame as ExtensionFrameData).tweens;
			for (var i:UInt = 0, l:UInt = currentFFDVertices.length; i < l; ++i)
			{
				_ffdVertices[i] = currentFFDVertices[i] + _durationFFDVertices[i] * tweenProgress;
			}
			
			_ffdDirty = true;
		}
	}
	
	override public function _init(armature:Armature, animationState:AnimationState, timelineData:TimelineData):Void
	{
		super._init(armature, animationState, timelineData);
		
		_slotFFDVertices = slot._ffdVertices;
		
		_ffdVertices.length = (_timelineData.frames[0] as ExtensionFrameData).tweens.length;
		_durationFFDVertices.length = _ffdVertices.length;
		_ffdVertices.fixed = true;
		_durationFFDVertices.fixed = true;
		
		for (var i:UInt = 0, l:UInt = _ffdVertices.length; i < l; ++i) 
		{
			_ffdVertices[i] = 0.0;
		}
		
		for (i = 0, l = _durationFFDVertices.length; i < l; ++i) 
		{
			_durationFFDVertices[i] = 0.0;
		}
	}
	
	override public function fadeOut():Void
	{
		_tweenFFD = TWEEN_TYPE_NONE;
	}
	
	override public function update(passedTime:Float):Void
	{
		super.update(passedTime);
		
		if (slot._meshData !== (_timelineData as FFDTimelineData).display.mesh) 
		{
			return;
		}
		
		// Fade animation.
		if (_tweenFFD !== TWEEN_TYPE_NONE || _ffdDirty)
		{
			if (_animationState._fadeState !== 0 || _animationState._subFadeState !== 0)
			{
				inline var fadeProgress:Float = Math.pow(_animationState._fadeProgress, 4.0);
				
				for (var i:UInt = 0, l:UInt = _ffdVertices.length; i < l; ++i)
				{
					_slotFFDVertices[i] += (_ffdVertices[i] - _slotFFDVertices[i]) * fadeProgress;
				}
				
				slot._meshDirty = true;
			}
			else if (_ffdDirty)
			{
				_ffdDirty = false;
				
				for (i = 0, l = _ffdVertices.length; i < l; ++i)
				{
					_slotFFDVertices[i] = _ffdVertices[i];
				}
				
				slot._meshDirty = true;
			}
		}
	}
}
}