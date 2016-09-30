package dragonBones.objects;

/** @private */
class SkinData
{
	public var name:String;

	private var _slotDataList:Array<SlotData>;
	public var slotDataList(get, null):Array<SlotData>;
	public function get_slotDataList():Array<SlotData>
	{
		return _slotDataList;
	}

	public function new()
	{
		_slotDataList = new Array<SlotData>();
	}

	public function dispose():Void
	{
		var i:Int = _slotDataList.length;
		while(i -- > 0)
		{
			_slotDataList[i].dispose();
		}
		_slotDataList = null;
	}

	public function getSlotData(slotName:String):SlotData
	{
		var i:Int = _slotDataList.length;
		while(i -- > 0)
		{
			if(_slotDataList[i].name == slotName)
			{
				return _slotDataList[i];
			}
		}
		return null;
	}

	public function addSlotData(slotData:SlotData):Void
	{
		if(slotData == null)
		{
			throw "ArgumentError";
		}

		if (_slotDataList.indexOf(slotData) < 0)
		{
			_slotDataList.push(slotData);
		}
		else
		{
			throw "ArgumentError";
		}
	}
}
