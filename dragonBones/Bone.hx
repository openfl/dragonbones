package dragonBones;

import openfl.geom.Matrix;


import dragonBones.core.TransformObject;
import dragonBones.geom.Transform;
import dragonBones.objects.BoneData;


/**
 * @language zh_CN
 * 骨骼，一个骨架中可以包含多个骨骼，骨骼以树状结构组成骨架。
 * 骨骼在骨骼动画体系中是最重要的逻辑单元之一，负责动画中的平移旋转缩放的实现。
 * @see dragonBones.objects.BoneData
 * @see dragonBones.Armature
 * @see dragonBones.Slot
 * @version DragonBones 3.0
 */
@:allow(dragonBones) @:final class Bone extends TransformObject
{
	/**
	 * @language zh_CN
	 * 是否继承父骨骼的平移。
	 * @version DragonBones 3.0
	 */
	public var inheritTranslation:Bool;
	/**
	 * @language zh_CN
	 * 是否继承父骨骼的旋转。
	 * @version DragonBones 3.0
	 */
	public var inheritRotation:Bool;
	/**
	 * @language zh_CN
	 * 是否继承父骨骼的缩放。
	 * @version DragonBones 4.5
	 */
	public var inheritScale:Bool;
	/**
	 * @private
	 */
	private var ikBendPositive:Bool;
	/**
	 * @language zh_CN
	 * 骨骼长度。
	 * @version DragonBones 4.5
	 */
	public var length:Float;
	/**
	 * @private
	 */
	private var ikWeight:Float;
	/**
	 * @private [2: update self, 1: update children, ik children, mesh, ..., 0: stop update]
	 */
	private var _transformDirty:Int;
	private var _visible:Bool;
	private var _cachedFrameIndex:Int;
	private var _ikChain:UInt;
	private var _ikChainIndex:UInt;
	/**
	 * @private
	 */
	private var _updateState:Int;
	/**
	 * @private
	 */
	private var _blendLayer:Int;
	/**
	 * @private
	 */
	private var _blendLeftWeight:Float;
	/**
	 * @private
	 */
	private var _blendTotalWeight:Float;
	/**
	 * @private
	 */
	private var _animationPose:Transform = new Transform();
	private var _bones:Array<Bone> = new Array<Bone>();
	private var _slots:Array<Slot> = new Array<Slot>();
	private var _boneData:BoneData;
	private var _ik:Bone;
	/**
	 * @private
	 */
	private var _cachedFrameIndices:Array<Int>;
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
		
		inheritTranslation = false;
		inheritRotation = false;
		inheritScale = false;
		ikBendPositive = false;
		length = 0.0;
		ikWeight = 0.0;
		
		_transformDirty = 0;
		_visible = true;
		_cachedFrameIndex = -1;
		_ikChain = 0;
		_ikChainIndex = 0;
		_updateState = -1;
		_blendLayer = 0;
		_blendLeftWeight = 1.0;
		_blendTotalWeight = 0.0;
		_animationPose.identity();
		_bones = [];
		_slots = [];
		_boneData = null;
		_ik = null;
		_cachedFrameIndices = null;
	}
	/**
	 * @private
	 */
	private function _updateGlobalTransformMatrix():Void
	{
		global.x = origin.x + offset.x + _animationPose.x;
		global.y = origin.y + offset.y + _animationPose.y;
		global.skewX = origin.skewX + offset.skewX + _animationPose.skewX;
		global.skewY = origin.skewY + offset.skewY + _animationPose.skewY;
		global.scaleX = origin.scaleX * offset.scaleX * _animationPose.scaleX;
		global.scaleY = origin.scaleY * offset.scaleY * _animationPose.scaleY;
		
		if (_parent != null)
		{
			var parentRotation:Float = _parent.global.skewY; // Only inherit skew y
			var parentMatrix:Matrix = _parent.globalTransformMatrix;
			
			if (inheritScale)
			{
				if (!inheritRotation)
				{
					global.skewX -= parentRotation;
					global.skewY -= parentRotation;
				}
				
				global.toMatrix(globalTransformMatrix);
				globalTransformMatrix.concat(parentMatrix);
				
				if (!inheritTranslation)
				{
					globalTransformMatrix.tx = global.x;
					globalTransformMatrix.ty = global.y;
				}
				
				global.fromMatrix(globalTransformMatrix);
			}
			else
			{
				if (inheritTranslation)
				{
					var x:Float = global.x;
					var y:Float = global.y;
					global.x = parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx;
					global.y = parentMatrix.d * y + parentMatrix.b * x + parentMatrix.ty;
				}
				
				if (inheritRotation)
				{
					global.skewX += parentRotation;
					global.skewY += parentRotation;
				}
				
				global.toMatrix(globalTransformMatrix);
			}
		}
		else
		{
			global.toMatrix(globalTransformMatrix);
		}
		
		if (_ik != null && _ikChainIndex == _ikChain && ikWeight > 0)
		{
			if (inheritTranslation && _ikChain > 0 && _parent != null)
			{
				_computeIKB();
			}
			else
			{
				_computeIKA();
			}
		}
	}
	/**
	 * @private
	 */
	private function _computeIKA():Void
	{
		var ikGlobal:Transform = _ik.global;
		var x:Float = globalTransformMatrix.a * length;
		var y:Float = globalTransformMatrix.b * length;
		
		var ikRadian:Float = 
			(
				Math.atan2(ikGlobal.y - global.y, ikGlobal.x - global.x) + 
				offset.skewY - 
				global.skewY * 2 + 
				Math.atan2(y, x)
			) * ikWeight; // Support offset.
		
		global.skewX += ikRadian;
		global.skewY += ikRadian;
		global.toMatrix(globalTransformMatrix);
	}
	/**
	 * @private
	 */
	private function _computeIKB():Void
	{
		// TODO IK
		var parentGlobal:Transform = _parent.global;
		var ikGlobal:Transform = _ik.global;
		
		var x:Float = globalTransformMatrix.a * length;
		var y:Float = globalTransformMatrix.b * length;
		
		var lLL:Float = x * x + y * y;
		var lL:Float = Math.sqrt(lLL);
		
		var dX:Float = global.x - parentGlobal.x;
		var dY:Float = global.y - parentGlobal.y;
		var lPP:Float = dX * dX + dY * dY;
		var lP:Float = Math.sqrt(lPP);
		
		dX = ikGlobal.x - parentGlobal.x;
		dY = ikGlobal.y - parentGlobal.y;
		var lTT:Float = dX * dX + dY * dY;
		var lT:Float = Math.sqrt(lTT);
		
		var ikRadianA:Float = 0;
		if (lL + lP <= lT || lT + lL <= lP || lT + lP <= lL)
		{
			ikRadianA = Math.atan2(ikGlobal.y - parentGlobal.y, ikGlobal.x - parentGlobal.x) + _parent.offset.skewY; // Support offset.
			if (lL + lP <= lT)
			{
			}
			else if (lP < lL)
			{
				ikRadianA += Math.PI;
			}
		}
		else
		{
			var h:Float = (lPP - lLL + lTT) / (2 * lTT);
			var r:Float = Math.sqrt(lPP - h * h * lTT) / lT;
			var hX:Float = parentGlobal.x + (dX * h);
			var hY:Float = parentGlobal.y + (dY * h);
			var rX:Float = -dY * r;
			var rY:Float = dX * r;
			
			if (ikBendPositive)
			{
				global.x = hX - rX;
				global.y = hY - rY;
			}
			else
			{
				global.x = hX + rX;
				global.y = hY + rY;
			}
			
			ikRadianA = Math.atan2(global.y - parentGlobal.y, global.x - parentGlobal.x) + _parent.offset.skewY; // Support offset
		}
		
		ikRadianA = (ikRadianA - parentGlobal.skewY) * ikWeight;
		
		parentGlobal.skewX += ikRadianA;
		parentGlobal.skewY += ikRadianA;
		parentGlobal.toMatrix(_parent.globalTransformMatrix);
		_parent._transformDirty = 1;
		
		global.x = parentGlobal.x + Math.cos(parentGlobal.skewY) * lP;
		global.y = parentGlobal.y + Math.sin(parentGlobal.skewY) * lP;
		
		var ikRadianB:Float = 
			(
				Math.atan2(ikGlobal.y - global.y, ikGlobal.x - global.x) + offset.skewY - 
				global.skewY * 2 + Math.atan2(y, x)
			) * ikWeight; // Support offset.
		
		global.skewX += ikRadianB;
		global.skewY += ikRadianB;
		
		global.toMatrix(globalTransformMatrix);
	}
	/**
	 * @private
	 */
	private function _init(boneData: BoneData):Void 
	{
		if (_boneData != null) 
		{
			return;
		}
		
		_boneData = boneData;
		
		inheritTranslation = _boneData.inheritTranslation;
		inheritRotation = _boneData.inheritRotation;
		inheritScale = _boneData.inheritScale;
		length = _boneData.length;
		name = _boneData.name;
		origin = _boneData.transform;
	}
	/**
	 * @private
	 */
	override private function _setArmature(value:Armature):Void
	{
		_armature = value;
		_armature._addBoneToBoneList(this);
	}
	/**
	 * @private
	 */
	private function _setIK(value:Bone, chain:UInt, chainIndex:UInt):Void
	{
		if (value != null)
		{
			if (chain == chainIndex)
			{
				var chainEnd:Bone = _parent;
				if (chain > 0 && chainEnd != null)
				{
					chain = 1;
				}
				else
				{
					chain = 0;
					chainIndex = 0;
					chainEnd = this;
				}
				
				if (chainEnd == value || chainEnd.contains(value))
				{
					value = null;
					chain = 0;
					chainIndex = 0;
				}
				else
				{
					var ancestor:Bone = value;
					while(ancestor._ik != null && ancestor._ikChain != 0)
					{
						if (chainEnd.contains(ancestor._ik))
						{
							value = null;
							chain = 0;
							chainIndex = 0;
							break;
						}
						
						ancestor = ancestor.parent;
					}
				}
			}
		}
		else
		{
			chain = 0;
			chainIndex = 0;
		}
		
		_ik = value;
		_ikChain = chain;
		_ikChainIndex = chainIndex;
		
		if (_armature != null)
		{
			_armature._bonesDirty = true;
		}
	}
	/**
	 * @private
	 */
	private function _update(cacheFrameIndex:Int):Void
	{
		_updateState = -1;
		
		if (cacheFrameIndex >= 0 && _cachedFrameIndices != null) 
		{
			var cachedFrameIndex:Int = _cachedFrameIndices[cacheFrameIndex];
			if (cachedFrameIndex >= 0 && _cachedFrameIndex == cachedFrameIndex) // Same cache.
			{
				_transformDirty = 0;
			}
			else if (cachedFrameIndex >= 0) // Has been Cached.
			{
				_transformDirty = 2;
				_cachedFrameIndex = cachedFrameIndex;
			}
			else if (
				_transformDirty == 2 ||
				(_parent != null && _parent._transformDirty != 0) ||
				(_ik != null && ikWeight > 0 && _ik._transformDirty != 0)
			) // Dirty.
			{
				_transformDirty = 2;
				_cachedFrameIndex = -1;
			}
			else if (_cachedFrameIndex >= 0) // Same cache, but not set index yet.
			{
				_transformDirty = 0;
				_cachedFrameIndices[cacheFrameIndex] = _cachedFrameIndex;
			}
			else // Dirty.
			{
				_transformDirty = 2;
				_cachedFrameIndex = -1;
			}
		}
		else if (
			_transformDirty == 2 ||
			(_parent != null && _parent._transformDirty != 0) ||
			(_ik != null && ikWeight > 0 && _ik._transformDirty != 0)
		) // Dirty.
		{
			cacheFrameIndex = -1;
			_transformDirty = 2;
			_cachedFrameIndex = -1;
		}
		
		if (_transformDirty != 0) 
		{
			if (_transformDirty == 2) 
			{
				_transformDirty = 1;
				
				if (_cachedFrameIndex < 0) 
				{
					_updateGlobalTransformMatrix();
					
					if (cacheFrameIndex >= 0) 
					{
						_cachedFrameIndex = _cachedFrameIndices[cacheFrameIndex] = _armature._armatureData.setCacheFrame(globalTransformMatrix, global);
					}
				}
				else 
				{
					_armature._armatureData.getCacheFrame(globalTransformMatrix, global, _cachedFrameIndex);
				}
				
				_updateState = 0;
			}
			else {
				_transformDirty = 0;
			}
		}
	}
	/**
	 * @language zh_CN
	 * 下一帧更新变换。 (当骨骼没有动画状态或动画状态播放完成时，骨骼将不在更新)
	 * @version DragonBones 3.0
	 */
	public function invalidUpdate():Void
	{
		_transformDirty = 2;
	}
	/**
	 * @language zh_CN
     * 是否包含骨骼或插槽。
	 * @return
	 * @see dragonBones.core.TransformObject
	 * @version DragonBones 3.0
	 */
	public function contains(child:TransformObject):Bool
	{
		if (child != null)
		{
			if (child == this)
			{
				return false;
			}
			
			var ancestor:TransformObject = child;
			while(ancestor != this && ancestor != null)
			{
				ancestor = ancestor.parent;
			}
			
			return ancestor == this;
		}
		
		return false;
	}
	/**
	 * @language zh_CN
	 * 所有的子骨骼。
	 * @version DragonBones 3.0
	 */
	public function getBones():Array<Bone>
	{
		_bones = [];
		
		var bones:Array<Bone> = _armature.getBones();
		var l:UInt = bones.length;
		var bone:Bone;
		for (i in 0...l) 
		{
			bone = bones[i];
			if (bone.parent == this)
			{
				_bones.push(bone);	
			}
		}
		
		return _bones;
	}
	/**
	 * @language zh_CN
	 * 所有的插槽。
	 * @see dragonBones.Slot
	 * @version DragonBones 3.0
	 */
	public function getSlots():Array<Slot>
	{
		_slots = [];
		
		var slots:Array<Slot> = _armature.getSlots();
		var l:UInt = slots.length;
		var slot:Slot;
		for (i in 0...l)
		{
			slot = slots[i];
			if (slot.parent == this)
			{
				_slots.push(slot);	
			}
		}
		
		return _slots;
	}
	/**
	 * @private
	 */
	private var boneData(get, never):BoneData;
	private function get_boneData():BoneData
	{
		return _boneData;
	}
	/**
	 * @language zh_CN
	 * 控制此骨骼所有插槽的可见。
	 * @default true
	 * @see dragonBones.Slot
	 * @version DragonBones 3.0
	 */
	public var visible(get, set):Bool;
	private function get_visible():Bool
	{
		return _visible;
	}
	private function set_visible(value:Bool):Bool
	{
		if (_visible == value)
		{
			return value;
		}
		
		_visible = value;
		
		var slots:Array<Slot> = _armature.getSlots();
		var l:UInt = slots.length;
		var slot:Slot;
		for (i in 0...l)
		{
			slot = slots[i];
			if (slot._parent == this)
			{
				slot._updateVisible();
			}
		}
		
		return value;
	}
	
	/**
	 * @deprecated
	 */
	@:deprecated public var ikChain(get, never):UInt;
	private function get_ikChain():UInt
	{
		return _ikChain;
	}
	/**
	 * @deprecated
	 */
	@:deprecated public var ikChainIndex(get, never):UInt;
	private function get_ikChainIndex():UInt
	{
		return _ikChainIndex;
	}
	/**
	 * @deprecated
	 */
	@:deprecated public var ik(get, never):Bone;
	private function get_ik():Bone
	{
		return _ik;
	}
}