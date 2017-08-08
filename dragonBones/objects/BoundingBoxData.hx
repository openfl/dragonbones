package dragonBones.objects;

import openfl.geom.Point;
import openfl.Vector;

import dragonBones.core.BaseObject;
import dragonBones.enums.BoundingBoxType;

/**
 * @language zh_CN
 * 自定义包围盒数据。
 * @version DragonBones 5.0
 */
@:allow(dragonBones) @:final class BoundingBoxData extends BaseObject
{
	/**
	 * Cohen–Sutherland algorithm https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
	 * ----------------------
	 * | 0101 | 0100 | 0110 |
	 * ----------------------
	 * | 0001 | 0000 | 0010 |
	 * ----------------------
	 * | 1001 | 1000 | 1010 |
	 * ----------------------
	 */
	private static inline var OutCode_InSide:UInt = 0; // 0000
	private static inline var OutCode_Left:UInt = 0; // 0001
	private static inline var OutCode_Right:UInt = 0; // 0010
	private static inline var OutCode_Top:UInt = 0; // 0100
	private static inline var OutCode_Bottom:UInt = 0; // 1000
	/**
	 * Compute the bit code for a point (x, y) using the clip rectangle
	 */
	private static function _computeOutCode(x:Float, y:Float, xMin:Float, yMin:Float, xMax:Float, yMax:Float): UInt 
	{
		var code:UInt = OutCode_InSide; // initialised as being inside of [[clip window]]
		
		if (x < xMin) // to the left of clip window
		{
			code |= OutCode_Left;
		}
		else if (x > xMax) // to the right of clip window
		{
			code |= OutCode_Right;
		}
		
		if (y < yMin) // below the clip window
		{
			code |= OutCode_Top;
		}
		else if (y > yMax) // above the clip window
		{
			code |= OutCode_Bottom;
		}
		
		return code;
	}
	/**
	 * @private
	 */
	private static function segmentIntersectsRectangle(
		xA:Float, yA:Float, xB:Float, yB:Float,
		xMin:Float, yMin:Float, xMax:Float, yMax:Float,
		intersectionPointA: Point = null,
		intersectionPointB: Point = null,
		normalRadians: Point = null
	):Int 
	{
		var inSideA:Bool = xA > xMin && xA < xMax && yA > yMin && yA < yMax;
		var inSideB:Bool = xB > xMin && xB < xMax && yB > yMin && yB < yMax;
		
		if (inSideA && inSideB) 
		{
			return -1;
		}
		
		var intersectionCount:Int = 0;
		var outcode0:UInt = BoundingBoxData._computeOutCode(xA, yA, xMin, yMin, xMax, yMax);
		var outcode1:UInt = BoundingBoxData._computeOutCode(xB, yB, xMin, yMin, xMax, yMax);
		
		while (true) 
		{
			if ((outcode0 | outcode1) == 0) // Bitwise OR is 0. Trivially accept and get out of loop
			{   
				intersectionCount = 2;
				break;
			}
			else if ((outcode0 & outcode1) != 0) // Bitwise AND is not 0. Trivially reject and get out of loop
			{
				break;
			}
			
			// failed both tests, so calculate the line segment to clip
			// from an outside point to an intersection with clip edge
			var x:Float = 0.0;
			var y:Float = 0.0;
			var normalRadian:Float = 0.0;
			
			// At least one endpoint is outside the clip rectangle; pick it.
			var outcodeOut:UInt = outcode0 != 0 ? outcode0 : outcode1;
			
			// Now find the intersection point;
			if (outcodeOut & OutCode_Top != 0) // point is above the clip rectangle
			{
				x = xA + (xB - xA) * (yMin - yA) / (yB - yA);
				y = yMin;
				
				if (normalRadians != null) 
				{
					normalRadian = -Math.PI * 0.5;
				}
			}
			else if (outcodeOut & OutCode_Bottom != 0) // point is below the clip rectangle
			{
				x = xA + (xB - xA) * (yMax - yA) / (yB - yA);
				y = yMax;
				
				if (normalRadians != null) 
				{
					normalRadian = Math.PI * 0.5;
				}
			}
			else if (outcodeOut & OutCode_Right != 0) // point is to the right of clip rectangle
			{
				y = yA + (yB - yA) * (xMax - xA) / (xB - xA);
				x = xMax;
				
				if (normalRadians != null) 
				{
					normalRadian = 0;
				}
			}
			else if (outcodeOut & OutCode_Left != 0) // point is to the left of clip rectangle
			{
				y = yA + (yB - yA) * (xMin - xA) / (xB - xA);
				x = xMin;
				
				if (normalRadians != null) 
				{
					normalRadian = Math.PI;
				}
			}
			
			// Now we move outside point to intersection point to clip
			// and get ready for next pass.
			if (outcodeOut == outcode0) 
			{
				xA = x;
				yA = y;
				outcode0 = BoundingBoxData._computeOutCode(xA, yA, xMin, yMin, xMax, yMax);
				
				if (normalRadians != null) 
				{
					normalRadians.x = normalRadian;
				}
			}
			else {
				xB = x;
				yB = y;
				outcode1 = BoundingBoxData._computeOutCode(xB, yB, xMin, yMin, xMax, yMax);
				
				if (normalRadians != null) 
				{
					normalRadians.y = normalRadian;
				}
			}
		}
		
		if (intersectionCount > 0) 
		{
			if (inSideA) 
			{
				intersectionCount = 2; // 10
				
				if (intersectionPointA != null) 
				{
					intersectionPointA.x = xB;
					intersectionPointA.y = yB;
				}
				
				if (intersectionPointB != null) 
				{
					intersectionPointB.x = xB;
					intersectionPointB.y = xB;
				}
				
				if (normalRadians != null) {
					normalRadians.x = normalRadians.y + Math.PI;
				}
			}
			else if (inSideB) {
				intersectionCount = 1; // 01
				
				if (intersectionPointA != null) {
					intersectionPointA.x = xA;
					intersectionPointA.y = yA;
				}
				
				if (intersectionPointB != null) {
					intersectionPointB.x = xA;
					intersectionPointB.y = yA;
				}
				
				if (normalRadians != null) {
					normalRadians.y = normalRadians.x + Math.PI;
				}
			}
			else {
				intersectionCount = 3; // 11
				if (intersectionPointA != null) {
					intersectionPointA.x = xA;
					intersectionPointA.y = yA;
				}
				
				if (intersectionPointB != null) {
					intersectionPointB.x = xB;
					intersectionPointB.y = yB;
				}
			}
		}
		
		return intersectionCount;
	}
	/**
	 * @private
	 */
	private static function segmentIntersectsEllipse(
		xA:Float, yA:Float, xB:Float, yB:Float,
		xC:Float, yC:Float, widthH:Float, heightH:Float,
		intersectionPointA: Point = null,
		intersectionPointB: Point = null,
		normalRadians: Point = null
	):Int 
	{
		var d:Float = widthH / heightH;
		var dd:Float = d * d;
		
		yA *= d;
		yB *= d;
		
		var dX:Float = xB - xA;
		var dY:Float = yB - yA;
		var lAB:Float = Math.sqrt(dX * dX + dY * dY);
		var xD:Float = dX / lAB;
		var yD:Float = dY / lAB;
		var a:Float = (xC - xA) * xD + (yC - yA) * yD;
		var aa:Float = a * a;
		var ee:Float = xA * xA + yA * yA;
		var rr:Float = widthH * widthH;
		var dR:Float = rr - ee + aa;
		var intersectionCount:Int = 0;
		
		if (dR >= 0) 
		{
			var dT:Float = Math.sqrt(dR);
			var sA:Float = a - dT;
			var sB:Float = a + dT;
			var inSideA:Int = sA < 0.0 ? -1 : (sA <= lAB ? 0 : 1);
			var inSideB:Int = sB < 0.0 ? -1 : (sB <= lAB ? 0 : 1);
			var sideAB:Int = inSideA * inSideB;
			
			if (sideAB < 0) 
			{
				return -1;
			}
			else if (sideAB == 0) 
			{
				if (inSideA == -1) 
				{
					intersectionCount = 2; // 10
					xB = xA + sB * xD;
					yB = (yA + sB * yD) / d;
					
					if (intersectionPointA != null) 
					{
						intersectionPointA.x = xB;
						intersectionPointA.y = yB;
					}
					
					if (intersectionPointB != null) 
					{
						intersectionPointB.x = xB;
						intersectionPointB.y = yB;
					}
					
					if (normalRadians != null) 
					{
						normalRadians.x = Math.atan2(yB / rr * dd, xB / rr);
						normalRadians.y = normalRadians.x + Math.PI;
					}
				}
				else if (inSideB == 1) 
				{
					intersectionCount = 1; // 01
					xA = xA + sA * xD;
					yA = (yA + sA * yD) / d;
					
					if (intersectionPointA != null) 
					{
						intersectionPointA.x = xA;
						intersectionPointA.y = yA;
					}
					
					if (intersectionPointB != null) 
					{
						intersectionPointB.x = xA;
						intersectionPointB.y = yA;
					}
					
					if (normalRadians != null) 
					{
						normalRadians.x = Math.atan2(yA / rr * dd, xA / rr);
						normalRadians.y = normalRadians.x + Math.PI;
					}
				}
				else 
				{
					intersectionCount = 3; // 11
					
					if (intersectionPointA != null) 
					{
						intersectionPointA.x = xA + sA * xD;
						intersectionPointA.y = (yA + sA * yD) / d;
						
						if (normalRadians != null) 
						{
							normalRadians.x = Math.atan2(intersectionPointA.y / rr * dd, intersectionPointA.x / rr);
						}
					}
					
					if (intersectionPointB != null) 
					{
						intersectionPointB.x = xA + sB * xD;
						intersectionPointB.y = (yA + sB * yD) / d;
						
						if (normalRadians != null) 
						{
							normalRadians.y = Math.atan2(intersectionPointB.y / rr * dd, intersectionPointB.x / rr);
						}
					}
				}
			}
		}
		
		return intersectionCount;
	}
	/**
	 * @private
	 */
	private static function segmentIntersectsPolygon(
		xA:Float, yA:Float, xB:Float, yB:Float,
		vertices: Vector<Float>,
		intersectionPointA: Point = null,
		intersectionPointB: Point = null,
		normalRadians: Point = null
	):Int
	{
		if (xA == xB)
		{
			xA = xB + 0.01;
		}
		
		if (yA == yB)
		{
			yA = yB + 0.01;
		}
		
		var l:UInt = vertices.length;
		var dXAB:Float = xA - xB;
		var dYAB:Float = yA - yB;
		var llAB:Float = xA * yB - yA * xB;
		var intersectionCount:Int = 0;
		var xC:Float = vertices[l - 2];
		var yC:Float = vertices[l - 1];
		var dMin:Float = 0.0;
		var dMax:Float = 0.0;
		var xMin:Float = 0.0;
		var yMin:Float = 0.0;
		var xMax:Float = 0.0;
		var yMax:Float = 0.0;
		
		var i:UInt = 0;
		var xD:Float, yD:Float, dXCD:Float, dYCD:Float, llCD:Float, ll:Float, x:Float;
		var y:Float, d:Float;
		
		while (i < l)
		{
			xD = vertices[i];
			yD = vertices[i + 1];
			
			if (xC == xD) 
			{
				xC = xD + 0.01;
			}
			
			if (yC == yD) 
			{
				yC = yD + 0.01;
			}
			
			dXCD = xC - xD;
			dYCD = yC - yD;
			llCD = xC * yD - yC * xD;
			ll = dXAB * dYCD - dYAB * dXCD;
			x = (llAB * dXCD - dXAB * llCD) / ll;
			
			if (((x >= xC && x <= xD) || (x >= xD && x <= xC)) && (dXAB == 0 || (x >= xA && x <= xB) || (x >= xB && x <= xA))) 
			{
				y = (llAB * dYCD - dYAB * llCD) / ll;
				if (((y >= yC && y <= yD) || (y >= yD && y <= yC)) && (dYAB == 0 || (y >= yA && y <= yB) || (y >= yB && y <= yA))) 
				{
					if (intersectionPointB != null) 
					{
						d = x - xA;
						if (d < 0.0) 
						{
							d = -d;
						}
						
						if (intersectionCount == 0) 
						{
							dMin = d;
							dMax = d;
							xMin = x;
							yMin = y;
							xMax = x;
							yMax = y;
							
							if (normalRadians != null) 
							{
								normalRadians.x = Math.atan2(yD - yC, xD - xC) - Math.PI * 0.5;
								normalRadians.y = normalRadians.x;
							}
						}
						else 
						{
							if (d < dMin) 
							{
								dMin = d;
								xMin = x;
								yMin = y;
								
								if (normalRadians != null) 
								{
									normalRadians.x = Math.atan2(yD - yC, xD - xC) - Math.PI * 0.5;
								}
							}
							
							if (d > dMax) 
							{
								dMax = d;
								xMax = x;
								yMax = y;
								
								if (normalRadians != null) 
								{
									normalRadians.y = Math.atan2(yD - yC, xD - xC) - Math.PI * 0.5;
								}
							}
						}
						
						intersectionCount++;
					}
					else 
					{
						xMin = x;
						yMin = y;
						xMax = x;
						yMax = y;
						intersectionCount++;
						
						if (normalRadians != null) 
						{
							normalRadians.x = Math.atan2(yD - yC, xD - xC) - Math.PI * 0.5;
							normalRadians.y = normalRadians.x;
						}
						
						i += 2;
						break;
					}
				}
			}
			
			xC = xD;
			yC = yD;
			
			i += 2;
		}
		
		if (intersectionCount == 1) 
		{
			if (intersectionPointA != null) 
			{
				intersectionPointA.x = xMin;
				intersectionPointA.y = yMin;
			}
			
			if (intersectionPointB != null) 
			{
				intersectionPointB.x = xMin;
				intersectionPointB.y = yMin;
			}
			
			if (normalRadians != null) 
			{
				normalRadians.y = normalRadians.x + Math.PI;
			}
		}
		else if (intersectionCount > 1) 
		{
			intersectionCount++;
			
			if (intersectionPointA != null) 
			{
				intersectionPointA.x = xMin;
				intersectionPointA.y = yMin;
			}
			
			if (intersectionPointB != null) 
			{
				intersectionPointB.x = xMax;
				intersectionPointB.y = yMax;
			}
		}
		
		return intersectionCount;
	}
	/**
	 * @language zh_CN
	 * 包围盒类型。
	 * @see dragonBones.enums.BoundingBoxType
	 * @version DragonBones 5.0
	 */
	public var type:Int;
	/**
	 * @language zh_CN
	 * 包围盒颜色。
	 * @version DragonBones 5.0
	 */
	public var color: UInt;
	
	public var x:Float; // Polygon min x.
	public var y:Float; // Polygon min y.
	public var width:Float; // Polygon max x.
	public var height:Float; // Polygon max y.
	/**
	 * @language zh_CN
	 * 自定义多边形顶点。
	 * @version DragonBones 5.0
	 */
	public var vertices: Vector<Float> = new Vector<Float>();
	/**
	 * @private
	 */
	@:keep private function new()
	{
		super();
	}
	/**
	 * @private
	 */
	override private function _onClear():Void 
	{
		type = BoundingBoxType.None;
		color = 0x000000;
		x = 0.0;
		y = 0.0;
		width = 0.0;
		height = 0.0;
		vertices.fixed = false;
		vertices.length = 0;
	}
	/**
	 * @language zh_CN
	 * 是否包含点。
	 * @version DragonBones 5.0
	 */
	public function containsPoint(pX:Float, pY:Float):Bool 
	{
		var isInSide:Bool = false;
		
		if (type == BoundingBoxType.Polygon) 
		{
			if (pX >= x && pX <= width && pY >= y && pY <= height) 
			{
				var i:UInt = 0, l:UInt = vertices.length, iP:UInt = l - 2;
				var yA:Float, yB:Float, xA:Float, xB:Float;
				while (i < l)
				{
					yA = vertices[iP + 1];
					yB = vertices[i + 1];
					if ((yB < pY && yA >= pY) || (yA < pY && yB >= pY)) 
					{
						xA = vertices[iP];
						xB = vertices[i];
						if ((pY - yB) * (xA - xB) / (yA - yB) + xB < pX) 
						{
							isInSide = !isInSide;
						}
					}
					
					iP = i;
					i += 2;
				}
			}
		}
		else 
		{
			var widthH = width * 0.5;
			if (pX >= -widthH && pX <= widthH) 
			{
				var heightH:Float = height * 0.5;
				if (pY >= -heightH && pY <= heightH) 
				{
					if (type == BoundingBoxType.Ellipse) 
					{
						pY *= widthH / heightH;
						isInSide = Math.sqrt(pX * pX + pY * pY) <= widthH;
					}
					else {
						isInSide = true;
					}
				}
			}
		}
		
		return isInSide;
	}
	/**
	 * @language zh_CN
	 * 是否与线段相交。
	 * @version DragonBones 5.0
	 */
	public function intersectsSegment(
		xA:Float, yA:Float, xB:Float, yB:Float,
		intersectionPointA: Point = null,
		intersectionPointB: Point = null,
		normalRadians: Point = null
	):Int 
	{
		var intersectionCount:Int = 0;
		
		switch (type) 
		{
			case BoundingBoxType.Rectangle:
				var widthH:Float = width * 0.5;
				var heightH:Float = height * 0.5;
				intersectionCount = segmentIntersectsRectangle(
					xA, yA, xB, yB,
					-widthH, -heightH, widthH, heightH,
					intersectionPointA, intersectionPointB, normalRadians
				);
			
			case BoundingBoxType.Ellipse:
				intersectionCount = segmentIntersectsEllipse(
					xA, yA, xB, yB,
					0.0, 0.0, width * 0.5, height * 0.5,
					intersectionPointA, intersectionPointB, normalRadians
				);
			
			case BoundingBoxType.Polygon:
				if (segmentIntersectsRectangle(xA, yA, xB, yB, x, y, width, height, null, null) != 0) 
				{
					intersectionCount = segmentIntersectsPolygon(
						xA, yA, xB, yB,
						vertices,
						intersectionPointA, intersectionPointB, normalRadians
					);
				}
			
			default:
		}
		
		return intersectionCount;
	}
}