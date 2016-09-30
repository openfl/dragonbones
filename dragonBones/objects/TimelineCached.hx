package dragonBones.objects;

import openfl.geom.Matrix;

class TimelineCached
{
	private var _timeline:Array<FrameCached>;
    public var timeline(get, null):Array<FrameCached>;
	public function get_timeline():Array<FrameCached>
	{
		return _timeline;
	}

	public function new()
	{
		_timeline = new Array<FrameCached>();
	}

	public function dispose():Void
	{
		var i:Int = _timeline.length;
		while(i -- > 0)
		{
			_timeline[i].dispose();
		}
		_timeline = null;
	}

	public function getFrame(framePosition:Int):FrameCached
	{
		return _timeline.length > framePosition?_timeline[framePosition]:null;
	}

	public function addFrame(transform:DBTransform, matrix:Matrix, framePosition:Int, frameDuration:Int):Void
	{
		var frame:FrameCached = new FrameCached();
		if(transform != null)
		{
			frame.transform = new DBTransform();
			frame.transform.copy(transform);
		}
		frame.matrix = new Matrix();
		frame.matrix.copyFrom(matrix);

		for(i in framePosition...(framePosition + frameDuration))
		{
			_timeline.push(frame);
		}
	}
}
