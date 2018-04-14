package dragonBones.geom;

import openfl.geom.Matrix;
import openfl.geom.Point;

/**
 * @language zh_CN
 * 2D 变换。
 * @version DragonBones 3.0
 */
@:allow(dragonBones) @:final class Transform
{
	/**
	 * @private
	 */
	private static function normalizeRadian(value:Float):Float
	{
		value = (value + Math.PI) % (Math.PI * 2.0);
		value += value > 0.0? -Math.PI: Math.PI;
		
		return value;
	}
	/**
	 * @private
	 */
	private static function transformPoint(matrix:Matrix, x:Float, y:Float, result:Point, delta:Bool = false):Void
	{
		result.x = matrix.a * x + matrix.c * y;
		result.y = matrix.b * x + matrix.d * y;
		
		if (!delta)
		{
			result.x += matrix.tx;
			result.y += matrix.ty;
		}
	}
	/**
	 * @language zh_CN
	 * 水平位移。
	 * @version DragonBones 3.0
	 */
	public var x:Float = 0.0;
	/**
	 * @language zh_CN
	 * 垂直位移。
	 * @version DragonBones 3.0
	 */
	public var y:Float = 0.0;
	/**
	 * @language zh_CN
	 * 水平倾斜。 (以弧度为单位)
	 * @version DragonBones 3.0
	 */
	public var skewX:Float = 0.0;
	/**
	 * @language zh_CN
	 * 垂直倾斜。 (以弧度为单位)
	 * @version DragonBones 3.0
	 */
	public var skewY:Float = 0.0;
	/**
	 * @language zh_CN
	 * 水平缩放。
	 * @version DragonBones 3.0
	 */
	public var scaleX:Float = 1.0;
	/**
	 * @language zh_CN
	 * 垂直缩放。
	 * @version DragonBones 3.0
	 */
	public var scaleY:Float = 1.0;
	/**
	 * @private
	 */
	private function new() {}
	/**
	 * @private
	 */
	private function toString():String 
	{
		return "[object dragonBones.geom.Transform] x:" + x + " y:" + y + " skewX:" + skewX * 180 / Math.PI + " skewY:" + skewY * 180 / Math.PI + " scaleX:" + scaleX + " scaleY:" + scaleY;
	}
	/**
	 * @private
	 */
	@:final public #if !js inline #end function copyFrom(value:Transform):Transform
	{
		x = value.x;
		y = value.y;
		skewX = value.skewX;
		skewY = value.skewY;
		scaleX = value.scaleX;
		scaleY = value.scaleY;
		
		return this;
	}
	/**
	 * @private
	 */
	@:final public #if !js inline #end function identity():Transform
	{
		x = y = skewX = skewY = 0.0;
		scaleX = scaleY = 1.0;
		
		return this;
	}
	/**
	 * @private
	 */
	@:final public #if !js inline #end function add(value:Transform):Transform
	{
		x += value.x;
		y += value.y;
		skewX += value.skewX;
		skewY += value.skewY;
		scaleX *= value.scaleX;
		scaleY *= value.scaleY;
		
		return this;
	}
	/**
	 * @private
	 */
	@:final public #if !js inline #end function minus(value:Transform):Transform
	{
		x -= value.x;
		y -= value.y;
		skewX = normalizeRadian(skewX - value.skewX);
		skewY = normalizeRadian(skewY - value.skewY);
		scaleX /= value.scaleX;
		scaleY /= value.scaleY;
		
		return this;
	}
	/**
	 * @private
	 */
	@:final public #if !js inline #end function fromMatrix(matrix:Matrix):Transform
	{
		var PI_Q:Float = Math.PI * 0.25;
		
		var backupScaleX:Float = scaleX, backupScaleY:Float = scaleY;
		
		x = matrix.tx;
		y = matrix.ty;
		
		//skewX = Math.atan2(-matrix.c, matrix.d);
		//skewY = Math.atan2(matrix.b, matrix.a);
		skewX = Math.atan(-matrix.c / matrix.d);
		skewY = Math.atan(matrix.b / matrix.a);
		if (skewX != skewX) 
		{
			skewX = 0.0;
		}
		
		if (skewY != skewY) 
		{
			skewY = 0.0;
		}
		
		// scaleY = (skewX > -PI_Q && skewX < PI_Q)? matrix.d / Math.cos(skewX): -matrix.c / Math.sin(skewX);
		if (skewX > -PI_Q && skewX < PI_Q)
		{
			scaleY = matrix.d / Math.cos(skewX);
		}
		else
		{
			scaleY = -matrix.c / Math.sin(skewX);
		}
		
		// scaleX = (skewY > -PI_Q && skewY < PI_Q)? matrix.a / Math.cos(skewY):  matrix.b / Math.sin(skewY);
		if (skewY > -PI_Q && skewY < PI_Q)
		{
			scaleX = matrix.a / Math.cos(skewY);
		}
		else
		{
			scaleX = matrix.b / Math.sin(skewY);
		}
		
		if (backupScaleX >= 0.0 && scaleX < 0.0)
		{
			scaleX = -scaleX;
			skewY = skewY - Math.PI;
		}
		
		if (backupScaleY >= 0.0 && scaleY < 0.0)
		{
			scaleY = -scaleY;
			skewX = skewX - Math.PI;
		}
		
		return this;
	}
	/**
	 * @language zh_CN
	 * 转换为矩阵。
	 * @version DragonBones 3.0
	 */
	@:final public #if !js inline #end function toMatrix(matrix:Matrix):Transform
	{
		if (skewX != 0.0 || skewY != 0.0) 
		{
			matrix.a = Math.cos(skewY);
			matrix.b = Math.sin(skewY);
			
			if (skewX == skewY) 
			{
				matrix.c = -matrix.b;
				matrix.d = matrix.a;
			}
			else 
			{
				matrix.c = -Math.sin(skewX);
				matrix.d = Math.cos(skewX);
			}
			
			if (scaleX != 1.0 || scaleY != 1.0) 
			{
				matrix.a *= scaleX;
				matrix.b *= scaleX;
				matrix.c *= scaleY;
				matrix.d *= scaleY;
			}
		}
		else 
		{
			matrix.a = scaleX;
			matrix.b = 0.0;
			matrix.c = 0.0;
			matrix.d = scaleY;
		}
		
		matrix.tx = x;
		matrix.ty = y;
		
		return this;
	}
	/**
	 * @language zh_CN
	 * 旋转。 (以弧度为单位)
	 * @version DragonBones 3.0
	 */
	@:final public var rotation(get, set):Float;
	private #if !js inline #end function get_rotation():Float
	{
		return skewY;
	}
	private #if !js inline #end function set_rotation(value:Float):Float
	{
		var dValue:Float = value - skewY;
		skewX += dValue;
		skewY += dValue;
		return value;
	}
}