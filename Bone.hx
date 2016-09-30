package dragonBones;

import dragonBones.animation.AnimationState;
import dragonBones.animation.TimelineState;
import dragonBones.core.DBObject;
import dragonBones.events.FrameEvent;
import dragonBones.events.SoundEvent;
import dragonBones.events.SoundEventManager;
import dragonBones.objects.DBTransform;
import dragonBones.objects.Frame;
import dragonBones.objects.FrameCached;
import dragonBones.objects.TimelineCached;
import dragonBones.objects.TransformFrame;
import dragonBones.utils.TransformUtil;

import openfl.geom.Matrix;
import openfl.geom.Point;

class Bone extends DBObject
{
	/**
	 * The instance dispatch sound event.
	 */
	private static var _soundManager:SoundEventManager = SoundEventManager.getInstance();


	/**
	 * Unrecommended API. Recommend use slot.childArmature.
	 */
    public var childArmature(get, null):Armature;
	public function get_childArmature():Armature
	{
		var slot:Slot = this.slot;
		if(slot != null)
		{
			return slot.childArmature;
		}
		return null;
	}

	/**
	 * Unrecommended API. Recommend use slot.display.
	 */
    public var display(get, set):Dynamic;
	public function get_display():Dynamic
	{
		var slot:Slot = this.slot;
		if(slot != null)
		{
			return slot.display;
		}
		return null;
	}
	public function set_display(value:Dynamic):Dynamic
	{
		var slot:Slot = this.slot;
		if(slot != null)
		{
			slot.display = value;
		}
		return value;
	}

	/**
	 * Unrecommended API. Recommend use offset.
	 */
    public var node(get, null):DBTransform;
	public function get_node():DBTransform
	{
		return _offset;
	}

	/**
	 * AnimationState that slots belong to the bone will be controlled by.
	 * Sometimes, we want slots controlled by a spedific animation state when animation is doing mix or addition.
	 */
	public var displayController:String;

	/** @private */
	public var _tween:DBTransform;

	/** @private */
	public var _tweenPivot:Point;

	/** @private */
	public var _needUpdate:Int;

	/** @private */
	public var _isColorChanged:Bool;

	/** @private */
	public var _frameCachedPosition:Int;

	/** @private */
	public var _frameCachedDuration:Int;

	/** @private */
	public var _timelineCached:TimelineCached;

	/** @private */
	public var _boneList:Array<Bone>;

	/** @private */
	public var _slotList:Array<Slot>;

	/** @private */
	public var _timelineStateList:Array<TimelineState>;

	private var _tempGlobalTransformForChild:DBTransform;
	public var _globalTransformForChild:DBTransform;
	private var _tempGlobalTransformMatrixForChild:Matrix;
	public var _globalTransformMatrixForChild:Matrix;

	public var applyOffsetTranslationToChild:Bool = true;
	public var applyOffsetRotationToChild:Bool = true;
	public var applyOffsetScaleToChild:Bool = false;

	/** @private */

	override public function set_visible(value:Bool):Bool
	{
		if(this._visible != value)
		{
			this._visible = value;
			for (slot in _slotList)
			{
				slot.updateDisplayVisible(this._visible);
			}
		}
		return value;
	}

	/** @private */
	override public function setArmature(value:Armature):Void
	{
		super.setArmature(value);

		var i:Int = _boneList.length;
		while(i -- > 0)
		{
			_boneList[i].setArmature(this._armature);
		}

		i = _slotList.length;
		while(i -- > 0)
		{
			_slotList[i].setArmature(this._armature);
		}
	}

	public var slot(get, null):Slot;
	public function get_slot():Slot
	{
		return _slotList.length > 0?_slotList[0]:null;
	}

	/**
	 * Creates a Bone blank instance.
	 */
	public function new()
	{
		super();

		_tween = new DBTransform();
		_tweenPivot = new Point();
		_tween.scaleX = _tween.scaleY = 1;

		_boneList = new Array<Bone>();
		_slotList = new Array<Slot>();
		_timelineStateList = new Array<TimelineState>();

		_needUpdate = 2;
		_isColorChanged = false;
		_frameCachedPosition = -1;
		_frameCachedDuration = -1;
	}

	/**
	 * @inheritDoc
	 */
	override public function dispose():Void
	{
		if(_boneList == null)
		{
			return;
		}

		super.dispose();
		var i:Int = _boneList.length;
		while(i -- > 0)
		{
			_boneList[i].dispose();
		}

		i = _slotList.length;
		while(i -- > 0)
		{
			_slotList[i].dispose();
		}

		_tween = null;
		_tweenPivot = null;
		_boneList = null;
		_slotList = null;
		_timelineStateList = null;
		_timelineCached = null;
	}

	/**
	 * Force update the bone in next frame even if the bone is not moving.
	 */
	public function invalidUpdate():Void
	{
		_needUpdate = 2;
	}

