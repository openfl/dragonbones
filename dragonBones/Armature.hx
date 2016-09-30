package dragonBones;
import openfl.events.Event;


//import flash.events.Event;
import flash.events.EventDispatcher;

import dragonBones.animation.Animation;
import dragonBones.animation.AnimationState;
import dragonBones.animation.IAnimatable;
import dragonBones.animation.TimelineState;
import dragonBones.core.DBObject;
import dragonBones.events.ArmatureEvent;
import dragonBones.events.FrameEvent;
import dragonBones.events.SoundEvent;
import dragonBones.events.SoundEventManager;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.Frame;

//use namespace dragonBones_internal;

/**
 * Dispatched when slot's zOrder changed
 */
//[Event(name="zOrderUpdated", type="dragonBones.events.ArmatureEvent")]

/**
 * Dispatched when an animation state begins fade in (Even if fade in time is 0)
 */
//[Event(name="fadeIn", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when an animation state begins fade out (Even if fade out time is 0)
 */
//[Event(name="fadeOut", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when an animation state start to play(AnimationState may play when fade in start or end. It is controllable).
 */
//[Event(name="start", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when an animation state play complete (if playtimes equals to 0 means loop forever. Then this Event will not be triggered)
 */
//[Event(name="complete", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when an animation state complete a loop.
 */
//[Event(name="loopComplete", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when an animation state fade in complete.
 */
//[Event(name="fadeInComplete", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when an animation state fade out complete.
 */
//[Event(name="fadeOutComplete", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when an animation state enter a frame with animation frame event.
 */
//[Event(name="animationFrameEvent", type="dragonBones.events.FrameEvent")]

/**
 * Dispatched when an bone enter a frame with animation frame event.
 */
//[Event(name="boneFrameEvent", type="dragonBones.events.FrameEvent")]

typedef LevelBone = {
    var level:Int;
    var bone:Bone;
};

class Armature extends EventDispatcher implements IAnimatable
{
	/**
	 * The instance dispatch sound event.
	 */
	private static var _soundManager:SoundEventManager = SoundEventManager.getInstance();

	/**
	 * The name should be same with ArmatureData's name
	 */
	public var name:String;

	/**
	 * An object that can contain any user extra data.
	 */
	public var userData:Dynamic;

	/** @private Set it to true when slot's zorder changed*/
	public var _slotsZOrderChanged:Bool;

	/** @private Store event needed to dispatch in current frame. When advanceTime execute complete, dispath them.*/
	public var _eventList:Array<Event>;


	/** @private Store slots based on slots' zOrder*/
	public var _slotList:Array<Slot>;

	/** @private Store bones based on bones' hierarchy (From root to leaf)*/
	public var _boneList:Array<Bone>;

	private var _delayDispose:Bool;
	private var _lockDispose:Bool;

	/** @private */
	public var _armatureData:ArmatureData;
	/**
	 * ArmatureData.
	 * @see dragonBones.objects.ArmatureData.
	 */
    public var armatureData(get, null):ArmatureData;
	public function get_armatureData():ArmatureData
	{
		return _armatureData;
	}

	/** @private */
	public var _display:Dynamic;
	/**
	 * Armature's display object. It's instance type depends on render engine. For example "flash.display.DisplayObject" or "startling.display.DisplayObject"
	 */
    public var display(get, null):Dynamic;
	public function get_display():Dynamic
	{
		return _display;
	}

	/** @private */
	public var _animation:Animation;
	/**
	 * An Animation instance
	 * @see dragonBones.animation.Animation
	 */
    public var animation(get, null):Animation;
	public function get_animation():Animation
	{
		return _animation;
	}

	/** @private */
	public var _cacheFrameRate:Int;
	public var cacheFrameRate(get, set):Int;
	public function get_cacheFrameRate():Int
	{
		return _cacheFrameRate;
	}
	public function set_cacheFrameRate(value:Int):Int
	{
		if(_cacheFrameRate == value)
		{
			return value;
		}
		_cacheFrameRate = value;

		return value;
	}

