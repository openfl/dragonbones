package dragonBones.objects
{
	import openfl.Vector;
	
/**
 * @private
 */
public final class ZOrderFrameData extends FrameData
{
	public inline var zOrder:Vector<Int> = new Vector<Int>();
	
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