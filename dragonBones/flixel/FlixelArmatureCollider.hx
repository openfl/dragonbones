package dragonBones.flixel;

import flixel.FlxObject;

class FlixelArmatureCollider extends FlxObject
{
	public var offsetX(default, set):Float = 0;
	public var offsetY(default, set):Float = 0;
	
	public function new(_x:Float = 0, _y:Float = 0, _width:Float = 0, _height:Float = 0, _offsetX:Float = 0, _offsetY:Float = 0)
	{
		super(_x, _y, _width, _height);
		offsetX = _offsetX;
	    offsetY = _offsetY;
	}

    private function set_offsetX(value:Float):Float
	{
		offsetX = value;
		return value;
	}
	
	private function set_offsetY(value:Float):Float
	{
		offsetY = value;
		return value;
	}
}