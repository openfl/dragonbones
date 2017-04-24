package dragonBones.objects
{
import dragonBones.core.BaseObject;
import dragonBones.enum.EventType;

/**
 * @private
 */
public final class EventData extends BaseObject
{
	public var type:Int;
	public var name:String;
	public var bone:BoneData;
	public var slot:SlotData;
	public var data:CustomData;
	
	public function EventData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		if (data != null)
		{
			data.returnToPool();
		}
		
		type = EventType.None;
		name = null;
		bone = null;
		slot = null;
		data = null;
	}
}
}