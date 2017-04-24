package dragonBones.objects
{
import dragonBones.core.BaseObject;
import dragonBones.enum.ActionType;

/**
 * @private
 */
public final class ActionData extends BaseObject
{
	public var type:Int;
	public var bone:BoneData;
	public var slot:SlotData;
	public var animationConfig:AnimationConfig;
	
	public function ActionData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		if (animationConfig)
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