package dragonBones.objects;

import openfl.Vector;
	
/**
 * @private
 */
@:allow(dragonBones) @:final class ZOrderFrameData extends FrameData
{
	public var zOrder:Vector<Int> = new Vector<Int>();
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void 
	{
		super._onClear();
		
		zOrder.length = 0;
	}
}