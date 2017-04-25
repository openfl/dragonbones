package dragonBones.objects;

import dragonBones.core.BaseObject;
import dragonBones.geom.Transform;

/**
 * @language zh_CN
 * 骨骼数据。
 * @see dragonBones.Bone
 * @version DragonBones 3.0
 */
class BoneData extends BaseObject
{
	/**
	 * @private
	 */
	@:allow("dragonBones") private var inheritTranslation:Bool;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var inheritRotation:Bool;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var inheritScale:Bool;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var bendPositive:Bool;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var chain:UInt;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var chainIndex:UInt;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var weight:Float;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var length:Float;
	/**
	 * @language zh_CN
	 * 数据名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var transform:Transform = new Transform();
	/**
	 * @language zh_CN
	 * 所属的父骨骼数据。
	 * @version DragonBones 3.0
	 */
	public var parent:BoneData;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var ik:BoneData;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var userData: CustomData;
	/**
	 * @private
	 */
	@:allow("dragonBones") @:allow("dragonBones") private function new()
	{
		super();
	}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		if (userData != null) 
		{
			userData.returnToPool();
		}
		
		inheritTranslation = false;
		inheritRotation = false;
		inheritScale = false;
		bendPositive = false;
		chain = 0;
		chainIndex = 0;
		weight = 0.0;
		length = 0.0;
		name = null;
		transform.identity();
		parent = null;
		ik = null;
		userData = null;
	}
	
	/**
	 * @private
	 */
	@:allow("dragonBones") private function toString():String
	{
		return name;
	}
}