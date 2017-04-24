package dragonBones.objects
{
import dragonBones.core.BaseObject;

/**
 * @private
 */
public final class SkinSlotData extends BaseObject
{
	public inline var displays:Vector<DisplayData> = new Vector<DisplayData>();
	public inline var meshs:Dynamic = {};
	public var slot:SlotData;
	
	public function SkinSlotData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		var l:UInt = displays.length;
		for (i in 0...l)
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
		var l:UInt = displays.length;
		for (i in 0...l)
		{
			inline var display:DisplayData = displays[i];
			if (display.name == name) 
			{
				return display;
			}
		}
		
		return null;
	}
	
	public function addMesh(value: MeshData):Void 
	{
		if (value != null && value.name != null && meshs[value.name] == null) 
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