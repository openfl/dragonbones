package dragonBones.objects;

import dragonBones.core.BaseObject;

/**
 * @private
 */
@:final class SkinData extends BaseObject
{
	public var name:String;
	public var slots:Map<String, SkinSlotData> = new Map<String, SkinSlotData>();
	
	@:allow("dragonBones") private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		for (k in slots.keys())
		{
			slots[k].returnToPool();
			slots.remove(k);
		}
		
		name = null;
		//slots.clear();
	}
	
	public function addSlot(value:SkinSlotData):Void
	{
		if (value != null && value.slot != null && !slots.exists(value.slot.name))
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
		return slots[name];
	}
}