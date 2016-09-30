package dragonBones.objects;

/** @private */
class Frame
{
	public var position:Int;
	public var duration:Int;

	public var action:String;
	public var event:String;
	public var sound:String;

	public function new()
	{
		position = 0;
		duration = 0;
	}

	public function dispose():Void
	{
	}
}
