﻿package dragonBones.objects;

import openfl.errors.ArgumentError;
import openfl.Vector;
	
/**
 * @language zh_CN
 * 动画数据。
 * @version DragonBones 3.0
 */
@:allow(dragonBones) @:final class AnimationData extends TimelineData
{
	/**
	 * @language zh_CN
	 * 持续的帧数。
	 * @version DragonBones 3.0
	 */
	public var frameCount:UInt;
	/**
	 * @language zh_CN
	 * 播放次数。 [0: 无限循环播放, [1~N]: 循环播放 N 次]
	 * @version DragonBones 3.0
	 */
	public var playTimes:UInt;
	/**
	 * @language zh_CN
	 * 持续时间。 (以秒为单位)
	 * @version DragonBones 3.0
	 */
	public var duration:Float;
	/**
	 * @language zh_CN
	 * 淡入时间。 (以秒为单位)
	 * @version DragonBones 3.0
	 */
	public var fadeInTime:Float;
	/**
	 * @private
	 */
	private var cacheFrameRate:Float;
	/**
	 * @language zh_CN
	 * 数据名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @private
	 */
	private var zOrderTimeline:ZOrderTimelineData;
	/**
	 * @private
	 */
	private var boneTimelines:Map<String, BoneTimelineData> = new Map<String, BoneTimelineData>();
	/**
	 * @private
	 */
	private var slotTimelines:Map<String, SlotTimelineData> = new Map<String, SlotTimelineData>();
	/**
	 * @private
	 */
	private var ffdTimelines:Map<String, Map<String, Map<String, FFDTimelineData>>> = new Map<String, Map<String, Map<String, FFDTimelineData>>>(); // skinName ,slotName, mesh
	/**
	 * @private
	 */
	private var cachedFrames:Vector<Bool> = new Vector<Bool>();
	/**
	 * @private
	 */
	private var boneCachedFrameIndices:Map<String, Vector<Int>> = new Map<String, Vector<Int>>(); //Object<Vector<Float>>
	/**
	 * @private
	 */
	private var slotCachedFrameIndices:Map<String, Vector<Int>> = new Map<String, Vector<Int>>(); //Object<Vector<Float>>
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
		super._onClear();
		
		for (k in boneTimelines.keys())
		{
			boneTimelines[k].returnToPool();
			boneTimelines.remove(k);
		}
		
		for (k in slotTimelines.keys())
		{
			slotTimelines[k].returnToPool();
			slotTimelines.remove(k);
		}
		
		for (k in ffdTimelines.keys()) {
			// for (kA in ffdTimelines[k].keys()) 
			// {
			// 	for (kB in ffdTimelines[k][kA].keys()) 
			// 	{
			// 		ffdTimelines[k][kA][kB].returnToPool();
			// 	}
			// }
			
			ffdTimelines.remove(k);
		}
		
		boneCachedFrameIndices = new Map();
		slotCachedFrameIndices = new Map();
		
		if (zOrderTimeline != null) 
		{
			zOrderTimeline.returnToPool();
		}
		
		frameCount = 0;
		playTimes = 0;
		duration = 0.0;
		fadeInTime = 0.0;
		cacheFrameRate = 0.0;
		name = null;
		//boneTimelines.clear();
		//slotTimelines.clear();
		//ffdTimelines.clear();
		cachedFrames.fixed = false;
		cachedFrames.length = 0;
		//boneCachedFrameIndices.clear();
		//boneCachedFrameIndices.clear();
		zOrderTimeline = null;
	}
	/**
	 * @private
	 */
	private function cacheFrames(frameRate:Float):Void
	{
		if (cacheFrameRate > 0.0)
		{
			return;
		}
		
		cacheFrameRate = Math.max(Math.ceil(frameRate * scale), 1.0);
		var cacheFrameCount:UInt = Math.ceil(cacheFrameRate * duration) + 1; // uint
		cachedFrames.length = cacheFrameCount;
		cachedFrames.fixed = true;
		
		var indices:Vector<Int>, l:UInt;
		
		for (k in boneTimelines.keys()) 
		{
			indices = new Vector<Int>(cacheFrameCount, true);
			l = indices.length;
			for (i in 0...l)
			{
				indices[i] = -1;
			}
			
			boneCachedFrameIndices[k] = indices;
		}
		
		for (k in slotTimelines.keys()) 
		{
			indices = new Vector<Int>(cacheFrameCount, true);
			l = indices.length;
			for (i in 0...l)
			{
				indices[i] = -1;
			}
			
			slotCachedFrameIndices[k] = indices;
		}
	}
	/**
	 * @private
	 */
	private function addBoneTimeline(value:BoneTimelineData):Void
	{
		if (value != null && value.bone != null && !boneTimelines.exists(value.bone.name))
		{
			boneTimelines[value.bone.name] = value;
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @private
	 */
	private function addSlotTimeline(value:SlotTimelineData):Void
	{
		if (value != null && value.slot != null && !slotTimelines.exists(value.slot.name))
		{
			slotTimelines[value.slot.name] = value;
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @private
	 */
	private function addFFDTimeline(value:FFDTimelineData):Void
	{
		if (value != null && value.skin != null && value.slot != null)
		{
			if (!ffdTimelines.exists(value.skin.name))
			{
				ffdTimelines[value.skin.name] = new Map();
			}
			var skin = ffdTimelines[value.skin.name];
			if (!skin.exists(value.slot.slot.name))
			{
				skin[value.slot.slot.name] = new Map();
			}
			var slot = skin[value.slot.slot.name];
			if (!slot.exists(value.display.name))
			{
				slot[value.display.name] = value;
			}
			else
			{
				throw new ArgumentError();
			}
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @private
	 */
	private function getBoneTimeline(name:String):BoneTimelineData
	{
		return boneTimelines[name];
	}
	/**
	 * @private
	 */
	private function getSlotTimeline(name:String):SlotTimelineData
	{
		return slotTimelines[name];
	}
	/**
	 * @private
	 */
	private function getFFDTimeline(skinName:String, slotName:String):Map<String, FFDTimelineData>
	{
		if (ffdTimelines.exists(skinName))
		{
			return ffdTimelines[skinName][slotName];
		}
		return null;
	}
	/**
	 * @private
	 */
	private function getBoneCachedFrameIndices(name: String): Vector<Int> 
	{
		return boneCachedFrameIndices[name];
	}
	/**
	 * @private
	 */
	private function getSlotCachedFrameIndices(name: String): Vector<Int> 
	{
		return slotCachedFrameIndices[name];
	}
}