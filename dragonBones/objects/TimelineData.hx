package dragonBones.objects
{
	import openfl.Vector;
	
import dragonBones.core.BaseObject;
import dragonBones.core.DragonBones;

/**
 * @private
 */
public class TimelineData extends BaseObject
{
	public var scale:Float;
	/**
	 * @private
	 */
	public var offset:Float;
	/**
	 * @private
	 */
	public inline var frames:Vector<FrameData> = new Vector<FrameData>();
	/**
	 * @private
	 */
	public function TimelineData(self:TimelineData)
	{
		super(this);
		
		if (self != this)
		{
			throw new Error(DragonBones.ABSTRACT_CLASS_ERROR);
		}
	}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		scale = 1.0;
		offset = 0.0;
		
		var prevFrame:FrameData = null;
		var l:UInt = frames.length;
		for (i in 0...l) // Find key frame data.
		{
			inline var frame:FrameData = frames[i];
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
}