package dragonBones.objects;

import dragonBones.core.BaseObject;
import dragonBones.geom.Transform;

/**
 * @language zh_CN
 * 骨骼数据。
 * @see dragonBones.Bone
 * @version DragonBones 3.0
 */
@:allow(dragonBones) class BoneData extends BaseObject
{
	/**
	 * @private
	 */
	private var inheritTranslation:Bool;
	/**
	 * @private
	 */
	private var inheritRotation:Bool;
	/**
	 * @private
	 */
	private var inheritScale:Bool;
	/**
	 * @private
	 */
	private var bendPositive:Bool;
	/**
	 * @private
	 */
	private var chain:UInt;
	/**
	 * @private
	 */
	private var chainIndex:UInt;
	/**
	 * @private
	 */
	private var weight:Float;
	/**
	 * @private
	 */
	private var length:Float;
	/**
	 * @language zh_CN
	 * 数据名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @private
	 */
	private var transform:Transform = new Transform();
	/**
	 * @language zh_CN
	 * 所属的父骨骼数据。
	 * @version DragonBones 3.0
	 */
	public var parent:BoneData;
	/**
	 * @private
	 */
	private var ik:BoneData;
	/**
	 * @private
	 */
	private var userData: CustomData;
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
	private function toString():String
	{
		return name;
	}
}