	/**
	 * Creates a Armature blank instance.
	 * @param Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
	 * @see #display
	 */
	public function new(display:Dynamic)
	{
		super(this);
		_display = display;

		_animation = new Animation(this);

		_slotsZOrderChanged = false;

		_slotList = new Array<Slot>();
		_boneList = new Array<Bone>();
		_eventList = new Array<Event>();

		_delayDispose = false;
		_lockDispose = false;

		_armatureData = null;

		_cacheFrameRate = 0;
	}

	/**
	 * Cleans up any resources used by this instance.
	 */
	public function dispose():Void
	{
		_delayDispose = true;
		if(_animation == null || _lockDispose)
		{
			return;
		}

		userData = null;

		_animation.dispose();
		var i:Int = _slotList.length;
		while(i -- > 0)
		{
			_slotList[i].dispose();
		}
		i = _boneList.length;
		while(i -- > 0)
		{
			_boneList[i].dispose();
		}

		_armatureData = null;
		_animation = null;
		_slotList = null;
		_boneList = null;
		_eventList = null;

		//_display = null;
	}

	/**
	 * Force update bones and slots. (When bone's animation play complete, it will not update)
	 */
	public function invalidUpdate(boneName:String = null):Void
	{
		if(boneName != null)
		{
			var bone:Bone = getBone(boneName);
			if(bone != null)
			{
				bone.invalidUpdate();
			}
		}
		else
		{
			var i:Int = _boneList.length;
			while(i -- > 0)
			{
				_boneList[i].invalidUpdate();
			}
		}
	}

	/**
	 * Update the animation using this method typically in an ENTERFRAME Event or with a Timer.
	 * @param The amount of second to move the playhead ahead.
	 */
	public function advanceTime(passedTime:Float):Void
	{
		_lockDispose = true;

		_animation.advanceTime(passedTime);

		passedTime *= _animation.timeScale;    //_animation's time scale will impact childArmature

		var isFading:Bool = _animation._isFading;
		var i:Int = _boneList.length;
		while(i -- > 0)
		{
			var bone:Bone = _boneList[i];
			bone.update(isFading);
		}

		i = _slotList.length;
		while(i -- > 0)
		{
			var slot:Slot = _slotList[i];
			slot.update();
			if(slot._isShowDisplay)
			{
				var childArmature:Armature = slot.childArmature;
				if(childArmature != null)
				{
					childArmature.advanceTime(passedTime);
				}
			}
		}

		if(_slotsZOrderChanged)
		{
			updateSlotsZOrder();

			if(this.hasEventListener(ArmatureEvent.Z_ORDER_UPDATED))
			{
				this.dispatchEvent(new ArmatureEvent(ArmatureEvent.Z_ORDER_UPDATED));
			}
		}

		if(_eventList.length != 0)
		{
			for (event in _eventList)
			{
				this.dispatchEvent(event);
			}
			_eventList = new Array<Event>();
		}

		_lockDispose = false;
		if(_delayDispose)
		{
			dispose();
		}
	}

	/**
	 * Get all Slot instance associated with this armature.
	 * @param if return Vector copy
	 * @return A Vector.&lt;Slot&gt; instance.
	 * @see dragonBones.Slot
	 */
	public function getSlots(returnCopy:Bool = true):Array<Slot>
	{
		return returnCopy?_slotList.copy():_slotList;
	}

	/**
	 * Retrieves a Slot by name
	 * @param The name of the Bone to retrieve.
	 * @return A Slot instance or null if no Slot with that name exist.
	 * @see dragonBones.Slot
	 */
	public function getSlot(slotName:String):Slot
	{
		for (slot in _slotList)
		{
			if(slot.name == slotName)
			{
				return slot;
			}
		}
		return null;
	}

