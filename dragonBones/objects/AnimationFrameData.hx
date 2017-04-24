package dragonBones.objects
{
/**
 * @private
 */
public final class AnimationFrameData extends FrameData
{
	
	public inline var actions:Vector.<ActionData> = new Vector.<ActionData>();
	public inline var events:Vector.<EventData> = new Vector.<EventData>();
	
	public function AnimationFrameData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		for (var i:UInt = 0, l:UInt = actions.length; i < l; ++i)
		{
			actions[i].returnToPool();
		}
		
		for (i = 0, l = events.length; i < l; ++i)
		{
			events[i].returnToPool();
		}
		
		actions.length = 0;
		events.length = 0;
	}
}
}