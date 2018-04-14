package dragonBones.flixel;

import dragonBones.objects.ArmatureData;
import dragonBones.objects.DragonBonesData;
import dragonBones.objects.SkinData;

@:allow(dragonBones) @:final class FlixelBuildArmaturePackage
{
	public var dataName:String = null;
	public var textureAtlasName:String = null;
	public var data:DragonBonesData = null;
	public var armature:ArmatureData = null;
	public var skin:SkinData = null;
	public var flxArmatureGroup:FlixelArmatureGroup = null;
	
	public function new() {}
}
