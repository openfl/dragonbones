package dragonBones.objects;

import openfl.geom.Point;
import openfl.Vector;

import dragonBones.core.DragonBones;

/**
 * @private
 */
@:allow(dragonBones) class TweenFrameData extends FrameData
{
	private static function _getCurvePoint(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float, t:Float, result: Point):Void
	{
		var l_t:Float = 1 - t;
		var powA:Float = l_t * l_t;
		var powB:Float = t * t;
		var kA:Float = l_t * powA;
		var kB:Float = 3.0 * t * powA;
		var kC:Float = 3.0 * l_t * powB;
		var kD:Float = t * powB;
		
		result.x = kA * x1 + kB * x2 + kC * x3 + kD * x4;
		result.y = kA * y1 + kB * y2 + kC * y3 + kD * y4;
	}
	
	public static function samplingEasingCurve(curve:Array<Float>, samples:Vector<Float>):Void
	{
		var curveCount:UInt = curve.length;
		var result:Point = new Point();
		
		var stepIndex:Int = -2;
		var l:UInt = samples.length;
		var t:Float, isInCurve:Bool, x1:Float, y1:Float, x2:Float, y2:Float;
		var x3:Float, y3:Float, x4:Float, y4:Float, lower:Float, higher:Float, percentage:Float;
		for (i in 0...l)
		{
			t = (i + 1) / (l + 1);
			while ((stepIndex + 6 < curveCount ? curve[stepIndex + 6] : 1) < t) // stepIndex + 3 * 2
			{
				stepIndex += 6;
			}
			
			isInCurve = stepIndex >= 0 && stepIndex + 6 < curveCount;
			x1 = isInCurve ? curve[stepIndex] : 0.0;
			y1 = isInCurve ? curve[stepIndex + 1] : 0.0;
			x2 = curve[stepIndex + 2];
			y2 = curve[stepIndex + 3];
			x3 = curve[stepIndex + 4];
			y3 = curve[stepIndex + 5];
			x4 = isInCurve ? curve[stepIndex + 6] : 1.0;
			y4 = isInCurve ? curve[stepIndex + 7] : 1.0;
			
			lower = 0.0;
			higher = 1.0;
			while (higher - lower > 0.01) 
			{
				percentage = (higher + lower) / 2.0;
				_getCurvePoint(x1, y1, x2, y2, x3, y3, x4, y4, percentage, result);
				if (t - result.x > 0.0) 
				{
					lower = percentage;
				} 
				else 
				{
					higher = percentage;
				}
			}
			
			samples[i] = result.y;
		}
	}
	
	public var tweenEasing:Float;
	public var curve:Vector<Float>;
	
	private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		tweenEasing = 0.0;
		curve = null;
	}
}