package dragonBones.objects
{
/**
 * @private
 */
public final class ZOrderFrameData extends FrameData
{
	public inline var zOrder:Vector.<int> = new Vector.<int>();
	
	public function ZOrderFrameData()
	{
		super(this);
	}
	
	override private function _onClear():Void 
	{
		super._onClear();
		
		zOrder.length = 0;
	}
}
}