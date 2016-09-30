package dragonBones.objects;

class BoneData
{
	public var name:String;
	public var parent:String;
	public var length:Float;

	public var global:DBTransform;
	public var transform:DBTransform;

	public var inheritScale:Bool;
	public var inheritRotation:Bool;

	private var _areaDataList:Array<IAreaData>;
	public var areaDataList(get, null):Array<IAreaData>;
	public function get_areaDataList():Array<IAreaData>
	{
		return _areaDataList;
	}

	public function new()
	{
		length = 0;
		global = new DBTransform();
		transform = new DBTransform();
		inheritRotation = true;
		inheritScale = false;

		_areaDataList = new Array<IAreaData>();
	}

	public function dispose():Void
	{
		global = null;
		transform = null;

		if(_areaDataList != null)
		{
			for (areaData in _areaDataList)
			{
				areaData.dispose();
			}
			_areaDataList = null;
		}
	}

	public function getAreaData(areaName:String):IAreaData
	{
		if(areaName == null && _areaDataList.length > 0)
		{
			return _areaDataList[0];
		}
		var i:Int = _areaDataList.length;
		while(i -- > 0)
		{
			if(_areaDataList[i].name == areaName)
			{
				return _areaDataList[i];
			}
		}
		return null;
	}

	public function addAreaData(areaData:IAreaData):Void
	{
		if(areaData == null)
		{
			throw "ArgumentError";
		}

		if(_areaDataList.indexOf(areaData) < 0)
		{
			_areaDataList.push(areaData);
		}
	}
}
