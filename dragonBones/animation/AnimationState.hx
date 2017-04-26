package dragonBones.animation;

import openfl.Vector;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.core.BaseObject;
import dragonBones.events.EventObject;
import dragonBones.objects.AnimationConfig;
import dragonBones.objects.AnimationData;
import dragonBones.objects.BoneTimelineData;
import dragonBones.objects.DisplayData;
import dragonBones.objects.FFDTimelineData;
import dragonBones.objects.SlotTimelineData;


/**
 * @language zh_CN
 * 动画状态，播放动画时产生，可以对每个播放的动画进行更细致的控制和调节。
 * @see dragonBones.animation.Animation
 * @see dragonBones.objects.AnimationData
 * @version DragonBones 3.0
 */
@:allow(dragonBones) @:final class AnimationState extends BaseObject
{
	/**
	 * @language zh_CN
     * 是否对插槽的显示对象有控制权。
	 * @see dragonBones.Slot#displayController
	 * @version DragonBones 3.0
	 */
	public var displayControl:Bool;
	/**
	 * @language zh_CN
     * 是否以增加的方式混合。
	 * @version DragonBones 3.0
	 */
	public var additiveBlending:Bool;
	/**
	 * @language zh_CN
	 * 是否能触发行为。
	 * @version DragonBones 5.0
	 */
	public var actionEnabled:Bool;
	/**
	 * @language zh_CN
     * 播放次数。 [0: 无限循环播放, [1~N]: 循环播放 N 次]
	 * @version DragonBones 3.0
	 */
	public var playTimes:UInt;
	/**
	 * @language zh_CN
     * 播放速度。 [(-N~0): 倒转播放, 0: 停止播放, (0~1): 慢速播放, 1: 正常播放, (1~N): 快速播放]
	 * @version DragonBones 3.0
	 */
	public var timeScale:Float;
	/**
	 * @language zh_CN
     * 混合权重。
	 * @version DragonBones 3.0
	 */
	public var weight:Float;
	/**
	 * @language zh_CN
     * 自动淡出时间。 [-1: 不自动淡出, [0~N]: 淡出时间] (以秒为单位)
     * 当设置一个大于等于 0 的值，动画状态将会在播放完成后自动淡出。
	 * @version DragonBones 3.0
	 */
	public var autoFadeOutTime:Float;
	/**
	 * @private
	 */
	private var fadeTotalTime:Float;
	/**
	 * @private
	 */
	private var _playheadState:Int;
	/**
	 * @private
	 */
	private var _fadeState:Int;
	/**
	 * @private
	 */
	private var _subFadeState:Int;
	/**
	 * @private
	 */
	private var _layer:Int;
	/**
	 * @private
	 */
	private var _position:Float;
	/**
	 * @private
	 */
	private var _duration:Float;
	/**
	 * @private
	 */
	private var _fadeTime:Float;
	/**
	 * @private
	 */
	private var _time:Float;
	/**
	 * @private
	 */
	private var _fadeProgress:Float;
	/**
	 * @private
	 */
	private var _weightResult:Float;
	/**
	 * @private
	 */
	private var _name:String;
	/**
	 * @private
	 */
	private var _group:String;
	/**
	 * @private
	 */
	private var _boneMask:Vector<String> = new Vector<String>();
	/**
	 * @private
	 */
	private var _boneTimelines:Vector<BoneTimelineState> = new Vector<BoneTimelineState>();
	/**
	 * @private
	 */
	private var _slotTimelines:Vector<SlotTimelineState> = new Vector<SlotTimelineState>();
	/**
	 * @private
	 */
	private var _ffdTimelines:Vector<FFDTimelineState> = new Vector<FFDTimelineState>();
	/**
	 * @private
	 */
	private var _animationData:AnimationData;
	/**
	 * @private
	 */
	private var _armature:Armature;
	/**
	 * @private
	 */
	private var _timeline:AnimationTimelineState;
	/**
	 * @private
	 */
	private var _zOrderTimeline: ZOrderTimelineState;
	/**
	 * @private
	 */
	private function new()
	{
		super();
	}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		var l:UInt = _boneTimelines.length;
		for (i in 0...l)
		{
			_boneTimelines[i].returnToPool();
		}
		
		l = _slotTimelines.length;
		for (i in 0...l)
		{
			_slotTimelines[i].returnToPool();
		}
		
		l = _ffdTimelines.length;
		for (i in 0...l)
		{
			_ffdTimelines[i].returnToPool();
		}
		
		if (_timeline != null)
		{
			_timeline.returnToPool();
		}
		
		if (_zOrderTimeline != null)
		{
			_zOrderTimeline.returnToPool();
		}
		
		displayControl = true;
		additiveBlending = false;
		actionEnabled = false;
		playTimes = 1;
		timeScale = 1.0;
		weight = 1.0;
		autoFadeOutTime = -1.0;
		fadeTotalTime = 0.0;
		
		_playheadState = 0;
		_fadeState = -1;
		_subFadeState = -1;
		_layer = 0;
		_position = 0.0;
		_duration = 0.0;
		_fadeTime = 0.0;
		_time = 0.0;
		_fadeProgress = 0.0;
		_weightResult = 0.0;
		_name = null;
		_group = null;
		_boneMask.fixed = false;
		_boneMask.length = 0;
		_boneTimelines.fixed = false;
		_boneTimelines.length = 0;
		_slotTimelines.fixed = false;
		_slotTimelines.length = 0;
		_ffdTimelines.fixed = false;
		_ffdTimelines.length = 0;
		_animationData = null;
		_armature = null;
		_timeline = null;
		_zOrderTimeline = null;
	}
	
	private function _advanceFadeTime(passedTime:Float):Void
	{
		var isFadeOut:Bool = _fadeState > 0;
		var eventType:String, eventObject:EventObject;
		
		if (_subFadeState < 0) // Fade start event.
		{
			_subFadeState = 0;
			
			eventType = isFadeOut ? EventObject.FADE_OUT : EventObject.FADE_IN;
			if (_armature.eventDispatcher.hasEvent(eventType)) 
			{
				eventObject = cast BaseObject.borrowObject(EventObject);
				eventObject.animationState = this;
				_armature._bufferEvent(eventObject, eventType);
			}
		}
		
		if (passedTime < 0.0) 
		{
			passedTime = -passedTime;
		}
		
		_fadeTime += passedTime;
		
		if (_fadeTime >= fadeTotalTime) // Fade complete.
		{
			_subFadeState = 1;
			_fadeProgress = isFadeOut ? 0.0 : 1.0;
		}
		else if (_fadeTime > 0.0) // Fading.
		{
			_fadeProgress = isFadeOut ? (1.0 - _fadeTime / fadeTotalTime) : (_fadeTime / fadeTotalTime);
		}
		else // Before fade.
		{
			_fadeProgress = isFadeOut ? 1.0 : 0.0;
		}
		
		if (_subFadeState > 0) // Fade complete event.
		{
			if (!isFadeOut) 
			{
				_playheadState |= 1; // x1
				_fadeState = 0;
			}
			
			eventType = isFadeOut ? EventObject.FADE_OUT_COMPLETE : EventObject.FADE_IN_COMPLETE;
			if (_armature.eventDispatcher.hasEvent(eventType)) 
			{
				eventObject = cast BaseObject.borrowObject(EventObject);
				eventObject.animationState = this;
				_armature._bufferEvent(eventObject, eventType);
			}
		}
	}
	/**
	 * @private
	 */
	private function _init(armature: Armature, animationData: AnimationData, animationConfig: AnimationConfig):Void 
	{
		_armature = armature;
		_animationData = animationData;
		_name = animationConfig.name != null ? animationConfig.name : animationConfig.animationName;
		
		actionEnabled = animationConfig.actionEnabled;
		additiveBlending = animationConfig.additiveBlending;
		displayControl = animationConfig.displayControl;
		playTimes = animationConfig.playTimes;
		timeScale = animationConfig.timeScale;
		fadeTotalTime = animationConfig.fadeInTime;
		autoFadeOutTime = animationConfig.autoFadeOutTime;
		weight = animationConfig.weight;
		
		if (animationConfig.pauseFadeIn) 
		{
			_playheadState = 2; // 10
		}
		else 
		{
			_playheadState = 3; // 11
		}
		
		_fadeState = -1;
		_subFadeState = -1;
		_layer = animationConfig.layer;
		_time = animationConfig.position;
		_group = animationConfig.group;
		
		if (animationConfig.duration < 0.0) 
		{
			_position = 0.0;
			_duration = _animationData.duration;
		}
		else 
		{
			_position = animationConfig.position;
			_duration = animationConfig.duration;
		}
		
		if (fadeTotalTime <= 0.0) 
		{
			_fadeProgress = 0.999999;
		}
		
		if (animationConfig.boneMask.length > 0) 
		{
			_boneMask.length = animationConfig.boneMask.length;
			var l:UInt = _boneMask.length;
			for (i in 0...l)
			{
				_boneMask[i] = animationConfig.boneMask[i];
			}
			
			_boneMask.fixed = true;
		}
		
		_timeline = cast BaseObject.borrowObject(AnimationTimelineState);
		_timeline._init(_armature, this, _animationData);
		
		if (_animationData.zOrderTimeline != null) 
		{
			_zOrderTimeline = cast BaseObject.borrowObject(ZOrderTimelineState);
			_zOrderTimeline._init(_armature, this, _animationData.zOrderTimeline);
		}
		
		_updateTimelineStates();
	}
	/**
	 * @private
	 */
	private function _updateTimelineStates():Void
	{
		_boneTimelines.fixed = false;
		_slotTimelines.fixed = false;
		_ffdTimelines.fixed = false;
		
		var boneTimelineStates = new Map<String, BoneTimelineState>();
		var slotTimelineStates = new Map<String, SlotTimelineState>();
		var ffdTimelineStates = new Map<String, FFDTimelineState>();
		
		var l:UInt = _boneTimelines.length;
		var boneTimelineState:BoneTimelineState;
		for (i in 0...l) // Create bone timelines map.
		{
			boneTimelineState = _boneTimelines[i];
			boneTimelineStates[boneTimelineState.bone.name] = boneTimelineState;
		}
		
		var bones:Vector<Bone> = _armature.getBones();
		l = bones.length;
		var bone:Bone, boneTimelineName:String, boneTimelineData:BoneTimelineData;
		for (i in 0...l)
		{
			bone = bones[i];
			boneTimelineName = bone.name;
			if (containsBoneMask(boneTimelineName))
			{
				boneTimelineData = _animationData.getBoneTimeline(boneTimelineName);
				if (boneTimelineData != null) 
				{
					if (boneTimelineStates.exists(boneTimelineName)) // Remove bone timeline from map.
					{
						boneTimelineStates.remove(boneTimelineName);
					}
					else // Create new bone timeline.
					{
						boneTimelineState = cast BaseObject.borrowObject(BoneTimelineState);
						boneTimelineState.bone = bone;
						boneTimelineState._init(_armature, this, boneTimelineData);
						_boneTimelines.push(boneTimelineState);
					}
				}
			}
		}
		
		for (boneTimelineState in boneTimelineStates) // Remove bone timelines.
		{
			boneTimelineState.bone.invalidUpdate(); //
			_boneTimelines.splice(_boneTimelines.indexOf(boneTimelineState), 1);
			boneTimelineState.returnToPool();
		}
		
		l = _slotTimelines.length;
		var slotTimelineState:SlotTimelineState;
		for (i in 0...l) // Create slot timelines map.
		{ 
			slotTimelineState = _slotTimelines[i];
			slotTimelineStates[slotTimelineState.slot.name] = slotTimelineState;
		}
		
		l = _ffdTimelines.length;
		var ffdTimelineState:FFDTimelineState, display:DisplayData, meshName:String;
		for (i in 0...l) // Create ffd timelines map.
		{ 
			ffdTimelineState = _ffdTimelines[i];
			display = cast(ffdTimelineState._timelineData, FFDTimelineData).display;
			meshName = display.inheritAnimation ? display.mesh.name : display.name;
			ffdTimelineStates[meshName] = ffdTimelineState;
		}
		
		var slots:Vector<Slot> = _armature.getSlots();
		l = slots.length;
		var slot:Slot, slotTimelineName:String, parentTimelineName:String, resetFFDVertices:Bool, slotTimelineData:SlotTimelineData, ffdTimelineDatas:Dynamic;
		for (i in 0...l)
		{
			slot = slots[i];
			slotTimelineName = slot.name;
			parentTimelineName = slot.parent.name;
			resetFFDVertices = false;
			
			if (containsBoneMask(parentTimelineName)) 
			{
				slotTimelineData = _animationData.getSlotTimeline(slotTimelineName);
				if (slotTimelineData != null) 
				{
					if (slotTimelineStates.exists(slotTimelineName)) // Remove slot timeline from map.
					{
						slotTimelineStates.remove(slotTimelineName);
					}
					else  // Create new slot timeline.
					{
						slotTimelineState = cast BaseObject.borrowObject(SlotTimelineState);
						slotTimelineState.slot = slot;
						slotTimelineState._init(_armature, this, slotTimelineData);
						_slotTimelines.push(slotTimelineState);
					}
				}
				
				ffdTimelineDatas = _animationData.getFFDTimeline(_armature._skinData.name, slotTimelineName);
				if (ffdTimelineDatas != null) 
				{
					for (k in ffdTimelineDatas.keys()) 
					{
						if (ffdTimelineStates.exists(k)) // Remove ffd timeline from map.
						{
							ffdTimelineStates.remove(k);
						}
						else // Create new ffd timeline.
						{
							ffdTimelineState = cast BaseObject.borrowObject(FFDTimelineState);
							ffdTimelineState.slot = slot;
							ffdTimelineState._init(_armature, this, ffdTimelineDatas[k]);
							_ffdTimelines.push(ffdTimelineState);
						}
					}
				}
				else 
				{
					resetFFDVertices = true;
				}
			}
			else 
			{
				resetFFDVertices = true;
			}
			
			if (resetFFDVertices) 
			{
				var lA:UInt = slot._ffdVertices.length;
				for (iA in 0...lA)
				{
					slot._ffdVertices[iA] = 0.0;
				}
				
				slot._meshDirty = true;
			}
		}
		
		for (slotTimelineState in slotTimelineStates) // Remove slot timelines.
		{
			_slotTimelines.splice(_slotTimelines.indexOf(slotTimelineState), 1);
			slotTimelineState.returnToPool();
		}
		
		for (ffdTimelineState in ffdTimelineStates) // Remove ffd timelines.
		{
			_ffdTimelines.splice(_ffdTimelines.indexOf(ffdTimelineState), 1);
			ffdTimelineState.returnToPool();
		}
		
		_boneTimelines.fixed = true;
		_slotTimelines.fixed = true;
		_ffdTimelines.fixed = true;
	}
	/**
	 * @private
	 */
	private function _advanceTime(passedTime:Float, cacheFrameRate:Float):Void
	{
		// Update fade time.
		if (_fadeState != 0 || _subFadeState != 0) 
		{
			_advanceFadeTime(passedTime);
		}
		
		// Update time.
		if (timeScale != 1.0) 
		{
			passedTime *= timeScale;
		}
		
		if (passedTime != 0.0 && _playheadState == 3) // 11
		{
			_time += passedTime;
		}
		
		// Weight.
		_weightResult = weight * _fadeProgress;
		if (_weightResult != 0.0) 
		{
			var isCacheEnabled:Bool = _fadeState == 0 && cacheFrameRate > 0.0;
			var isUpdatesTimeline:Bool = true;
			var isUpdatesBoneTimeline:Bool = true;
			var time:Float = _time;
			
			// Update main timeline.
			_timeline.update(time);
			
			// Cache time internval.
			if (isCacheEnabled) 
			{
				_timeline._currentTime = Math.floor(_timeline._currentTime * cacheFrameRate) / cacheFrameRate;
			}
			
			// Update zOrder timeline.
			if (_zOrderTimeline != null) 
			{
				_zOrderTimeline.update(time);
			}
			
			// Update cache.
			if (isCacheEnabled) 
			{
				var cacheFrameIndex:Int = Math.floor(_timeline._currentTime * cacheFrameRate); // uint
				if (_armature.animation._cacheFrameIndex == cacheFrameIndex) // Same cache.
				{
					isUpdatesTimeline = false;
					isUpdatesBoneTimeline = false;
				}
				else 
				{
					_armature.animation._cacheFrameIndex = cacheFrameIndex;
					
					if (_animationData.cachedFrames[cacheFrameIndex]) // Cached.
					{
						isUpdatesBoneTimeline = false;
					}
					else // Cache.
					{
						_animationData.cachedFrames[cacheFrameIndex] = true;
					}
				}
			}
			
			// Update timelines.
			if (isUpdatesTimeline) 
			{
				var l:UInt;
				if (isUpdatesBoneTimeline) 
				{
					l = _boneTimelines.length;
					for (i in 0...l)
					{
						_boneTimelines[i].update(time);
					}
				}
				
				l = _slotTimelines.length;
				for (i in 0...l)
				{
					_slotTimelines[i].update(time);
				}
				
				l = _ffdTimelines.length;
				for (i in 0...l)
				{
					_ffdTimelines[i].update(time);
				}
			}
		}
		
		if (_fadeState == 0) 
		{
			if (_subFadeState > 0) 
			{
				_subFadeState = 0;
			}
			
			// Auto fade out.
			if (autoFadeOutTime >= 0.0) 
			{
				if (_timeline._playState > 0) 
				{
					fadeOut(autoFadeOutTime);
				}
			}
		}
	}
	/**
	 * @private
	 */
	private function _isDisabled(slot:Slot):Bool
	{
		if (
			displayControl != null &&
			(
				slot.displayController == null ||
				slot.displayController == _name ||
				slot.displayController == _group
			)
		) 
		{
			return false;
		}
		
		return true;
	}
	/**
	 * @private
	 */
	private function _getBoneTimelineState(name:String):BoneTimelineState
	{
		for (boneTimelineState in _boneTimelines)
		{
			if (boneTimelineState.bone.name == name)
			{
				return boneTimelineState;
			}
		}
		
		return null;
	}
	/**
	 * @language zh_CN
	 * 继续播放。
	 * @version DragonBones 3.0
	 */
	public function play():Void
	{
		_playheadState = 3; // 11
	}
	/**
	 * @language zh_CN
	 * 暂停播放。
	 * @version DragonBones 3.0
	 */
	public function stop():Void
	{
		_playheadState &= 1; // 0x
	}
	/**
	 * @language zh_CN
	 * 淡出动画。
	 * @param fadeOutTime 淡出时间。 (以秒为单位)
	 * @param pausePlayhead 淡出时是否暂停动画。
	 * @version DragonBones 3.0
	 */
	public function fadeOut(fadeOutTime:Float, pausePlayhead:Bool = true):Void
	{
		if (fadeOutTime < 0.0 || fadeOutTime != fadeOutTime) 
		{
			fadeOutTime = 0.0;
		}
		
		if (pausePlayhead) 
		{
			_playheadState &= 2; // x0
		}
		
		if (_fadeState > 0) {
			if (fadeOutTime > fadeOutTime - _fadeTime) 
			{
				// If the animation is already in fade out, the new fade out will be ignored.
				return;
			}
		}
		else 
		{
			_fadeState = 1;
			_subFadeState = -1;
			
			if (fadeOutTime <= 0.0 || _fadeProgress <= 0.0) 
			{
				_fadeProgress = 0.000001; // Modify _fadeProgress to different value.
			}
			
			var l:UInt = _boneTimelines.length;
			for (i in 0...l)
			{
				_boneTimelines[i].fadeOut();
			}
			
			l = _slotTimelines.length;
			for (i in 0...l)
			{
				_slotTimelines[i].fadeOut();
			}
			
			l = _ffdTimelines.length;
			for (i in 0...l)
			{
				_ffdTimelines[i].fadeOut();
			}
		}
		
		displayControl = false; //
		fadeTotalTime = _fadeProgress > 0.000001 ? fadeOutTime / _fadeProgress : 0.0;
		_fadeTime = fadeTotalTime * (1.0 - _fadeProgress);
	}
	/**
	 * @language zh_CN
     * 是否包含骨骼遮罩。
	 * @param name 指定的骨骼名称。
	 * @version DragonBones 3.0
	 */
	public function containsBoneMask(name:String):Bool
	{
		return _boneMask.length == 0 || _boneMask.indexOf(name) >= 0;
	}
	/**
	 * @language zh_CN
     * 添加骨骼遮罩。
	 * @param boneName 指定的骨骼名称。
	 * @param recursive 是否为该骨骼的子骨骼添加遮罩。
	 * @version DragonBones 3.0
	 */
	public function addBoneMask(name:String, recursive:Bool = true):Void
	{
		var currentBone: Bone = _armature.getBone(name);
		if (currentBone == null) 
		{
			return;
		}
		
		_boneMask.fixed = false;
		
		if (_boneMask.indexOf(name) < 0) // Add mixing
		{
			_boneMask.push(name);
		}
		
		if (recursive) // Add recursive mixing.
		{
			var bones:Vector<Bone> = _armature.getBones();
			var l:UInt = bones.length;
			var bone:Bone;
			for (i in 0...l)
			{
				bone = bones[i];
				if (_boneMask.indexOf(bone.name) < 0 && currentBone.contains(bone))
				{
					_boneMask.push(bone.name);
				}
			}
		}
		
		_boneMask.fixed = true;
		
		_updateTimelineStates();
	}
	/**
	 * @language zh_CN
     * 删除骨骼遮罩。
	 * @param boneName 指定的骨骼名称。
	 * @param recursive 是否删除该骨骼的子骨骼遮罩。
	 * @version DragonBones 3.0
	 */
	public function removeBoneMask(name:String, recursive:Bool = true):Void
	{
		_boneMask.fixed = false;
		
		var index:Int = _boneMask.indexOf(name);
		if (index >= 0) // Remove mixing.
		{
			_boneMask.splice(index, 1);
		}
		
		if (recursive) 
		{
			var currentBone:Bone = _armature.getBone(name);
			if (currentBone != null) 
			{
				var bones:Vector<Bone> = _armature.getBones();
				var l:UInt, bone:Bone;
				if (_boneMask.length > 0) // Remove recursive mixing.
				{
					l = bones.length;
					for (i in 0...l)
					{
						bone = bones[i];
						index = _boneMask.indexOf(bone.name);
						if (index >= 0 && currentBone.contains(bone))
						{
							_boneMask.splice(index, 1);
						}
					}
				}
				else // Add unrecursive mixing.
				{
					for (i in 0...l)
					{
						bone = bones[i];
						if (!currentBone.contains(bone))
						{
							_boneMask.push(bone.name);
						}
					}
				}
			}
		}
		
		_boneMask.fixed = true;
		
		_updateTimelineStates();
	}
	/**
	 * @language zh_CN
	 * 删除所有骨骼遮罩。
	 * @version DragonBones 3.0
	 */
	public function removeAllBoneMask():Void
	{
		_boneMask.fixed = false;
		_boneMask.length = 0;
		_boneMask.fixed = true;
		
		_updateTimelineStates();
	}
	/**
	 * @language zh_CN
     * 混合图层。
	 * @version DragonBones 3.0
	 */
	public var layer(get, never):Int;
	private function get_layer():Int
	{
		return _layer;
	}
	/**
	 * @language zh_CN
     * 混合组。
	 * @version DragonBones 3.0
	 */
	public var group(get, never):String;
	private function get_group():String
	{
		return _group;
	}
	/**
	 * @language zh_CN
	 * 动画名称。
	 * @see dragonBones.objects.AnimationData#name
	 * @version DragonBones 3.0
	 */
	public var name(get, never):String;
	private function get_name():String
	{
		return _name;
	}
	/**
	 * @language zh_CN
	 * 动画数据。
	 * @see dragonBones.objects.AnimationData
	 * @version DragonBones 3.0
	 */
	public var animationData(get, never):AnimationData;
	private function get_animationData():AnimationData
	{
		return _animationData;
	}
	/**
	 * @language zh_CN
	 * 是否播放完毕。
	 * @version DragonBones 3.0
	 */
	public var isCompleted(get, never):Bool;
	private function get_isCompleted():Bool
	{
		return _timeline._playState > 0;
	}
	/**
	 * @language zh_CN
	 * 是否正在播放。
	 * @version DragonBones 3.0
	 */
	public var isPlaying(get, never):Bool;
	private function get_isPlaying():Bool
	{
		return (_playheadState & 2 != 0) && _timeline._playState <= 0;
	}
	/**
	 * @language zh_CN
     * 当前播放次数。
	 * @version DragonBones 3.0
	 */
	public var currentPlayTimes(get, never):UInt;
	private function get_currentPlayTimes():UInt
	{
		return _timeline._currentPlayTimes;
	}
	
	/**
	 * @language zh_CN
     * 动画的总时间。 (以秒为单位)
	 * @version DragonBones 3.0
	 */
	public var totalTime(get, never):Float;
	private function get_totalTime():Float
	{
		return _duration;
	}
	
	/**
	 * @language zh_CN
     * 动画当前播放的时间。 (以秒为单位)
	 * @version DragonBones 3.0
	 */
	public var currentTime(get, set):Float;
	private function get_currentTime():Float
	{
		return _timeline._currentTime;
	}
	private function set_currentTime(value:Float):Float
	{
		if (value < 0 || value != value)
		{
			value = 0;
		}
		
		var currentPlayTimes:UInt = _timeline._currentPlayTimes - (_timeline._playState > 0? 1: 0);
		value = (value % _duration) + currentPlayTimes * _duration;
		if (_time == value) 
		{
			return value;
		}
		
		_time = value;
		_timeline.setCurrentTime(_time);
		
		if (_zOrderTimeline != null) 
		{
			_zOrderTimeline._playState = -1;
		}
		
		var l:UInt = _boneTimelines.length;
		for (i in 0...l)
		{
			_boneTimelines[i]._playState = -1;
		}
		
		l = _slotTimelines.length;
		for (i in 0...l)
		{
			_slotTimelines[i]._playState = -1;
		}
		
		l = _ffdTimelines.length;
		for (i in 0...l)
		{
			_ffdTimelines[i]._playState = -1;
		}
		return value;
	}
}