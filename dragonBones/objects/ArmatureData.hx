package dragonBones.objects;

typedef LevelBoneData = {
	var level:Int;
    var boneData:BoneData;
};

/** @private */
class ArmatureData
{
	public var name:String;
	
	private var _boneDataList:Array<BoneData>;
	public var boneDataList(get, null):Array<BoneData>;
	public function get_boneDataList():Array<BoneData>
	{
		return _boneDataList;
	}
	
	private var _skinDataList:Array<SkinData>;
	public var skinDataList(get, null):Array<SkinData>;
	public function get_skinDataList():Array<SkinData>
	{
		return _skinDataList;
	}
	
	private var _animationDataList:Array<AnimationData>;
	public var animationDataList(get, null):Array<AnimationData>;
	public function get_animationDataList():Array<AnimationData>
	{
		return _animationDataList;
	}
	
	private var _areaDataList:Array<IAreaData>;
	public var areaDataList(get, null):Array<IAreaData>;
	public function get_areaDataList():Array<IAreaData>
	{
		return _areaDataList;
	}
	
	public function new()
	{
		_boneDataList = new Array<BoneData>();
		_skinDataList = new Array<SkinData>();
		_animationDataList = new Array<AnimationData>();
		
		_areaDataList = new Array<IAreaData>();
	}
	
	public function dispose():Void
	{
		var i:Int = _boneDataList.length;
		while(i -- > 0)
		{
			_boneDataList[i].dispose();
		}
		i = _skinDataList.length;
		while(i -- > 0)
		{
			_skinDataList[i].dispose();
		}
		i = _animationDataList.length;
		while(i -- > 0)
		{
			_animationDataList[i].dispose();
		}

		_boneDataList = null;
		_skinDataList = null;
		_animationDataList = null;
	}
	
	public function getBoneData(boneName:String):BoneData
	{
		var i:Int = _boneDataList.length;
		while(i -- > 0)
		{
			if(_boneDataList[i].name == boneName)
			{
				return _boneDataList[i];
			}
		}
		return null;
	}
	
	public function getSkinData(skinName:String):SkinData
	{
		if(skinName == null && _skinDataList.length > 0)
		{
			return _skinDataList[0];
		}
		var i:Int = _skinDataList.length;
		while(i -- > 0)
		{
			if(_skinDataList[i].name == skinName)
			{
				return _skinDataList[i];
			}
		}
		
		return null;
	}
	
	public function getAnimationData(animationName:String):AnimationData
	{
		var i:Int = _animationDataList.length;
		while(i -- > 0)
		{
			if(_animationDataList[i].name == animationName)
			{
				return _animationDataList[i];
			}
		}
		return null;
	}
	
	public function addBoneData(boneData:BoneData):Void
	{
		if(boneData == null)
		{
			throw "ArgumentError";
		}
		
		if (_boneDataList.indexOf(boneData) < 0)
		{
			_boneDataList.push(boneData);
		}
		else
		{
			throw "ArgumentError";
		}
	}
	
	public function addSkinData(skinData:SkinData):Void
	{
		if(skinData == null)
		{
			throw "ArgumentError";
		}
		
		if(_skinDataList.indexOf(skinData) < 0)
		{
			_skinDataList.push(skinData);
		}
		else
		{
			throw "ArgumentError";
		}
	}
	
	public function addAnimationData(animationData:AnimationData):Void
	{
		if(animationData == null)
		{
			throw "ArgumentError";
		}
		
		if(_animationDataList.indexOf(animationData) < 0)
		{
			_animationDataList.push(animationData);
		}
	}
	
	public function sortBoneDataList():Void
	{
		var i:Int = _boneDataList.length;
		if(i == 0)
		{
			return;
		}
		
		var helpArray:Array<LevelBoneData> = new Array<LevelBoneData>();
		while(i -- > 0)
		{
			var boneData:BoneData = _boneDataList[i];
			var level:Int = 0;
			var parentData:BoneData = boneData;
			while(parentData != null)
			{
				level ++;
				parentData = getBoneData(parentData.parent);
			}
			helpArray[i] = {level: level, boneData: boneData};
		}

		// TODO
		//helpArray.sortOn("0", Array.NUMERIC);
		helpArray.sort(function(a, b):Int {
		    return a.level - b.level;
		});
		
		i = helpArray.length;
		while(i -- > 0)
		{
			_boneDataList[i] = helpArray[i].boneData;
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
