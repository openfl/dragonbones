package dragonBones.objects;

import openfl.errors.ArgumentError;
import openfl.Vector;
	
import dragonBones.core.BaseObject;

/**
 * @language zh_CN
 * 龙骨数据。
 * 一个龙骨数据包含多个骨架数据。
 * @see dragonBones.objects.ArmatureData
 * @version DragonBones 3.0
 */
@:allow(dragonBones) class DragonBonesData extends BaseObject
{
	/**
	 * @language zh_CN
	 * 是否开启共享搜索。
	 * @default false
	 * @version DragonBones 4.5
	 */
	public var autoSearch:Bool;
	/**
	 * @language zh_CN
	 * 动画帧频。
	 * @version DragonBones 3.0
	 */
	public var frameRate:UInt;
	/**
	 * @language zh_CN
	 * 数据名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @language zh_CN
	 * 所有骨架数据。
	 * @see dragonBones.objects.ArmatureData
	 * @version DragonBones 3.0
	 */
	public var armatures:Map<String, ArmatureData> = new Map<String, ArmatureData>();
	/**
	 * @private
	 */
	private var cachedFrames: Vector<Float> = new Vector<Float>();
	/**
	 * @private
	 */
	private var userData: CustomData;
	
	private var _armatureNames:Vector<String> = new Vector<String>();
	/**
	 * @private
	 */
	@:keep private function new()
	{
		super();
	}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		for (k in armatures.keys())
		{
			armatures[k].returnToPool();
			armatures.remove(k);
		}
		
		if (userData != null) 
		{
			userData.returnToPool();
		}
		
		autoSearch = false;
		frameRate = 0;
		name = null;
		//armatures.clear();
		cachedFrames.length = 0;
		userData = null;
		
		_armatureNames.length = 0;
	}
	/**
	 * @private
	 */
	private function addArmature(value:ArmatureData):Void
	{
		if (value != null && value.name != null && !armatures.exists(value.name))
		{
			armatures[value.name] = value;
			_armatureNames.push(value.name);
			
			value.parent = this;
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @language zh_CN
	 * 获取骨架数据。
	 * @param name 骨架数据名称。
	 * @see dragonBones.objects.ArmatureData
	 * @version DragonBones 3.0
	 */
	public function getArmature(name:String):ArmatureData
	{
		return armatures[name];
	}
	/**
	 * @language zh_CN
	 * 所有骨架数据名称。
	 * @see #armatures
	 * @version DragonBones 3.0
	 */
	public var armatureNames(get, never):Vector<String>;
	private function get_armatureNames():Vector<String>
	{
		return _armatureNames;
	}
}