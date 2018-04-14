package dragonBones.objects;

import dragonBones.core.BaseObject;
import dragonBones.enums.ActionType;

/**
 * @private
 */
@:allow(dragonBones) @:final class ActionData extends BaseObject
{
	public var type:Int;
	public var bone:BoneData;
	public var slot:SlotData;
	public var animationConfig:AnimationConfig;
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		if (animationConfig != null)
		{
			animationConfig.returnToPool();
		}
		
		type = ActionType.None;
		bone = null;
		slot = null;
		animationConfig = null;
	}
}