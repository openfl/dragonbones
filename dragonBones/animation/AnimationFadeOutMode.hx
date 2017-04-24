package dragonBones.animation
{
/**
 * @language zh_CN
 * 动画混合的淡出方式。
 * @version DragonBones 4.5
 */
public final class AnimationFadeOutMode
{
	/**
	 * @language zh_CN
	 * 不淡出动画。
	 * @version DragonBones 4.5
	 */
	public static inline var None:Int = 0;
	/**
	 * @language zh_CN
	 * 淡出同层的动画。
	 * @version DragonBones 4.5
	 */
	public static inline var SameLayer:Int = 1;
	/**
	 * @language zh_CN
	 * 淡出同组的动画。
	 * @version DragonBones 4.5
	 */
	public static inline var SameGroup:Int = 2;
	/**
	 * @language zh_CN
	 * 淡出同层并且同组的动画。
	 * @version DragonBones 4.5
	 */
	public static inline var SameLayerAndGroup:Int = 3;
	/**
	 * @language zh_CN
	 * 淡出所有动画。
	 * @version DragonBones 4.5
	 */
	public static inline var All:Int = 4;
}
}