	/**
	 * If contains some bone or slot
	 * @param Slot or Bone instance
	 * @return Boolean
	 * @see dragonBones.core.DBObject
	 */
	public function contains(child:DBObject):Bool
	{
		if(child == null)
		{
			throw "ArgumentError";
		}
		if(child == this)
		{
			return false;
		}
		var ancestor:DBObject = child;
		while(!(ancestor == this || ancestor == null))
		{
			ancestor = ancestor.parent;
		}
		return ancestor == this;
	}

	/**
	 * Get all Bone instance associated with this bone.
	 * @return A Vector.&lt;Slot&gt; instance.
	 * @see dragonBones.Slot
	 */
	public function getBones(returnCopy:Bool = true):Array<Bone>
	{
		return returnCopy?_boneList.copy():_boneList;
	}

	/**
	 * Get all Slot instance associated with this bone.
	 * @return A Vector.&lt;Slot&gt; instance.
	 * @see dragonBones.Slot
	 */
	public function getSlots(returnCopy:Bool = true):Array<Slot>
	{
		return returnCopy?_slotList.copy():_slotList;
	}

	/**
	 * Add a bone or slot as child
	 * @param a Slot or Bone instance
	 * @see dragonBones.core.DBObject
	 */
	public function addChild(child:DBObject):Void
	{
		if(child == null)
		{
			throw "ArgumentError";
		}
		if(child.parent != null)
		{
			child.parent.removeChild(child);
		}

		if (Std.is(child, Bone)) {
			var bone:Bone = cast(child, Bone);
			if(bone == this || (bone != null && bone.contains(this)))
			{
				throw "An Bone cannot be added as a child to itself or one of its children (or children's children, etc.)";
			}

			if(bone != null)
			{
				_boneList.push(bone);
				bone.setParent(this);
				bone.setArmature(this._armature);
			}
		}
		else if(Std.is(child, Slot))
		{
			var slot:Slot = cast(child, Slot);
			_slotList.push(slot);
			slot.setParent(this);
			slot.setArmature(this._armature);
		}
	}

	/**
	 * remove a child bone or slot
	 * @param a Slot or Bone instance
	 * @see dragonBones.core.DBObject
	 */
	public function removeChild(child:DBObject):Void
	{
		if(child == null)
		{
			throw "ArgumentError";
		}

		var index:Int;
		if(Std.is(child, Bone))
		{
			var bone:Bone = cast(child, Bone);
			index = _boneList.indexOf(bone);
			if(index >= 0)
			{
				_boneList.splice(index, 1);
				bone.setParent(null);
				bone.setArmature(null);
			}
			else
			{
				throw "ArgumentError";
			}
		}
		else if(Std.is(child, Slot))
		{
			var slot:Slot = cast(child, Slot);
			index = _slotList.indexOf(slot);
			if(index >= 0)
			{
				_slotList.splice(index, 1);
				slot.setParent(null);
				slot.setArmature(null);
			}
			else
			{
				throw "ArgumentError";
			}
		}
	}

	override public function calculateRelativeParentTransform():Void
	{
		_global.scaleX = this._origin.scaleX * _tween.scaleX * this._offset.scaleX;
		_global.scaleY = this._origin.scaleY * _tween.scaleY * this._offset.scaleY;
		_global.skewX = this._origin.skewX + _tween.skewX + this._offset.skewX;
		_global.skewY = this._origin.skewY + _tween.skewY + this._offset.skewY;
		_global.x = this._origin.x + _tween.x + this._offset.x;
		_global.y = this._origin.y + _tween.y + this._offset.y;
	}

