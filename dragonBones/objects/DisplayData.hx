package dragonBones.objects;

import openfl.geom.Point;

import dragonBones.core.BaseObject;
import dragonBones.enums.DisplayType;
import dragonBones.geom.Transform;
import dragonBones.textures.TextureData;

/**
 * @private
 */
@:allow(dragonBones) class DisplayData extends BaseObject
{
	public var isRelativePivot:Bool;
	public var inheritAnimation:Bool;
	public var type:Int;
	public var name:String;
	public var path:String;
	public var share:String;
	public var pivot:Point = new Point();
	public var transform:Transform = new Transform();
	public var texture:TextureData;
	public var armature:ArmatureData;
	public var mesh:MeshData;
	public var boundingBox: BoundingBoxData;
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		if (boundingBox != null) 
		{
			boundingBox.returnToPool();
		}
		
		isRelativePivot = false;
		type = DisplayType.None;
		name = null;
		path = null;
		share = null;
		pivot.x = 0.0;
		pivot.y = 0.0;
		transform.identity();
		texture = null;
		armature = null;
		mesh = null;
		boundingBox = null;
	}
}