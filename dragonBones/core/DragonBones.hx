package dragonBones.core;

@:allow(dragonBones) @:final class DragonBones
{
	/**
	 * @private
	 */
	private static var PI_D:Float = Math.PI * 2.0;
	/**
	 * @private
	 */
	private static var PI_H:Float = Math.PI / 2.0;
	/**
	 * @private
	 */
	private static var PI_Q:Float = Math.PI / 4.0;
	/**
	 * @private
	 */
	private static var ANGLE_TO_RADIAN:Float = Math.PI / 180.0;
	/**
	 * @private
	 */
	private static var RADIAN_TO_ANGLE:Float = 180.0 / Math.PI;
	/**
	 * @private
	 */
	private static inline var SECOND_TO_MILLISECOND:Float = 1000.0;
	/**
	 * @private
	 */
	private static inline var NO_TWEEN:Float = 100.0;
	/**
	 * @private
	 */
	private static var ABSTRACT_CLASS_ERROR:String = "Abstract class can not be instantiated.";
	/**
	 * @private
	 */
	private static var ABSTRACT_METHOD_ERROR:String = "Abstract method needs to be implemented in subclass.";
	
	public static inline var VERSION:String = "5.0.0";
	/**
	 * @private
	 */
	private static var debugDraw:Bool = false;
}