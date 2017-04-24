package dragonBones.objects
{
/**
 * @private
 */
public final class AnimationFrameData extends FrameData
{
	
	public inline var actions:Vector<ActionData> = new Vector<ActionData>();
	public inline var events:Vector<EventData> = new Vector<EventData>();
	
	public function AnimationFrameData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		var l:UInt = actions.length;
		for (i in 0...l)
		{
			actions[i].returnToPool();
		}
		
		l = events.length;
		for (i in 0...l)
		{
			events[i].returnToPool();
		}
		
		actions.length = 0;
		events.length = 0;
	}
}
}