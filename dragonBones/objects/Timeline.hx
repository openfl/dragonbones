package dragonBones.objects;

class Timeline
{
	private var _frameList:Array<Frame>;
    public var frameList(get, null):Array<Frame>;
	public function get_frameList():Array<Frame>
	{
		return _frameList;
	}

	public var duration:Int;
	public var scale:Float;

	public function new()
	{
		_frameList = new Array<Frame>();
		duration = 0;
		scale = 1;
	}

	public function dispose():Void
	{
		var i:Int = _frameList.length;
		while(i -- > 0)
		{
			_frameList[i].dispose();
		}
		_frameList = null;
	}

	public function addFrame(frame:Frame):Void
	{
		if(frame == null)
		{
			throw "ArgumentError";
		}

		if(_frameList.indexOf(frame) < 0)
		{
			_frameList.push(frame);
		}
		else
		{
			throw "ArgumentError";
		}
	}
}

