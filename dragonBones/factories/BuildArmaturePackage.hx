package dragonBones.factories;

import dragonBones.objects.ArmatureData;
import dragonBones.objects.DragonBonesData;
import dragonBones.objects.SkinData;

/**
 * @private
 */
@:allow(dragonBones) @:final class BuildArmaturePackage
{
	public var dataName:String = null;
	public var textureAtlasName:String = null;
	public var data:DragonBonesData = null;
	public var armature:ArmatureData = null;
	public var skin:SkinData = null;
	
	private function new() {}
}