	/** @private */
	public function update(needUpdate:Bool = false):Void
	{
		_needUpdate --;
		if(needUpdate || _needUpdate > 0 || (this._parent != null && this._parent._needUpdate > 0))
		{
			_needUpdate = 1;
		}
		else
		{
			return;
		}

		if(_frameCachedPosition >= 0 && _frameCachedDuration <= 0)
		{
			var frameCached:FrameCached = _timelineCached.timeline[_frameCachedPosition];
			var transform:DBTransform = frameCached.transform;
			this._global.x = transform.x;
			this._global.y = transform.x;
			this._global.skewX = transform.skewX;
			this._global.skewY = transform.skewY;
			this._global.scaleX = transform.scaleX;
			this._global.scaleY = transform.scaleY;
			//this._global.copy(_frameCached.transform);

			var matrix:Matrix = frameCached.matrix;
			this._globalTransformMatrix.a = matrix.a;
			this._globalTransformMatrix.b = matrix.b;
			this._globalTransformMatrix.c = matrix.c;
			this._globalTransformMatrix.d = matrix.d;
			this._globalTransformMatrix.tx = matrix.tx;
			this._globalTransformMatrix.ty = matrix.ty;
			//this._globalTransformMatrix.copyFrom(_frameCached.matrix);
			return;
		}

		blendingTimeline();

	//计算global
		var result:TransformSet = updateGlobal();
		var parentGlobalTransform:DBTransform = result != null ? result.parentGlobalTransform : null;
		var parentGlobalTransformMatrix:Matrix = result != null ? result.parentGlobalTransformMatrix : null;

	//计算globalForChild
		var ifExistOffsetTranslation:Bool = _offset.x != 0 || _offset.y != 0;
		var ifExistOffsetScale:Bool = _offset.scaleX != 1 || _offset.scaleY != 1;
		var ifExistOffsetRotation:Bool = _offset.skewX != 0 || _offset.skewY != 0;

		if(	(!ifExistOffsetTranslation || applyOffsetTranslationToChild) &&
			(!ifExistOffsetScale || applyOffsetScaleToChild) &&
			(!ifExistOffsetRotation || applyOffsetRotationToChild))
		{
			_globalTransformForChild = _global;
			_globalTransformMatrixForChild = _globalTransformMatrix;
		}
		else
		{
			if(_tempGlobalTransformForChild == null)
			{
				_tempGlobalTransformForChild = new DBTransform();
			}
			_globalTransformForChild = _tempGlobalTransformForChild;

			if(_tempGlobalTransformMatrixForChild == null)
			{
				_tempGlobalTransformMatrixForChild = new Matrix();
			}
			_globalTransformMatrixForChild = _tempGlobalTransformMatrixForChild;

			_globalTransformForChild.x = this._origin.x + _tween.x;
			_globalTransformForChild.y = this._origin.y + _tween.y;
			_globalTransformForChild.scaleX = this._origin.scaleX * _tween.scaleX;
			_globalTransformForChild.scaleY = this._origin.scaleY * _tween.scaleY;
			_globalTransformForChild.skewX = this._origin.skewX + _tween.skewX;
			_globalTransformForChild.skewY = this._origin.skewY + _tween.skewY;

			if(applyOffsetTranslationToChild)
			{
				_globalTransformForChild.x += this._offset.x;
				_globalTransformForChild.y += this._offset.y;
			}
			if(applyOffsetScaleToChild)
			{
				_globalTransformForChild.scaleX *= this._offset.scaleX;
				_globalTransformForChild.scaleY *= this._offset.scaleY;
			}
			if(applyOffsetRotationToChild)
			{
				_globalTransformForChild.skewX += this._offset.skewX;
				_globalTransformForChild.skewY += this._offset.skewY;
			}

			TransformUtil.transformToMatrix(_globalTransformForChild, _globalTransformMatrixForChild, true);
			if(parentGlobalTransformMatrix != null)
			{
				_globalTransformMatrixForChild.concat(parentGlobalTransformMatrix);
				TransformUtil.matrixToTransform(_globalTransformMatrixForChild, _globalTransformForChild, _globalTransformForChild.scaleX * parentGlobalTransform.scaleX >= 0, _globalTransformForChild.scaleY * parentGlobalTransform.scaleY >= 0 );
			}
		}

		if(_frameCachedDuration > 0)    // && _frameCachedPosition >= 0
		{
			_timelineCached.addFrame(this._global, this._globalTransformMatrix, _frameCachedPosition, _frameCachedDuration);
		}
	}

	/** @private */
	public function updateColor(
		aOffset:Float,
		rOffset:Float,
		gOffset:Float,
		bOffset:Float,
		aMultiplier:Float,
		rMultiplier:Float,
		gMultiplier:Float,
		bMultiplier:Float,
		colorChanged:Bool
	):Void
	{
		for (slot in _slotList)
		{
			slot.updateDisplayColor(
				aOffset, rOffset, gOffset, bOffset,
				aMultiplier, rMultiplier, gMultiplier, bMultiplier
			);
		}

		_isColorChanged = colorChanged;
	}

	/** @private */
	public function hideSlots():Void
	{
		for (slot in _slotList)
		{
			slot.changeDisplay(-1);
		}
	}

