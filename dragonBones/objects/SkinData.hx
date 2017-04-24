package dragonBones.objects
{
import dragonBones.core.BaseObject;

/**
 * @private
 */
public final class SkinData extends BaseObject
{
	public var name:String;
	public inline var slots:Dynamic = {};
	
	public function SkinData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		for (var k:String in slots)
		{
			(slots[k] as SkinSlotData).returnToPool();
			delete slots[k];
		}
		
		name = null;
		//slots.clear();
	}
	
	public function addSlot(value:SkinSlotData):Void
	{
		if (value != null && value.slot != null && slots[value.slot.name] == null)
		{
			slots[value.slot.name] = value;
		}
		else
		{
			throw new ArgumentError();
		}
	}
	
	public function getSlot(name:String):SkinSlotData
	{
		return slots[name] as SkinSlotData;
	}
}
}