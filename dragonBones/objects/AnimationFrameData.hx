package dragonBones.objects;

import openfl.Vector;
	
/**
 * @private
 */
@:final class AnimationFrameData extends FrameData
{
	
	public var actions:Vector<ActionData> = new Vector<ActionData>();
	public var events:Vector<EventData> = new Vector<EventData>();
	
	private function new() {}
	
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