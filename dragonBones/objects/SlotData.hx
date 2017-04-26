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
@:allow(dragonBones) class SlotData extends BaseObject
{
	/**
	 * @private
	 */
	private static var DEFAULT_COLOR:ColorTransform = new ColorTransform();
	/**
	 * @private
	 */
	private static function generateColor():ColorTransform
	{
		return new ColorTransform();
	}
	/**
	 * @private
	 */
	private var displayIndex:Int;
	/**
	 * @private
	 */
	private var zOrder:Int;
	/**
	 * @private
	 */
	private var blendMode:Int;
	/**
	 * @language zh_CN
	 * 数据名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @private
	 */
	private var actions: Vector<ActionData> = new Vector<ActionData>();
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
	private var color:ColorTransform;
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