	/**
	 * Gets the Slot associated with this DisplayObject.
	 * @param Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
	 * @return A Slot instance or null if no Slot with that DisplayObject exist.
	 * @see dragonBones.Slot
	 */
	public function getSlotByDisplay(display:Dynamic):Slot
	{
		if(display != null)
		{
			for (slot in _slotList)
			{
				if(slot.display == display)
				{
					return slot;
				}
			}
		}
		return null;
	}

	/**
	 * Add a slot to a bone as child.
	 * @param slot A Slot instance
	 * @param boneName bone name
	 * @see dragonBones.core.DBObject
	 */
	public function addSlot(slot:Slot, boneName:String):Void
	{
		var bone:Bone = getBone(boneName);
		if (bone != null)
		{
			bone.addChild(slot);
		}
		else
		{
			throw "ArgumentError";
		}
	}

	/**
	 * Remove a Slot instance from this Armature instance.
	 * @param The Slot instance to remove.
	 * @see dragonBones.Slot
	 */
	public function removeSlot(slot:Slot):Void
	{
		if(slot != null || slot.armature != this)
		{
			throw "ArgumentError";
		}

		slot.parent.removeChild(slot);
	}

	/**
	 * Remove a Slot instance from this Armature instance.
	 * @param The name of the Slot instance to remove.
	 * @see dragonBones.Slot
	 */
	public function removeSlotByName(slotName:String):Slot
	{
		var slot:Slot = getSlot(slotName);
		if(slot != null)
		{
			removeSlot(slot);
		}
		return slot;
	}

	/**
	 * Get all Bone instance associated with this armature.
	 * @param if return Vector copy
	 * @return A Vector.&lt;Bone&gt; instance.
	 * @see dragonBones.Bone
	 */
	public function getBones(returnCopy:Bool = true):Array<Bone>
	{
		return returnCopy?_boneList.copy():_boneList;
	}

	/**
	 * Retrieves a Bone by name
	 * @param The name of the Bone to retrieve.
	 * @return A Bone instance or null if no Bone with that name exist.
	 * @see dragonBones.Bone
	 */
	public function getBone(boneName:String):Bone
	{
		for (bone in _boneList)
		{
			if(bone.name == boneName)
			{
				return bone;
			}
		}
		return null;
	}

	/**
	 * Gets the Bone associated with this DisplayObject.
	 * @param Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
	 * @return A Bone instance or null if no Bone with that DisplayObject exist..
	 * @see dragonBones.Bone
	 */
	public function getBoneByDisplay(display:Dynamic):Bone
	{
		var slot:Slot = getSlotByDisplay(display);
		return slot != null ?slot.parent:null;
	}

	/**
	 * Add a Bone instance to this Armature instance.
	 * @param A Bone instance.
	 * @param (optional) The parent's name of this Bone instance.
	 * @see dragonBones.Bone
	 */
	public function addBone(bone:Bone, parentName:String = null):Void
	{
		if(parentName != null)
		{
			var boneParent:Bone = getBone(parentName);
			if (boneParent != null)
			{
				boneParent.addChild(bone);
			}
			else
			{
				throw "ArgumentError";
			}
		}
		else
		{
			if(bone.parent != null)
			{
				bone.parent.removeChild(bone);
			}
			bone.setArmature(this);
		}
	}

	/**
	 * Remove a Bone instance from this Armature instance.
	 * @param The Bone instance to remove.
	 * @see	dragonBones.Bone
	 */
	public function removeBone(bone:Bone):Void
	{
		if(bone == null || bone.armature != this)
		{
			throw "ArgumentError";
		}

		if(bone.parent != null)
		{
			bone.parent.removeChild(bone);
		}
		else
		{
			bone.setArmature(null);
		}

	}

	/**
	 * Remove a Bone instance from this Armature instance.
	 * @param The name of the Bone instance to remove.
	 * @see dragonBones.Bone
	 */
	public function removeBoneByName(boneName:String):Bone
	{
		var bone:Bone = getBone(boneName);
		if(bone != null)
		{
			removeBone(bone);
		}
		return bone;
	}

