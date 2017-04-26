package dragonBones;

import haxe.Constraints;

import openfl.errors.Error;
import openfl.geom.Point;
import openfl.Vector;

import dragonBones.animation.Animation;
import dragonBones.animation.IAnimateble;
import dragonBones.animation.WorldClock;
import dragonBones.core.BaseObject;
import dragonBones.core.DragonBones;
import dragonBones.core.IArmatureProxy;
import dragonBones.enums.ActionType;
import dragonBones.events.EventObject;
import dragonBones.events.IEventDispatcher;
import dragonBones.objects.ActionData;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.SkinData;
import dragonBones.objects.SlotData;
import dragonBones.textures.TextureAtlasData;


/**
 * @language zh_CN
 * 骨架，是骨骼动画系统的核心，由显示容器、骨骼、插槽、动画、事件系统构成。
 * @see dragonBones.objects.ArmatureData
 * @see dragonBones.Bone
 * @see dragonBones.Slot
 * @see dragonBones.animation.Animation
 * @version DragonBones 3.0
 */
@:allow(dragonBones) @:final class Armature extends BaseObject implements IAnimateble
{
	private static function _onSortSlots(a:Slot, b:Slot):Int 
	{
		return a._zOrder > b._zOrder ? 1 : -1;
	}
	/**
	 * @language zh_CN
	 * 是否继承父骨架的动画状态。
	 * @default true
	 * @version DragonBones 4.5
	 */
	public var inheritAnimation:Bool;
	/**
	 * @private
	 */
	private var debugDraw:Bool;
	/**
	 * @language zh_CN
	 * 用于存储临时数据。
	 * @version DragonBones 3.0
	 */
	public var userData:Dynamic;
	
	private var _debugDraw:Bool;
	private var _delayDispose:Bool;
	private var _lockDispose:Bool;
	/**
	 * @private
	 */
	private var _bonesDirty:Bool;
	private var _slotsDirty:Bool;
	private var _zOrderDirty:Bool;
	private var _bones:Vector<Bone> = new Vector<Bone>();
	private var _slots:Vector<Slot> = new Vector<Slot>();
	private var _actions:Vector<ActionData> = new Vector<ActionData>();
	private var _events:Vector<EventObject> = new Vector<EventObject>();
	/**
	 * @private
	 */
	private var _armatureData:ArmatureData;
	/**
	 * @private
	 */
	private var _skinData:SkinData;
	private var _animation:Animation;
	private var _proxy:IArmatureProxy;
	private var _display:Dynamic;
	private var _eventManager:IEventDispatcher;
	/**
	 * @private Slot
	 */
	private var _parent:Slot;
	private var _clock:WorldClock;
	/**
	 * @private
	 */
	private var _replaceTextureAtlasData:TextureAtlasData;
	private var _replacedTexture:Dynamic;
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
		var l = _bones.length;
		for (i in 0...l)
		{
			_bones[i].returnToPool();
		}
		
		l = _slots.length;
		for (i in 0...l)
		{
			_slots[i].returnToPool();
		}
		
		l = _events.length;
		for (i in 0...l)
		{
			_events[i].returnToPool();
		}
		
		if (_clock != null) 
		{
			_clock.remove(this);
		}
		
		if (_proxy != null) 
		{
			_proxy._onClear();
		}
		
		if (_replaceTextureAtlasData != null) 
		{
			_replaceTextureAtlasData.returnToPool();
		}
		
		if (_animation != null) 
		{
			_animation.returnToPool();
		}
		
		inheritAnimation = true;
		debugDraw = false;
		userData = null;
		
		_debugDraw = false;
		_delayDispose = false;
		_lockDispose = false;
		_bonesDirty = false;
		_slotsDirty = false;
		_zOrderDirty = false;
		_bones.fixed = false;
		_bones.length = 0;
		_slots.fixed = false;
		_slots.length = 0;
		_actions.length = 0;
		_events.length = 0;
		_armatureData = null;
		_skinData = null;
		_animation = null;
		_proxy = null;
		_display = null;
		_eventManager = null;
		_parent = null;
		_clock = null;
		_replaceTextureAtlasData = null;
		_replacedTexture = null;
	}
	
	private function _sortBones():Void
	{
		var total:UInt = _bones.length;
		if (total <= 0)
		{
			return;
		}
		
		var sortHelper:Vector<Bone> = _bones.concat();
		var index:UInt = 0;
		var count:UInt = 0;
		
		_bones.length = 0;
		var bone:Bone;
		
		while(count < total)
		{
			bone = sortHelper[index++];
			
			if (index >= total)
			{
				index = 0;
			}
			
			if (_bones.indexOf(bone) >= 0)
			{
				continue;
			}
			
			if (bone.parent != null && _bones.indexOf(bone.parent) < 0)
			{
				continue;
			}
			
			if (bone._ik != null && _bones.indexOf(bone._ik) < 0)
			{
				continue;
			}
			
			if (bone._ik != null && bone._ikChain > 0 && bone._ikChainIndex == bone._ikChain)
			{
				_bones.insertAt(_bones.indexOf(bone.parent) + 1, bone); // ik, parent, bone, children
				//_bones.splice(_bones.indexOf(bone.parent) + 1, 0, bone); // ik, parent, bone, children
			}
			else
			{
				_bones.push(bone);
			}
			
			count++;
		}
	}
	
	private function _sortSlots():Void
	{
		_slots.sort(_onSortSlots);
	}
	
	private function _doAction(value:ActionData):Void
	{
		switch (value.type) 
		{
			case ActionType.Play:
				_animation.playConfig(value.animationConfig);
			
			default:
		}
	}
	/**
	 * @private
	 */
	private function _init(
		armatureData: ArmatureData, skinData: SkinData,
		display:Dynamic, proxy: IArmatureProxy, eventManager: IEventDispatcher
	):Void 
	{
		if (_armatureData != null) 
		{
			return;
		}
		
		_armatureData = armatureData;
		_skinData = skinData;
		_animation = cast BaseObject.borrowObject(Animation);
		_proxy = proxy;
		_display = display;
		_eventManager = eventManager;
		
		_animation._init(this);
		_animation.animations = _armatureData.animations;
	}
	/**
	 * @private
	 */
	private function _addBoneToBoneList(value:Bone):Void
	{
		if (_bones.indexOf(value) < 0)
		{
			_bones.fixed = false;
			
			_bonesDirty = true;
			_bones.push(value);
			_animation._timelineStateDirty = true;
		}
	}
	/**
	 * @private
	 */
	private function _removeBoneFromBoneList(value: Bone):Void 
	{
		var index:Int = _bones.indexOf(value);
		if (index >= 0) 
		{
			_bones.fixed = false;
			
			_bones.splice(index, 1);
			_animation._timelineStateDirty = true;
			
			_bones.fixed = true;
		}
	}
	/**
	 * @private
	 */
	private function _addSlotToSlotList(value:Slot):Void
	{
		if (_slots.indexOf(value) < 0)
		{
			_slots.fixed = false;
			
			_slotsDirty = true;
			_slots.push(value);
			_animation._timelineStateDirty = true;
		}
	}
	/**
	 * @internal
	 * @private
	 */
	private function _removeSlotFromSlotList(value: Slot):Void 
	{
		var index:Int = _slots.indexOf(value);
		if (index >= 0) 
		{
			_slots.fixed = false;
			
			_slots.splice(index, 1);
			_animation._timelineStateDirty = true;
			
			_slots.fixed = true;
		}
	}
	/**
	 * @private
	 */
	private function _sortZOrder(slotIndices: Vector<Int>):Void 
	{
		var sortedSlots:Vector<SlotData> = _armatureData.sortedSlots;
		var isOriginal:Bool = slotIndices == null || slotIndices.length < 1;
		
		var l, slotIndex:Int, slotData:SlotData, slot:Slot;
		
		if (_zOrderDirty || !isOriginal)
		{
			l = sortedSlots.length;
			for (i in 0...l)
			{
				slotIndex = isOriginal? i: slotIndices[i];
				slotData = sortedSlots[slotIndex];
				
				if (slotData != null)
				{
					slot = getSlot(slotData.name);
					if (slot != null) 
					{
						slot._setZorder(i);
					}
				}
			}
			
			_slotsDirty = true;
			_zOrderDirty = !isOriginal;
		}
	}
	/**
	 * @private
	 */
	private function _bufferAction(value:ActionData):Void
	{
		_actions.push(value);
	}
	/**
	 * @private
	 */
	private function _bufferEvent(value:EventObject, type:String):Void
	{
		value.type = type;
		value.armature = this;
		_events.push(value);
	}
	/**
	 * @language zh_CN
     * 释放骨架。 (回收到对象池)
	 * @version DragonBones 3.0
	 */
	public function dispose():Void
	{
		_delayDispose = true;
		
		if (!_lockDispose && _armatureData != null)
		{
			returnToPool();
		}
	}
	/**
	 * @language zh_CN
	 * 更新骨架和动画。
     * @param passedTime 两帧之间的时间间隔。 (以秒为单位)
	 * @see dragonBones.animation.IAnimateble
	 * @see dragonBones.animation.WorldClock
	 * @version DragonBones 3.0
	 */
	public function advanceTime(passedTime:Float):Void
	{
		if (_armatureData == null)
		{
			throw new Error("The armature has been disposed.");
		}
		else if (_armatureData.parent == null)
		{
			throw new Error("The armature data has been disposed.");
		}
		
		// Sort bones and slots.
		if (_bonesDirty)
		{
			_bonesDirty = false;
			_sortBones();
			_bones.fixed = true;
		}
		
		if (_slotsDirty)
		{
			_slotsDirty = false;
			_sortSlots();
			_slots.fixed = true;
		}
		
		var prevCacheFrameIndex:Int = _animation._cacheFrameIndex;
		
		// Update nimation.
		_animation._advanceTime(passedTime);
		
		var currentCacheFrameIndex:Int = _animation._cacheFrameIndex;
		
		var l:UInt = 0;
		
		// Update bones and slots.
		if (currentCacheFrameIndex < 0 || currentCacheFrameIndex != prevCacheFrameIndex) 
		{
			l = _bones.length;
			for (i in 0...l)
			{
				_bones[i]._update(currentCacheFrameIndex);
			}
			
			l = _slots.length;
			for (i in 0...l)
			{
				_slots[i]._update(currentCacheFrameIndex);
			}
		}
		
		// 
		var drawed:Bool = debugDraw || DragonBones.debugDraw;
		if (drawed || _debugDraw) 
		{
			_debugDraw = drawed;
			_proxy._debugDraw(_debugDraw);
		}
		
		if (!_lockDispose)
		{
			_lockDispose = true;
			
			// Events. (Dispatch event before action.)
			l = _events.length;
			if (l > 0) 
			{
				var eventObject:EventObject;
				for (i in 0...l) 
				{
					eventObject = _events[i];
					@:privateAccess _proxy._dispatchEvent(eventObject.type, eventObject);
					
					if (eventObject.type == EventObject.SOUND_EVENT)
					{
						_eventManager._dispatchEvent(eventObject.type, eventObject);
					}
					
					eventObject.returnToPool();
				}
				
				_events.length = 0;
			}
			
			// Actions.
			l = _actions.length;
			if (l > 0) 
			{
				var action:ActionData, slot:Slot, childArmature:Armature, lA:UInt;
				for (i in 0...l) 
				{
					action = _actions[i];
					if (action.slot != null) 
					{
						slot = getSlot(action.slot.name);
						if (slot != null) 
						{
							childArmature = slot.childArmature;
							if (childArmature != null) 
							{
								childArmature._doAction(action);
							}
						}
					} 
					else if (action.bone != null) 
					{
						lA = _slots.length;
						for (iA in 0...lA)
						{
							childArmature = _slots[iA].childArmature;
							if (childArmature != null) 
							{
								childArmature._doAction(action);
							}
						}
					} 
					else 
					{
						_doAction(action);
					}
				}
				
				_actions.length = 0;
			}
			
			_lockDispose = false;
		}
		
		if (_delayDispose)
		{
			returnToPool();
		}
	}
	/**
	 * @language zh_CN
	 * 更新骨骼和插槽。 (当骨骼没有动画状态或动画状态播放完成时，骨骼将不在更新)
	 * @param boneName 指定的骨骼名称，如果未设置，将更新所有骨骼。
	 * @param updateSlotDisplay 是否更新插槽的显示对象。
	 * @see dragonBones.Bone
	 * @see dragonBones.Slot
	 * @version DragonBones 3.0
	 */
	public function invalidUpdate(boneName:String = null, updateSlotDisplay:Bool = false):Void
	{
		if (boneName != null)
		{
			var bone:Bone = getBone(boneName);
			if (bone != null)
			{
				bone.invalidUpdate();
				
				if (updateSlotDisplay)
				{
					var l:UInt = _slots.length;
					var slot:Slot;
					for (i in 0...l)
					{
						slot = _slots[i];
						if (slot.parent == bone)
						{
							slot.invalidUpdate();
						}
					}
				}
			}
		}
		else
		{
			var l:UInt = _bones.length;
			for (i in 0...l)
			{
				_bones[i].invalidUpdate();
			}
			
			if (updateSlotDisplay) 
			{
				l = _slots.length;
				for (i in 0...l)
				{
					_slots[i].invalidUpdate();
				}
			}
		}
	}
	/**
	 * @language zh_CN
     * 判断点是否在所有插槽的自定义包围盒内。
	 * @param x 点的水平坐标。（骨架内坐标系）
	 * @param y 点的垂直坐标。（骨架内坐标系）
	 * @version DragonBones 5.0
	 */
	public function containsPoint(x:Float, y:Float):Slot 
	{
		var l:UInt = _slots.length;
		var slot:Slot;
		for (i in 0...l)
		{
			slot = _slots[i];
			if (slot.containsPoint(x, y)) 
			{
				return slot;
			}
		}
		
		return null;
	}
	/**
	 * @language zh_CN
     * 判断线段是否与骨架的所有插槽的自定义包围盒相交。
	 * @param xA 线段起点的水平坐标。（骨架内坐标系）
	 * @param yA 线段起点的垂直坐标。（骨架内坐标系）
	 * @param xB 线段终点的水平坐标。（骨架内坐标系）
	 * @param yB 线段终点的垂直坐标。（骨架内坐标系）
	 * @param intersectionPointA 线段从起点到终点与包围盒相交的第一个交点。（骨架内坐标系）
	 * @param intersectionPointB 线段从终点到起点与包围盒相交的第一个交点。（骨架内坐标系）
	 * @param normalRadians 碰撞点处包围盒切线的法线弧度。 [x: 第一个碰撞点处切线的法线弧度, y: 第二个碰撞点处切线的法线弧度]
	 * @returns 线段从起点到终点相交的第一个自定义包围盒的插槽。
	 * @version DragonBones 5.0
	 */
	public function intersectsSegment(
		xA:Float, yA:Float, xB:Float, yB:Float,
		intersectionPointA:Point = null,
		intersectionPointB:Point = null,
		normalRadians:Point = null
	):Slot 
	{
		var isV:Bool = xA == xB;
		var dMin:Float = 0.0;
		var dMax:Float = 0.0;
		var intXA:Float = 0.0;
		var intYA:Float = 0.0;
		var intXB:Float = 0.0;
		var intYB:Float = 0.0;
		var intAN:Float = 0.0;
		var intBN:Float = 0.0;
		var intSlotA:Slot = null;
		var intSlotB:Slot = null;
		
		var l:UInt = _slots.length;
		var slot:Slot, intersectionCount:Int, d:Float;
		for (i in 0...l)
		{
			slot = _slots[i];
			intersectionCount = slot.intersectsSegment(xA, yA, xB, yB, intersectionPointA, intersectionPointB, normalRadians);
			if (intersectionCount > 0) 
			{
				if (intersectionPointA != null || intersectionPointB != null) 
				{
					if (intersectionPointA != null) 
					{
						d = isV ? intersectionPointA.y - yA : intersectionPointA.x - xA;
						if (d < 0.0) 
						{
							d = -d;
						}
						
						if (intSlotA == null || d < dMin) 
						{
							dMin = d;
							intXA = intersectionPointA.x;
							intYA = intersectionPointA.y;
							intSlotA = slot;
							
							if (normalRadians != null) 
							{
								intAN = normalRadians.x;
							}
						}
					}
					
					if (intersectionPointB != null) 
					{
						d = intersectionPointB.x - xA;
						if (d < 0.0) 
						{
							d = -d;
						}
						
						if (intSlotB == null || d > dMax) 
						{
							dMax = d;
							intXB = intersectionPointB.x;
							intYB = intersectionPointB.y;
							intSlotB = slot;
							
							if (normalRadians != null) 
							{
								intBN = normalRadians.y;
							}
						}
					}
				}
				else 
				{
					intSlotA = slot;
					break;
				}
			}
		}
		
		if (intSlotA != null && intersectionPointA != null) 
		{
			intersectionPointA.x = intXA;
			intersectionPointA.y = intYA;
			
			if (normalRadians != null) 
			{
				normalRadians.x = intAN;
			}
		}
		
		if (intSlotB != null && intersectionPointB != null) 
		{
			intersectionPointB.x = intXB;
			intersectionPointB.y = intYB;
			
			if (normalRadians != null) 
			{
				normalRadians.y = intBN;
			}
		}
		
		return intSlotA;
	}
	/**
	 * @language zh_CN
     * 获取骨骼。
	 * @param name 骨骼的名称。
	 * @return 骨骼。
	 * @see dragonBones.Bone
	 * @version DragonBones 3.0
	 */
	public function getBone(name:String):Bone
	{
		var l:UInt = _bones.length;
		var bone:Bone;
		for (i in 0...l)
		{
			bone = _bones[i];
			if (bone.name == name) 
			{
				return bone;
			}
		}
		
		return null;
	}
	/**
	 * @language zh_CN
	 * 通过显示对象获取骨骼。
	 * @param display 显示对象。
	 * @return 包含这个显示对象的骨骼。
	 * @see dragonBones.Bone
	 * @version DragonBones 3.0
	 */
	public function getBoneByDisplay(display:Dynamic):Bone
	{
		var slot:Slot = getSlotByDisplay(display);
		
		return slot != null? slot.parent: null;
	}
	/**
	 * @language zh_CN
     * 获取插槽。
	 * @param name 插槽的名称。
	 * @return 插槽。
	 * @see dragonBones.Slot
	 * @version DragonBones 3.0
	 */
	public function getSlot(name:String):Slot
	{
		var l:UInt = _slots.length;
		var slot:Slot;
		for (i in 0...l)
		{
			slot = _slots[i];
			if (slot.name == name) 
			{
				return slot;
			}
		}
		
		return null;
	}
	/**
	 * @language zh_CN
	 * 通过显示对象获取插槽。
	 * @param display 显示对象。
	 * @return 包含这个显示对象的插槽。
	 * @see dragonBones.Slot
	 * @version DragonBones 3.0
	 */
	public function getSlotByDisplay(display:Dynamic):Slot
	{
		if (display != null)
		{
			var l:UInt = _slots.length;
			var slot:Slot;
			for (i in 0...l)
			{
				slot = _slots[i];
				if (slot.display == display)
				{
					return slot;
				}
			}
		}
		
		return null;
	}
	/**
	 * @private
	 */
	private function _addBone(value:Bone, parentName:String = null):Void
	{
		if (value != null)
		{
			value._setArmature(this);
			value._setParent(parentName != null? getBone(parentName): null);
		}
	}
	/**
	 * @private
	 */
	private function _addSlot(value:Slot, parentName:String):Void
	{
		var bone:Bone = getBone(parentName);
		if (bone != null)
		{
			value._setArmature(this);
			value._setParent(bone);
		}
	}
	/**
     * @language zh_CN
     * 替换骨架的主贴图，根据渲染引擎的不同，提供不同的贴图类型。
     * @param texture 贴图。
	 * @version DragonBones 4.5
	 */
	public function replaceTexture(texture:Dynamic):Void
	{
		replacedTexture = texture;
	}
	/**
	 * @language zh_CN
	 * 获取所有骨骼。
	 * @see dragonBones.Bone
	 * @version DragonBones 3.0
	 */
	public function getBones():Vector<Bone>
	{
		return _bones;
	}
	/**
	 * @language zh_CN
	 * 获取所有插槽。
	 * @see dragonBones.Slot
	 * @version DragonBones 3.0
	 */
	public function getSlots():Vector<Slot>
	{
		return _slots;
	}
	/**
	 * @language zh_CN
	 * 骨架名称。
	 * @see dragonBones.objects.ArmatureData#name
	 * @version DragonBones 3.0
	 */
	public var name(get, never):String;
	private function get_name():String
	{
		return _armatureData != null? _armatureData.name: null;
	}
	/**
	 * @language zh_CN
	 * 获取骨架数据。
	 * @see dragonBones.objects.ArmatureData
	 * @version DragonBones 4.5
	 */
	public var armatureData(get, never):ArmatureData;
	private function get_armatureData():ArmatureData
	{
		return _armatureData;
	}
	/**
	 * @language zh_CN
	 * 获取动画控制器。
	 * @see dragonBones.animation.Animation
	 * @version DragonBones 3.0
	 */
	public var animation(get, never):Animation;
	private function get_animation():Animation	
	{
		return _animation;
	}
	/**
	 * @language zh_CN
	 * 获取事件监听器。
	 * @version DragonBones 5.0
	 */
	public var eventDispatcher(get, never):IEventDispatcher;
	private function get_eventDispatcher():IEventDispatcher
	{
		return _proxy;
	}
	/**
	 * @language zh_CN
	 * 获取显示容器，插槽的显示对象都会以此显示容器为父级，根据渲染平台的不同，类型会不同，通常是 DisplayObjectContainer 类型。
	 * @version DragonBones 3.0
	 */
	public var display(get, never):Dynamic;
	private function get_display():Dynamic
	{
		return _display;
	}
	/**
	 * @language zh_CN
	 * 获取父插槽。 (当此骨架是某个骨架的子骨架时，可以通过此属性向上查找从属关系)
	 * @see dragonBones.Slot
	 * @version DragonBones 4.5
	 */
	public var parent(get, never):Slot;
	private function get_parent():Slot
	{
		return _parent;
	}
	/**
	 * @language zh_CN
     * 动画缓存帧率，当设置的值大于 0 的时，将会开启动画缓存。
	 * 通过将动画数据缓存在内存中来提高运行性能，会有一定的内存开销。
	 * 帧率不宜设置的过高，通常跟动画的帧率相当且低于程序运行的帧率。
	 * 开启动画缓存后，某些功能将会失效，比如 Bone 和 Slot 的 offset 属性等。
	 * @see dragonBones.objects.DragonBonesData#frameRate
	 * @see dragonBones.objects.ArmatureData#frameRate
	 * @version DragonBones 4.5
	 */
	public var cacheFrameRate(get, set):UInt;
	private function get_cacheFrameRate():UInt
	{
		return _armatureData.cacheFrameRate;
	}
	private function set_cacheFrameRate(value:UInt):UInt
	{
		if (_armatureData.cacheFrameRate != value)
		{
			_armatureData.cacheFrames(value);
			
			// Set child armature frameRate.
			var l:UInt = _slots.length;
			var childArmature:Armature;
			for (i in 0...l)
			{
				childArmature = _slots[i].childArmature;
				if (childArmature != null) 
				{
					childArmature.cacheFrameRate = value;
				}
			}
		}
		return value;
	}
	/**
	 * @inheritDoc
	 */
	public var clock(get, set):WorldClock;
	private function get_clock():WorldClock 
	{
		return _clock;
	}
	private function set_clock(value:WorldClock):WorldClock
	{
		if (_clock == value) 
		{
			return value;
		}
		
		var prevClock:WorldClock = _clock;
		_clock = value;
		
		if (prevClock != null) 
		{
			prevClock.remove(this);
		}
		
		if (_clock != null) 
		{
			_clock.add(this);
		}
		
		// Update childArmature clock.
		var l:UInt = _slots.length;
		var childArmature:Armature;
		for (i in 0...l)
		{
			childArmature = _slots[i].childArmature;
			if (childArmature != null) 
			{
				childArmature.clock = _clock;
			}
		}
		return value;
	}
	/**
	 * @language zh_CN
	 * 替换骨架的主贴图，根据渲染引擎的不同，提供不同的贴图数据。
	 * @version DragonBones 4.5
	 */
	public var replacedTexture(get, set):Dynamic;
	private function get_replacedTexture():Dynamic 
	{
		return _replacedTexture;
	}
	private function set_replacedTexture(value:Dynamic):Dynamic
	{
		if (_replacedTexture == value)
		{
			return value;
		}
		
		if (_replaceTextureAtlasData != null) 
		{
			_replaceTextureAtlasData.returnToPool();
			_replaceTextureAtlasData = null;
		}
		
		_replacedTexture = value;
		
		var l:UInt = _slots.length;
		var slot:Slot;
		for (i in 0...l)
		{
			slot = _slots[i];
			slot.invalidUpdate();
			slot._update(-1);
		}
		
		return value;
	}
	
	/**
	 * @deprecated
	 * @see dragonBones.Armature#eventDispatcher
	 */
	public function hasEventListener(type:String):Void
	{
		_display.hasEvent(type);
	}
	/**
	 * @deprecated
	 * @see dragonBones.Armature#eventDispatcher
	 */
	public function addEventListener(type:String, listener:Function):Void
	{
		_display.addEvent(type, listener);
	}
	/**
	 * @deprecated
	 * @see dragonBones.Armature#eventDispatcher
	 */
	public function removeEventListener(type:String, listener:Function):Void
	{
		_display.removeEvent(type, listener);
	}
}