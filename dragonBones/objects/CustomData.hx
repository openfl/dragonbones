package dragonBones.objects
{
	import openfl.Vector;
	
import dragonBones.core.BaseObject;

/**
 * @language zh_CN
 * 自定义数据。
 * @version DragonBones 5.0
 */
public final class CustomData extends BaseObject
{
	/**
	 * @language zh_CN
	 * 自定义整数。
	 * @version DragonBones 5.0
	 */
	public inline var ints: Vector<Float> = new Vector<Float>();
	/**
	 * @language zh_CN
	 * 自定义浮点数。
	 * @version DragonBones 5.0
	 */
	public inline var floats: Vector<Float> = new Vector<Float>();
	/**
	 * @language zh_CN
	 * 自定义字符串。
	 * @version DragonBones 5.0
	 */
	public inline var strings: Vector<String> = new Vector<String>();
	/**
	 * @private
	 */
	public function CustomData()
	{
		super(this);
	}
	/**
	 * @private
	 */
	override private function _onClear():Void {
		ints.length = 0;
		floats.length = 0;
		strings.length = 0;
	}
	/**
	 * @language zh_CN
	 * 获取自定义整数。
	 * @version DragonBones 5.0
	 */
	public function getInt(index:Float = 0):Float 
	{
		return index >= 0 && index < ints.length ? ints[index] : 0;
	}
	/**
	 * @language zh_CN
	 * 获取自定义浮点数。
	 * @version DragonBones 5.0
	 */
	public function getFloat(index:Float = 0):Float 
	{
		return index >= 0 && index < floats.length ? floats[index] : 0;
	}
	/**
	 * @language zh_CN
	 * 获取自定义字符串。
	 * @version DragonBones 5.0
	 */
	public function getString(index:Float = 0): String 
	{
		return index >= 0 && index < strings.length ? strings[index] : null;
	}
}
}