package dragonBones.events;

import flash.errors.IllegalOperationError;
import flash.events.EventDispatcher;

//[Event(name="sound",type="dragonBones.events.SoundEvent")]

/**
 * 全局声音管理，通过监听SoundEventManager的SoundEvent事件得到动画的声音触发时间和声音的名字
 */
class SoundEventManager extends EventDispatcher
{
	private static var _instance:SoundEventManager;

	public static function getInstance():SoundEventManager
	{
		if (_instance == null)
		{
			_instance = new SoundEventManager();
		}
		return _instance;
	}

	public function new()
	{
		super();
		if (_instance != null)
		{
			throw new IllegalOperationError("Singleton already constructed!");
		}
	}
}
