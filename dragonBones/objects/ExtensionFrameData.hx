package dragonBones.objects
{
/**
 * @private
 */
public final class ExtensionFrameData extends TweenFrameData
{
	public inline var tweens:Vector<Float> = new Vector<Float>();
	
	public function ExtensionFrameData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		tweens.fixed = false;
		tweens.length = 0;
	}
}
}