package dragonBones.objects
{
import openfl.geom.Point;

import dragonBones.core.DragonBones;

/**
 * @private
 */
public class TweenFrameData extends FrameData
{
	private static function _getCurvePoint(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float, t:Float, result: Point):Void
	{
		inline var l_t:Float = 1 - t;
		inline var powA:Float = l_t * l_t;
		inline var powB:Float = t * t;
		inline var kA:Float = l_t * powA;
		inline var kB:Float = 3.0 * t * powA;
		inline var kC:Float = 3.0 * l_t * powB;
		inline var kD:Float = t * powB;
		
		result.x = kA * x1 + kB * x2 + kC * x3 + kD * x4;
		result.y = kA * y1 + kB * y2 + kC * y3 + kD * y4;
	}
	
	public static function samplingEasingCurve(curve:Array, samples:Vector<Float>):Void
	{
		inline var curveCount:UInt = curve.length;
		inline var result:Point = new Point();
		
		var stepIndex:Int = -2;
		var l:UInt = samples.length;
		for (i in 0...l)
		{
			var t:Float = (i + 1) / (l + 1);
			while ((stepIndex + 6 < curveCount ? curve[stepIndex + 6] : 1) < t) // stepIndex + 3 * 2
			{
				stepIndex += 6;
			}
			
			inline var isInCurve:Bool = stepIndex >= 0 && stepIndex + 6 < curveCount;
			inline var x1:Float = isInCurve ? curve[stepIndex] : 0.0;
			inline var y1:Float = isInCurve ? curve[stepIndex + 1] : 0.0;
			inline var x2:Float = curve[stepIndex + 2];
			inline var y2:Float = curve[stepIndex + 3];
			inline var x3:Float = curve[stepIndex + 4];
			inline var y3:Float = curve[stepIndex + 5];
			inline var x4:Float = isInCurve ? curve[stepIndex + 6] : 1.0;
			inline var y4:Float = isInCurve ? curve[stepIndex + 7] : 1.0;
			
			var lower:Float = 0.0;
			var higher:Float = 1.0;
			while (higher - lower > 0.01) 
			{
				inline var percentage:Float = (higher + lower) / 2.0;
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
	
	public function TweenFrameData(self:TweenFrameData)
	{
		super(this);
		
		if (self != this)
		{
			throw new Error(DragonBones.ABSTRACT_CLASS_ERROR);
		}
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		tweenEasing = 0.0;
		curve = null;
	}
}
}