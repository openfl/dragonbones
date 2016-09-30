package dragonBones.objects;

import openfl.geom.Point;

class SkeletonData
{
	public var name:String;
	
	private var _subTexturePivots:Map<String, Point>;

	public var armatureNames(get, null):Array<String>;
	public function get_armatureNames():Array<String>
	{
		var nameList:Array<String> = new Array<String>();
		for (armatureData in _armatureDataList)
		{
			nameList.push(armatureData.name);
		}
		return nameList;
	}
	
	private var _armatureDataList:Array<ArmatureData>;
	public var armatureDataList(get, null):Array<ArmatureData>;
	public function get_armatureDataList():Array<ArmatureData>
	{
		return _armatureDataList;
	}
	
	public function new()
	{
		_armatureDataList = new Array<ArmatureData>();
		_subTexturePivots = new Map<String, Point>();
	}
	
	public function dispose():Void
	{
		for (armatureData in _armatureDataList)
		{
			armatureData.dispose();
		}

		_armatureDataList = null;
		_subTexturePivots = null;
	}
	
	public function getArmatureData(armatureName:String):ArmatureData
	{
		var i:Int = _armatureDataList.length;
		while(i -- > 0)
		{
			if(_armatureDataList[i].name == armatureName)
			{
				return _armatureDataList[i];
			}
		}
		
		return null;
	}
	
	public function addArmatureData(armatureData:ArmatureData):Void
	{
		if(armatureData == null)
		{
			throw "ArgumentError";
		}
		
		if(_armatureDataList.indexOf(armatureData) < 0)
		{
			_armatureDataList.push(armatureData);
		}
		else
		{
			throw "ArgumentError";
		}
	}
	
	public function removeArmatureData(armatureData:ArmatureData):Void
	{
		var index:Int = _armatureDataList.indexOf(armatureData);
		if(index >= 0)
		{
			_armatureDataList.splice(index, 1);
		}
	}
	
	public function removeArmatureDataByName(armatureName:String):Void
	{
		var i:Int = _armatureDataList.length;
		while(i -- > 0)
		{
			if(_armatureDataList[i].name == armatureName)
			{
				_armatureDataList.splice(i, 1);
			}
		}
	}
	
	public function getSubTexturePivot(subTextureName:String):Point
	{
		return _subTexturePivots[subTextureName];
	}
	
	public function addSubTexturePivot(x:Float, y:Float, subTextureName:String):Point
	{
		var point:Point = _subTexturePivots[subTextureName];
		if(point != null)
		{
			point.x = x;
			point.y = y;
		}
		else
		{
			point = new Point(x, y);
			_subTexturePivots.set(subTextureName, point);
		}
		
		return point;
	}
	
	public function removeSubTexturePivot(subTextureName:String):Void
	{
		if(subTextureName != null)
		{
			 _subTexturePivots.remove(subTextureName);
		}
		else
		{
			for(subTextureName in _subTexturePivots.keys())
			{
				_subTexturePivots.remove(subTextureName);
			}
		}
	}
}