	/** @private When bone timeline enter a key frame, call this func*/
	public function arriveAtFrame(frame:Frame, timelineState:TimelineState, animationState:AnimationState, isCross:Bool):Void
	{
		var displayControl:Bool =
			animationState.displayControl &&
			(displayController == null || displayController == animationState.name) &&
			animationState.getMixingTransform(name) == false;

		if(displayControl)
		{
			var slot:Slot;
			var tansformFrame:TransformFrame = cast(frame, TransformFrame);
			var displayIndex:Int = tansformFrame.displayIndex;
			for (slot in _slotList)
			{
				slot.changeDisplay(displayIndex);
				slot.updateDisplayVisible(tansformFrame.visible);
				if(displayIndex >= 0)
				{
					if(!Math.isNaN(tansformFrame.zOrder) && tansformFrame.zOrder != slot._tweenZOrder)
					{
						slot._tweenZOrder = tansformFrame.zOrder;
						this._armature._slotsZOrderChanged = true;
					}
				}
			}

			if(frame.event != null && this._armature.hasEventListener(FrameEvent.BONE_FRAME_EVENT))
			{
				var frameEvent:FrameEvent = new FrameEvent(FrameEvent.BONE_FRAME_EVENT);
				frameEvent.bone = this;
				frameEvent.animationState = animationState;
				frameEvent.frameLabel = frame.event;
				this._armature._eventList.push(frameEvent);
			}

			if(frame.sound != null && _soundManager.hasEventListener(SoundEvent.SOUND))
			{
				var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
				soundEvent.armature = this._armature;
				soundEvent.animationState = animationState;
				soundEvent.sound = frame.sound;
				_soundManager.dispatchEvent(soundEvent);
			}

			//[TODO]currently there is only gotoAndPlay belongs to frame action. In future, there will be more.
			//后续会扩展更多的action，目前只有gotoAndPlay的含义
			if(frame.action != null)
			{
				for (slot in _slotList)
				{
					var childArmature:Armature = slot.childArmature;
					if(childArmature != null)
					{
						childArmature.animation.gotoAndPlay(frame.action);
					}
				}
			}
		}
	}

	/** @private */
	public function addState(timelineState:TimelineState):Void
	{
		if(_timelineStateList.indexOf(timelineState) < 0)
		{
			_timelineStateList.push(timelineState);
			_timelineStateList.sort(sortState);
		}
	}

	/** @private */
	public function removeState(timelineState:TimelineState):Void
	{
		var index:Int = _timelineStateList.indexOf(timelineState);
		if(index >= 0)
		{
			_timelineStateList.splice(index, 1);
		}
	}

	private function blendingTimeline():Void
	{
		var timelineState:TimelineState;
		var transform:DBTransform;
		var pivot:Point;
		var weight:Float;

		var i:Int = _timelineStateList.length;
		if(i == 1)
		{
			timelineState = _timelineStateList[0];
			weight = timelineState._animationState.weight * timelineState._animationState.fadeWeight;
			timelineState._weight = weight;
			transform = timelineState._transform;
			pivot = timelineState._pivot;

			_tween.x = transform.x * weight;
			_tween.y = transform.y * weight;
			_tween.skewX = transform.skewX * weight;
			_tween.skewY = transform.skewY * weight;
			_tween.scaleX = 1 + (transform.scaleX - 1) * weight;
			_tween.scaleY = 1 + (transform.scaleY - 1) * weight;

			_tweenPivot.x = pivot.x * weight;
			_tweenPivot.y = pivot.y * weight;
		}
		else if(i > 1)
		{
			var x:Float = 0;
			var y:Float = 0;
			var skewX:Float = 0;
			var skewY:Float = 0;
			var scaleX:Float = 1;
			var scaleY:Float = 1;
			var pivotX:Float = 0;
			var pivotY:Float = 0;

			var weigthLeft:Float = 1;
			var layerTotalWeight:Float = 0;
			var prevLayer:Int = _timelineStateList[i - 1]._animationState.layer;
			var currentLayer:Int;

			//Traversal the layer from up to down
			//layer由高到低依次遍历

			while(i -- > 0)
			{
				timelineState = _timelineStateList[i];

				currentLayer = timelineState._animationState.layer;
				if(prevLayer != currentLayer)
				{
					if(layerTotalWeight >= weigthLeft)
					{
						timelineState._weight = 0;
						break;
					}
					else
					{
						weigthLeft -= layerTotalWeight;
					}
				}
				prevLayer = currentLayer;

				weight = timelineState._animationState.weight * timelineState._animationState.fadeWeight * weigthLeft;
				timelineState._weight = weight;
				if(weight != 0 && timelineState._blendEnabled)
				{
					transform = timelineState._transform;
					pivot = timelineState._pivot;

					x += transform.x * weight;
					y += transform.y * weight;
					skewX += transform.skewX * weight;
					skewY += transform.skewY * weight;
					scaleX += (transform.scaleX - 1) * weight;
					scaleY += (transform.scaleY - 1) * weight;
					pivotX += pivot.x * weight;
					pivotY += pivot.y * weight;

					layerTotalWeight += weight;
				}
			}

			_tween.x = x;
			_tween.y = y;
			_tween.skewX = skewX;
			_tween.skewY = skewY;
			_tween.scaleX = scaleX;
			_tween.scaleY = scaleY;
			_tweenPivot.x = pivotX;
			_tweenPivot.y = pivotY;
		}
	}

	private function sortState(state1:TimelineState, state2:TimelineState):Int
	{
		return state1._animationState.layer < state2._animationState.layer?-1:1;
	}
}
