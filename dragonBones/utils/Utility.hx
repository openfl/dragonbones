package dragonBones.utils;
import openfl.geom.Matrix;

@:allow(dragonBones) class Utility 
{
  private static var degree:Float = (180 / Math.PI);
	private static var radian:Float = (Math.PI / 180);
    
  /**
	 * @private
	 */
	private static inline function getAngle(matrix:Matrix):Float
	{
		var scaleX:Float = Math.sqrt((matrix.a * matrix.a) + (matrix.c * matrix.c));
		var sign:Float = Math.atan(-matrix.c / matrix.a);
		var rad:Float  = Math.acos(matrix.a / scaleX);
		var deg:Float  = rad * degree;

		var rotation:Float;

		if (deg > 90 && sign > 0)
		{
				rotation = (360 - deg) * radian;
		}
		else if (deg < 90 && sign < 0)
		{
				rotation = (360 - deg) * radian;
		}
		else
		{
				rotation = rad;
		}

		var rotationInDegree:Float = rotation * degree;

		return rotationInDegree;
	}
}