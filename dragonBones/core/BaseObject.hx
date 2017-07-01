package dragonBones.core;

import openfl.errors.Error;
import dragonBones.utils.ClassMap;
/**
 * @language zh_CN
 * 基础对象。
 * @version DragonBones 4.5
 */
 
/*
@:coreType abstract ClassKey from Class<Dynamic> to {} {
}
*/
@:allow(dragonBones) class BaseObject
{
	private static var _hashCode:UInt = 0;
	private static var _defaultMaxCount:UInt = 5000;
	private static var _maxCountMap:ClassMap<Class<Dynamic>, Int> = new ClassMap<Class<Dynamic>, Int>();
	private static var _poolsMap:ClassMap<Class<Dynamic>, Array<BaseObject>> = new ClassMap<Class<Dynamic>, Array<BaseObject>>();
	
	private static function _returnObject(object:BaseObject):Void
	{
		//var objectConstructor:Class<Dynamic> = getDefinitionByName(getQualifiedClassName(object));
		var objectConstructor:Class<Dynamic> = Type.getClass(object);
		var maxCount:Int = _maxCountMap.exists(objectConstructor) ? _maxCountMap.get(objectConstructor) : _defaultMaxCount;
		var pool:Array<BaseObject>;
		
		if (_poolsMap.exists(objectConstructor))
		{
			pool = _poolsMap.get(objectConstructor);
		}
		else
		{
			pool = new Array<BaseObject>();
			_poolsMap.set(objectConstructor, pool);
		}
		
		if (pool.length < maxCount)
		{
			if (!object._isInPool)
			{
				object._isInPool = true;
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
	public static function setMaxCount(objectConstructor:Class<Dynamic>, maxCount:Int):Void
	{
		var pool:Array<BaseObject>;
		
		if (objectConstructor != null)
		{
			_maxCountMap.set(objectConstructor, maxCount);
			
			if (_poolsMap.exists(objectConstructor))
			{
				pool = _poolsMap.get(objectConstructor);
				if (pool.length > maxCount)
				{
					//pool.length = maxCount;
				}
			}
		}
		else
		{
			_defaultMaxCount = maxCount;
			
			for (classType in _poolsMap.keys())
			{
				if (!_maxCountMap.exists(classType))
				{
					continue;
				}
				
				pool = _poolsMap.get(classType);
				if (pool.length > maxCount)
				{
					//pool.length = maxCount;
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
			if (_poolsMap.exists(objectConstructor))
			{
				var pool:Array<BaseObject> = _poolsMap.get(objectConstructor);
				if (pool.length > 0)
				{
					pool = [];
				}
			}
		}
		else
		{
			for (k in _poolsMap.keys())
			{
				_poolsMap.set(k, []);
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
		var pool:Array<BaseObject> = _poolsMap.exists(objectConstructor) ? _poolsMap.get(objectConstructor) : null;
		if (pool != null && pool.length > 0)
		{
			var object = pool.pop();
			object._isInPool = false;
			return object;
		}
		else
		{
			var object:BaseObject = Type.createInstance(objectConstructor, []);
			object._onClear();
			return object;
		}
	}
	/**
	 * @language zh_CN
	 * 对象的唯一标识。
	 * @version DragonBones 4.5
	 */
	public var hashCode:UInt = _hashCode++;

	private var _isInPool:Bool = false;
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