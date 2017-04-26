package dragonBones.objects;

import openfl.errors.ArgumentError;
import openfl.Vector;
	
import dragonBones.core.BaseObject;

/**
 * @private
 */
@:allow(dragonBones) @:final class SkinSlotData extends BaseObject
{
	public var displays:Vector<DisplayData> = new Vector<DisplayData>();
	public var meshs:Map<String, MeshData> = new Map<String, MeshData>();
	public var slot:SlotData;
	
	private function new ()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		var l:UInt = displays.length;
		for (i in 0...l)
		{
			displays[i].returnToPool();
		}
		
		for (k in meshs.keys()) 
		{
			meshs[k].returnToPool();
			meshs.remove(k);
		}
		
		displays.fixed = false;
		displays.length = 0;
		//meshs.clear();
		slot = null;
	}
	
	public function getDisplay(name: String): DisplayData 
	{
		var l:UInt = displays.length;
		var display:DisplayData;
		for (i in 0...l)
		{
			display = displays[i];
			if (display.name == name) 
			{
				return display;
			}
		}
		
		return null;
	}
	
	public function addMesh(value: MeshData):Void 
	{
		if (value != null && value.name != null && !meshs.exists(value.name)) 
		{
			meshs[value.name] = value;
		}
		else 
		{
			throw new ArgumentError();
		}
	}
	
	public function getMesh(name: String): MeshData 
	{
		return meshs[name];
	}
}