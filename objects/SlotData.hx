package dragonBones.objects;

/** @private */
class SlotData
{
	public var name:String;
	public var parent:String;
	public var zOrder:Float;
    public var blendMode:String;

	private var _displayDataList:Array<DisplayData>;
	public var displayDataList(get, null):Array<DisplayData>;
	public function get_displayDataList():Array<DisplayData>
	{
		return _displayDataList;
	}

	public function new()
	{
		_displayDataList = new Array<DisplayData>();
		zOrder = 0;
	}

	public function dispose():Void
	{
		var i:Int = _displayDataList.length;
		while(i -- > 0)
		{
			_displayDataList[i].dispose();
		}
		_displayDataList = null;
	}

	public function addDisplayData(displayData:DisplayData):Void
	{
		if(displayData == null)
		{
			throw "ArgumentError";
		}
		if (_displayDataList.indexOf(displayData) < 0)
		{
			_displayDataList.insert(0, displayData);
		}
		else
		{
			throw "ArgumentError";
		}
	}

	public function getDisplayData(displayName:String):DisplayData
	{
		var i:Int = _displayDataList.length;
		while(i -- > 0)
		{
			if(_displayDataList[i].name == displayName)
			{
				return _displayDataList[i];
			}
		}

		return null;
	}
}
