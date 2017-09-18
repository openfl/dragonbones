package dragonBones.core;

import dragonBones.Armature;
import dragonBones.animations.Animation;
import dragonBones.events.IEventDispatcher;

/**
 * @language zh_CN
 * 骨架代理接口。
 * @version DragonBones 5.0
 */
@:allow(dragonBones) interface IArmatureProxy extends IEventDispatcher
{
	/**
	 * @private
	 */
	private function _onClear():Void;
	/**
	 * @private
	 */
	private function _debugDraw(isEnabled:Bool):Void;
	/**
	 * @language zh_CN
	 * 释放代理和骨架。 (骨架会回收到对象池)
	 * @version DragonBones 4.5
	 */
	function dispose():Void;
	/**
	 * @language zh_CN
     * 获取骨架。
	 * @see dragonBones.Armature
	 * @version DragonBones 4.5
	 */
	var armature(get, never):Armature;
	/**
	 * @language zh_CN
     * 获取动画控制器。
	 * @see dragonBones.animations.Animation
	 * @version DragonBones 4.5
	 */
	var animations(get, never):Animation;
}