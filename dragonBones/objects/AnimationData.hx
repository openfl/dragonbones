package dragonBones.objects;

class AnimationData extends Timeline
{
	public var name:String;
	public var frameRate:UInt;
	public var fadeTime:Float;
	public var playTimes:Int;
	//use frame tweenEase, NaN
	//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
	public var tweenEasing:Float;
	public var autoTween:Bool;
	public var lastFrameDuration:Int;

	public var hideTimelineNameMap:Array<String>;

	private var _timelineList:Array<TransformTimeline>;
	public var timelineList(get, null):Array<TransformTimeline>;
	public function get_timelineList():Array<TransformTimeline>
	{
		return _timelineList;
	}

	public function new()
	{
		super();
		fadeTime = 0;
		playTimes = 0;
		autoTween = true;
		tweenEasing = Math.NaN;
		hideTimelineNameMap = new Array<String>();

		_timelineList = new Array<TransformTimeline>();
	}

	override public function dispose():Void
	{
		super.dispose();

		hideTimelineNameMap = null;

		for (timeline in _timelineList)
		{
			timeline.dispose();
		}
		_timelineList = null;
	}

	public function getTimeline(timelineName:String):TransformTimeline
	{
		var i:Int = _timelineList.length;
		while(i -- > 0)
		{
			if(_timelineList[i].name == timelineName)
			{
				return _timelineList[i];
			}
		}
		return null;
	}

	public function addTimeline(timeline:TransformTimeline):Void
	{
		if(timeline == null)
		{
			throw "ArgumentError";
		}

		if(_timelineList.indexOf(timeline) < 0)
		{
			_timelineList[_timelineList.length] = timeline;
		}
	}
}