	/** @private */
	public function addDBObject(object:DBObject):Void
	{
		if(Std.is(object, Slot))
		{
			var slot:Slot = cast(object, Slot);
			if(_slotList.indexOf(slot) < 0)
			{
				_slotList.push(slot);
			}
		}
		else if(Std.is(object, Bone))
		{
			var bone:Bone = cast(object, Bone);
			if(_boneList.indexOf(bone) < 0)
			{
				_boneList.push(bone);
				sortBoneList();
				_animation.updateAnimationStates();
			}
		}
	}

	/** @private */
	public function removeDBObject(object:DBObject):Void
	{
		var index:Int;
		if(Std.is(object, Slot))
		{
			var slot:Slot = cast(object, Slot);
			index = _slotList.indexOf(slot);
			if(index >= 0)
			{
				_slotList.splice(index, 1);
			}
		}
		else if(Std.is(object, Bone))
		{
			var bone:Bone = cast(object, Bone);
			index = _boneList.indexOf(bone);
			if(index >= 0)
			{
				_boneList.splice(index, 1);
				_animation.updateAnimationStates();
			}
		}
	}

	/**
	 * Sort all slots based on zOrder
	 */
	public function updateSlotsZOrder():Void
	{
		haxe.ds.ArraySort.sort(_slotList, sortSlot);
		var i:Int = _slotList.length;
		while(i -- > 0)
		{
			var slot:Slot = _slotList[i];
			if(slot._isShowDisplay)
			{
				slot.addDisplayToContainer(_display);
			}
		}

		_slotsZOrderChanged = false;
	}

	private function sortBoneList():Void
	{
		return;
		var i:Int = _boneList.length;
		if(i == 0)
		{
			return;
		}
		var helpArray:Array<LevelBone> = new Array<LevelBone>();
		while(i -- > 0)
		{
			var level:Int = 0;
			var bone:Bone = _boneList[i];
			var boneParent:Bone = bone;
			while(boneParent != null)
			{
				level ++;
				boneParent = boneParent.parent;
			}
			helpArray[i] = {level: level, bone: bone};
		}

		//helpArray.sortOn("0", Array.NUMERIC|Array.DESCENDING);
        helpArray.sort(function (a, b):Int {
            return b.level - a.level;
        });

		i = helpArray.length;
		while(i -- > 0)
		{
			_boneList[i] = helpArray[i].bone;
		}

	}

	/** @private When AnimationState enter a key frame, call this func*/
	public function arriveAtFrame(frame:Frame, timelineState:TimelineState, animationState:AnimationState, isCross:Bool):Void
	{
		if(frame.event != null && this.hasEventListener(FrameEvent.ANIMATION_FRAME_EVENT))
		{
			var frameEvent:FrameEvent = new FrameEvent(FrameEvent.ANIMATION_FRAME_EVENT);
			frameEvent.animationState = animationState;
			frameEvent.frameLabel = frame.event;
			_eventList.push(frameEvent);
		}

		if(frame.sound != null && _soundManager.hasEventListener(SoundEvent.SOUND))
		{
			var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
			soundEvent.armature = this;
			soundEvent.animationState = animationState;
			soundEvent.sound = frame.sound;
			_soundManager.dispatchEvent(soundEvent);
		}

		//[TODO]currently there is only gotoAndPlay belongs to frame action. In future, there will be more.
		//后续会扩展更多的action，目前只有gotoAndPlay的含义
		if(frame.action != null)
		{
			if(animationState.displayControl)
			{
				animation.gotoAndPlay(frame.action);
			}
		}
	}

	private function sortSlot(slot1:Slot, slot2:Slot):Int
	{
		if (slot1 == null) {
			return -1;
		}
		if (slot2 == null) {
			return -1;
		}

		return slot1.zOrder < slot2.zOrder?1: -1;
	}

}

