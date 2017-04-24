package dragonBones.objects
{
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
	public inline var frames:Vector.<FrameData> = new Vector.<FrameData>();
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
		for (var i:UInt = 0, l:UInt = frames.length; i < l; ++i) // Find key frame data.
		{
			inline var frame:FrameData = frames[i];
			if (prevFrame && frame !== prevFrame)
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