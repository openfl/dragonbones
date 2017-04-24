package dragonBones.core;

import openfl.geom.Matrix;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.geom.Transform;


/**
 * @language zh_CN
 * 基础变换对象。
 * @version DragonBones 4.5
 */
class TransformObject extends BaseObject
{
	/**
	 * @language zh_CN
	 * 对象的名称。
     * @readOnly
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @language zh_CN
	 * 相对于骨架坐标系的矩阵。
     * @readOnly
	 * @version DragonBones 3.0
	 */
	public static var globalTransformMatrix:Matrix = new Matrix();
	/**
	 * @language zh_CN
	 * 相对于骨架坐标系的变换。
     * @readOnly
	 * @see dragonBones.geom.Transform
	 * @version DragonBones 3.0
	 */
	public static var global:Transform = new Transform();
	/**
	 * @language zh_CN
	 * 相对于骨架或父骨骼坐标系的偏移变换。
	 * @see dragonBones.geom.Transform
	 * @version DragonBones 3.0
	 */
	public static var offset:Transform = new Transform();
	/**
	 * @language zh_CN
	 * 相对于骨架或父骨骼坐标系的绑定变换。
     * @readOnly
	 * @see dragonBones.geom.Transform
	 * @version DragonBones 3.0
	 */
	public var origin:Transform;
	/**
	 * @language zh_CN
	 * 可以用于存储临时数据。
	 * @version DragonBones 3.0
	 */
	public var userData:Object;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var _armature:Armature;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var _parent:Bone;
	/**
	 * @private
	 */
	private function new() {}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		name = null;
		globalTransformMatrix.identity();
		global.identity();
		offset.identity();
		origin = null;
		userData = null;
		
		_armature = null;
		_parent = null;
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function _setArmature(value:Armature):Void
	{
		_armature = value;
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function _setParent(value:Bone):Void
	{
		_parent = value;
	}
	/**
	 * @language zh_CN
	 * 所属的骨架。
	 * @see dragonBones.Armature
	 * @version DragonBones 3.0
	 */
	public var armature(get, never):Armature;
	private function get_armature():Armature
	{
		return _armature;
	}
	/**
	 * @language zh_CN
	 * 所属的父骨骼。
	 * @see dragonBones.Bone
	 * @version DragonBones 3.0
	 */
	public var parent(get, never):Bone;
	private function get_parent():Bone
	{
		return _parent;
	}
}