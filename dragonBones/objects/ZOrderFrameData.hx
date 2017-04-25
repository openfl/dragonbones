package dragonBones.objects;

import openfl.Vector;
	
/**
 * @private
 */
@:final class ZOrderFrameData extends FrameData
{
	public inline var zOrder:Vector<Int> = new Vector<Int>();
	
	private function new() {}
	
	override private function _onClear():Void 
	{
		super._onClear();
		
		zOrder.length = 0;
	}
}