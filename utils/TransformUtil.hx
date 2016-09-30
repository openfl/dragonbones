package dragonBones.utils;

import openfl.geom.Matrix;

import dragonBones.objects.DBTransform;

/** @private */
class TransformUtil
{
	private static var HALF_PI:Float = Math.PI * 0.5;
	private static var DOUBLE_PI:Float = Math.PI * 2;

	//private static const _helpMatrix:Matrix = new Matrix();

	private static var _helpTransformMatrix:Matrix = new Matrix();
	private static var _helpParentTransformMatrix:Matrix = new Matrix();

	/*
	public static function transformPointWithParent(transform:DBTransform, parent:DBTransform):void
	{
		transformToMatrix(parent, _helpMatrix, true);
		_helpMatrix.invert();

		var x:Number = transform.x;
		var y:Number = transform.y;

		transform.x = _helpMatrix.a * x + _helpMatrix.c * y + _helpMatrix.tx;
		transform.y = _helpMatrix.d * y + _helpMatrix.b * x + _helpMatrix.ty;

		transform.skewX = formatRadian(transform.skewX - parent.skewX);
		transform.skewY = formatRadian(transform.skewY - parent.skewY);
	}
	*/
	public static function transformToMatrix(transform:DBTransform, matrix:Matrix, keepScale:Bool = false):Void
	{
		if(keepScale)
		{
			matrix.a = transform.scaleX * Math.cos(transform.skewY);
			matrix.b = transform.scaleX * Math.sin(transform.skewY);
			matrix.c = -transform.scaleY * Math.sin(transform.skewX);
			matrix.d = transform.scaleY * Math.cos(transform.skewX);
			matrix.tx = transform.x;
			matrix.ty = transform.y;
		}
		else
		{
			matrix.a = Math.cos(transform.skewY);
			matrix.b = Math.sin(transform.skewY);
			matrix.c = -Math.sin(transform.skewX);
			matrix.d = Math.cos(transform.skewX);
			matrix.tx = transform.x;
			matrix.ty = transform.y;
		}
	}

	public static function formatRadian(radian:Float):Float
	{
		//radian %= DOUBLE_PI;
		if (radian > Math.PI)
		{
			radian -= DOUBLE_PI;
		}
		if (radian < -Math.PI)
		{
			radian += DOUBLE_PI;
		}
		return radian;
	}

	public static function globalToLocal(transform:DBTransform, parent:DBTransform):Void
	{
		transformToMatrix(transform, _helpTransformMatrix, true);
		transformToMatrix(parent, _helpParentTransformMatrix, true);

		_helpParentTransformMatrix.invert();
		_helpTransformMatrix.concat(_helpParentTransformMatrix);

		matrixToTransform(_helpTransformMatrix, transform, transform.scaleX * parent.scaleX >= 0, transform.scaleY * parent.scaleY >= 0);
	}

	public static function matrixToTransform(matrix:Matrix, transform:DBTransform, scaleXF:Bool, scaleYF:Bool):Void
	{
		transform.x = matrix.tx;
		transform.y = matrix.ty;
		transform.scaleX = Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b) * (scaleXF ? 1 : -1);
		transform.scaleY = Math.sqrt(matrix.d * matrix.d + matrix.c * matrix.c) * (scaleYF ? 1 : -1);

		var skewXArray0 = 0.0, skewXArray1 = 0.0, skewXArray2 = 0.0, skewXArray3 = 0.0;
		skewXArray0 = Math.acos(matrix.d / transform.scaleY);
		skewXArray1 = -skewXArray0;
		skewXArray2 = Math.asin(-matrix.c / transform.scaleY);
		skewXArray3 = skewXArray2 >= 0 ? Math.PI - skewXArray2 : skewXArray2 - Math.PI;

        if(floatsEqual(skewXArray0, skewXArray2) || floatsEqual(skewXArray0, skewXArray3))
		{
			transform.skewX = skewXArray0;
		}
		else
		{
			transform.skewX = skewXArray1;
		}

		var skewYArray0 = 0.0, skewYArray1 = 0.0, skewYArray2 = 0.0, skewYArray3 = 0.0;
		skewYArray0 = Math.acos(matrix.a / transform.scaleX);
		skewYArray1 = -skewYArray0;
		skewYArray2 = Math.asin(matrix.b / transform.scaleX);
		skewYArray3 = skewYArray2 >= 0 ? Math.PI - skewYArray2 : skewYArray2 - Math.PI;

		if(floatsEqual(skewYArray0, skewYArray2) || floatsEqual(skewYArray0, skewYArray3))
		{
			transform.skewY = skewYArray0;
		}
		else
		{
			transform.skewY = skewYArray1;
		}

	}

    private static function toFixed(f:Float, len:Int):String {
	    return Std.string(f).substr(0, len);
    }

    private static function floatsEqual(a:Float, b:Float):Bool {
	    return Math.abs(a - b) < 0.0000000001;
    }
}
