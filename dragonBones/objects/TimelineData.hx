package dragonBones.objects;

import openfl.Vector;
	
import dragonBones.core.BaseObject;
import dragonBones.core.DragonBones;

/**
 * @private
 */
class TimelineData extends BaseObject
{
	public var scale:Float;
	/**
	 * @private
	 */
	public var offset:Float;
	/**
	 * @private
	 */
	public var frames:Vector<FrameData> = new Vector<FrameData>();
	/**
	 * @private
	 */
	private function new() {}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		scale = 1.0;
		offset = 0.0;
		
		var prevFrame:FrameData = null;
		var l:UInt = frames.length;
		var frame:FrameData;
		for (i in 0...l) // Find key frame data.
		{
			frame = frames[i];
			if (prevFrame != null && frame !== prevFrame)
			{
				prevFrame.returnToPool();
			}
			
			prevFrame = frame;
		}
		
		frames.fixed = false;
		frames.length = 0;
	}
}