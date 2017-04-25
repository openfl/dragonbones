package dragonBones.objects;

import openfl.geom.ColorTransform;
import openfl.Vector;

import dragonBones.core.BaseObject;
import dragonBones.enums.BlendMode;

/**
 * @language zh_CN
 * 插槽数据。
 * @see dragonBones.Slot
 * @version DragonBones 3.0
 */
class SlotData extends BaseObject
{
	/**
	 * @private
	 */
	@:allow("dragonBones") private static var DEFAULT_COLOR:ColorTransform = new ColorTransform();
	/**
	 * @private
	 */
	@:allow("dragonBones") private static function generateColor():ColorTransform
	{
		return new ColorTransform();
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private var displayIndex:Int;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var zOrder:Int;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var blendMode:Int;
	/**
	 * @language zh_CN
	 * 数据名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var actions: Vector<ActionData> = new Vector<ActionData>();
	/**
	 * @language zh_CN
	 * 所属的父骨骼数据。
	 * @see dragonBones.objects.BoneData
	 * @version DragonBones 3.0
	 */
	public var parent:BoneData;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var color:ColorTransform;
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
		var l:UInt = actions.length;
		for (i in 0...l)
		{
			actions[i].returnToPool();
		}
		
		if (userData != null) 
		{
			userData.returnToPool();
		}
		
		displayIndex = -1;
		zOrder = 0;
		blendMode = BlendMode.None;
		name = null;
		actions.length = 0;
		parent = null;
		color = null;
		userData = null;
	}
}