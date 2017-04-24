package dragonBones.objects
{
import dragonBones.core.BaseObject;

/**
 * @private
 */
public final class SkinSlotData extends BaseObject
{
	public inline var displays:Vector.<DisplayData> = new Vector.<DisplayData>();
	public inline var meshs:Object = {};
	public var slot:SlotData;
	
	public function SkinSlotData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		for (var i:UInt = 0, l:UInt = displays.length; i < l; ++i)
		{
			displays[i].returnToPool();
		}
		
		for (var k:String in meshs) 
		{
			meshs[k].returnToPool();
			delete meshs[k];
		}
		
		displays.fixed = false;
		displays.length = 0;
		//meshs.clear();
		slot = null;
	}
	
	public function getDisplay(name: String): DisplayData 
	{
		for (var i:UInt = 0, l:UInt = displays.length; i < l; ++i) 
		{
			inline var display:DisplayData = displays[i];
			if (display.name === name) 
			{
				return display;
			}
		}
		
		return null;
	}
	
	public function addMesh(value: MeshData):Void 
	{
		if (value && value.name && !meshs[value.name]) 
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
}