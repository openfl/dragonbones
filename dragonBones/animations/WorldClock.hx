﻿package dragonBones.animations;

import openfl.Lib;
import openfl.Vector;
	
import dragonBones.core.DragonBones;

/**
 * @language zh_CN
 * WorldClock 提供时钟支持，为每个加入到时钟的 IAnimatable 对象更新时间。
 * @see dragonBones.animations.IAnimateble
 * @see dragonBones.Armature
 * @version DragonBones 3.0
 */
@:allow(dragonBones) @:final class WorldClock implements IAnimateble
{
	/**
	 * @language zh_CN
	 * 一个可以直接使用的全局 WorldClock 实例.
	 * @version DragonBones 3.0
	 */
	public static var clock:WorldClock = new WorldClock();
	/**
	 * @language zh_CN
	 * 当前时间。 (以秒为单位)
	 * @version DragonBones 3.0
	 */
	public var time:Float = Lib.getTimer() / DragonBones.SECOND_TO_MILLISECOND;	
	/**
	 * @language zh_CN
	 * 时间流逝速度，用于控制动画变速播放。 [0: 停止播放, (0~1): 慢速播放, 1: 正常播放, (1~N): 快速播放]
	 * @default 1
	 * @version DragonBones 3.0
	 */
	public var timeScale:Float = 1;
	
	private var _animatebles:Vector<IAnimateble> = new Vector<IAnimateble>();
	private var __clock: WorldClock = null;
	/**
	 * @language zh_CN
	 * 创建一个新的 WorldClock 实例。
	 * 通常并不需要单独创建 WorldClock 实例，可以直接使用 WorldClock.clock 静态实例。
	 * (创建更多独立的 WorldClock 实例可以更灵活的为需要更新的 IAnimateble 实例分组，用于控制不同组不同的播放速度)
	 * @version DragonBones 3.0
	 */
	public function new()
	{
	}
	/**
	 * @language zh_CN
	 * 为所有的 IAnimatable 实例更新时间。
	 * @param passedTime 前进的时间。 (以秒为单位，当设置为 -1 时将自动计算当前帧与上一帧的时间差)
	 * @version DragonBones 3.0
	 */
	public function advanceTime(passedTime:Float):Void
	{
		if (passedTime != passedTime) 
		{
			passedTime = 0.0;
		}
		
		if (passedTime < 0.0) 
		{
			passedTime = Lib.getTimer() / DragonBones.SECOND_TO_MILLISECOND - time;
		}
		
		if (timeScale != 1.0) 
		{
			passedTime *= timeScale;
		}
		
		if (passedTime < 0.0) 
		{
			time -= passedTime;
		}
		else 
		{
			time += passedTime;
		}
		
		if (passedTime != 0) 
		{
			var i:UInt = 0, r:UInt = 0, l:UInt = _animatebles.length;
			var animateble:IAnimateble;
			while (i < l)
			{
				animateble = _animatebles[i];
				if (animateble != null) 
				{
					if (r > 0) 
					{
						_animatebles[i - r] = animateble;
						_animatebles[i] = null;
					}
					
					animateble.advanceTime(passedTime);
				}
				else 
				{
					r++;
				}
				i++;
			}
			
			if (r > 0) 
			{
				l = _animatebles.length;
				for (j in i...l) 
				{
					animateble = _animatebles[j];
					if (animateble != null) 
					{
						_animatebles[j - r] = animateble;
					}
					else 
					{
						r++;
					}
				}
				
				_animatebles.length = _animatebles.length - r;
			}
		}
	}
	/** 
	 * 是否包含 IAnimatable 实例
	 * @param value IAnimatable 实例。
	 * @version DragonBones 3.0
	 */
	public function contains(value:IAnimateble):Bool
	{
		return _animatebles.indexOf(value) >= 0;
	}
	/**
	 * @language zh_CN
	 * 添加 IAnimatable 实例。
	 * @param value IAnimatable 实例。
	 * @version DragonBones 3.0
	 */
	public function add(value:IAnimateble):Void
	{
		if (value != null && _animatebles.indexOf(value) < 0)
		{
			_animatebles.push(value);
			value._clock = this;
		}
	}
	/**
	 * @language zh_CN
	 * 移除 IAnimatable 实例。
	 * @param value IAnimatable 实例。
	 * @version DragonBones 3.0
	 */
	public function remove(value:IAnimateble):Void
	{
		var index:Int = _animatebles.indexOf(value);
		if (index >= 0)
		{
			_animatebles[index] = null;
			value._clock = null;
		}
	}
	/**
	 * @language zh_CN
	 * 清除所有的 IAnimatable 实例。
	 * @version DragonBones 3.0
	 */
	public function clear():Void
	{
		var l:UInt = _animatebles.length;
		var animateble:IAnimateble;
		for (i in 0...l)
		{
			animateble = _animatebles[i];
			_animatebles[i] = null;
			if (animateble != null) 
			{
				animateble._clock = null;
			}
		}
	}
	/**
	 * @inheritDoc
	 */
	private var _clock(get, set):WorldClock;
	private function get__clock(): WorldClock 
	{
		return __clock;
	}
	private function set__clock(value: WorldClock):WorldClock
	{
		if (__clock == value) {
			return value;
		}
		
		var prevClock:WorldClock = __clock;
		__clock = value;
		
		if (prevClock != null) {
			prevClock.remove(this);
		}
		
		if (__clock != null) {
			__clock.add(this);
		}
		return value;
	}
}