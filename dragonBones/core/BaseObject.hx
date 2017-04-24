package dragonBones.core;

import openfl.Vector;

/**
 * @language zh_CN
 * 基础对象。
 * @version DragonBones 4.5
 */
public class BaseObject
{
	private static var _hashCode:UInt = 0;
	private static var _defaultMaxCount:UInt = 5000;
	private static inline var _maxCountMap:Map<Class<Dynamic>> = new Map();
	private static inline var _poolsMap:Map<Class<Dynamic>> = new Map();
	
	private static function _returnObject(object:BaseObject):Void
	{
		//inline var objectConstructor:Class = getDefinitionByName(getQualifiedClassName(object));
		inline var objectConstructor:Class<Dynamic> = Type.getClass(object);
		inline var maxCount:UInt = _maxCountMap[objectConstructor] == null? _defaultMaxCount: _maxCountMap[objectConstructor];
		inline var pool:Vector<BaseObject> = _poolsMap[objectConstructor] = _poolsMap[objectConstructor] || new Vector<BaseObject>;
		
		if (pool.length < maxCount)
		{
			if (pool.indexOf(object) < 0)
			{
				pool.push(object);
			}
			else
			{
				throw new Error();
			}
		}
	}
	/**
	 * @language zh_CN
	 * 设置每种对象池的最大缓存数量。
	 * @param objectConstructor 对象类。
	 * @param maxCount 最大缓存数量。 (设置为 0 则不缓存)
	 * @version DragonBones 4.5
	 */
	public static function setMaxCount(objectConstructor:Class<Dynamic>, maxCount:UInt):Void
	{
		if (objectConstructor != null)
		{
			_maxCountMap[objectConstructor] = maxCount;
			
			var pool:Vector<BaseObject> = _poolsMap[objectConstructor];
			if (pool != null && pool.length > maxCount)
			{
				pool.length = maxCount;
			}
		}
		else
		{
			_defaultMaxCount = maxCount;
			
			for (classType in _poolsMap)
			{
				if (_maxCountMap[classType] == null)
				{
					continue;
				}
				
				pool = _poolsMap[classType];
				if (pool.length > maxCount)
				{
					pool.length = maxCount;
				}
			}
		}
	}
	/**
	 * @language zh_CN
	 * 清除所有对象池缓存的对象。
     * @param objectConstructor 对象类。 (不设置则清除所有缓存)
	 * @version DragonBones 4.5
	 */
	public static function clearPool(objectConstructor:Class<Dynamic> = null):Void
	{
		if (objectConstructor != null)
		{
			var pool:Vector<BaseObject> = _poolsMap[objectConstructor];
			if (pool != null && pool.length)
			{
				pool.length = 0;
			}
		}
		else
		{
			for (pool in _poolsMap)
			{
				pool.length = 0;
			}
		}
	}
	/**
	 * @language zh_CN
	 * 从对象池中创建指定对象。
	 * @version DragonBones 4.5
	 */
	public static function borrowObject(objectConstructor:Class<Dynamic>):BaseObject
	{
		var pool:Vector<BaseObject> = _poolsMap[objectConstructor];
		if (pool != null && pool.length > 0)
		{
			return pool.pop();
		}
		else
		{
			var object:BaseObject = Type.createInstance(objectConstructor, objectConstructor, []);
			object._onClear();
			return object;
		}
	}
	/**
	 * @language zh_CN
	 * 对象的唯一标识。
	 * @version DragonBones 4.5
	 */
	public inline var hashCode:UInt = _hashCode++;
	/**
	 * @private
	 */
	private function new() {}
	/**
	 * @private
	 */
	private function _onClear():Void {}
	/**
	 * @language zh_CN
	 * 清除数据并返还对象池。
	 * @version DragonBones 4.5
	 */
	@:final public function returnToPool():Void
	{
		_onClear();
		_returnObject(this);
	}
}