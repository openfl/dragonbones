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
	public var inheritTranslation:Bool;
	/**
	 * @private
	 */
	public var inheritRotation:Bool;
	/**
	 * @private
	 */
	public var inheritScale:Bool;
	/**
	 * @private
	 */
	public var bendPositive:Bool;
	/**
	 * @private
	 */
	public var chain:UInt;
	/**
	 * @private
	 */
	public var chainIndex:UInt;
	/**
	 * @private
	 */
	public var weight:Float;
	/**
	 * @private
	 */
	public var length:Float;
	/**
	 * @language zh_CN
	 * 数据名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @private
	 */
	public inline var transform:Transform = new Transform();
	/**
	 * @language zh_CN
	 * 所属的父骨骼数据。
	 * @version DragonBones 3.0
	 */
	public var parent:BoneData;
	/**
	 * @private
	 */
	public var ik:BoneData;
	/**
	 * @private
	 */
	public var userData: CustomData;
	/**
	 * @private
	 */
	private function new() {}
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
	public function toString():String
	{
		return name;
	}
}