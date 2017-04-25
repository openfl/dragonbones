package dragonBones.objects;

import dragonBones.core.BaseObject;
import dragonBones.enum.ActionType;

/**
 * @private
 */
@:final class ActionData extends BaseObject
{
	public var type:Int;
	public var bone:BoneData;
	public var slot:SlotData;
	public var animationConfig:AnimationConfig;
	
	private function new() {}
	
	override private function _onClear():Void
	{
		if (animationConfig != null)
		{
			animationConfig..returnToPool();
		}
		
		type = ActionType.None;
		bone = null;
		slot = null;
		animationConfig = null;
	}
}
}