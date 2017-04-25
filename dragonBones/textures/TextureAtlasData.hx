package dragonBones.textures;

import openfl.display.BitmapData;

import dragonBones.core.BaseObject;
import dragonBones.core.DragonBones;

/**
 * @language zh_CN
 * 贴图集数据。
 * @version DragonBones 3.0
 */
class TextureAtlasData extends BaseObject
{
	/**
	 * @language zh_CN
	 * 是否开启共享搜索。
	 * @see dragonBones.objects.ArmatureData
	 * @version DragonBones 4.5
	 */
	public var autoSearch:Bool;
	/**
	 * @language zh_CN
	 * 贴图集缩放系数。
	 * @version DragonBones 3.0
	 */
	public var scale:Float;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var width:Float;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var height:Float;
	/**
	 * @language zh_CN
	 * 贴图集名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @language zh_CN
	 * 贴图集图片路径。
	 * @version DragonBones 3.0
	 */
	public var imagePath:String;
	/**
	 * @private For AS.
	 */
	public var bitmapData:BitmapData;
	/**
	 * @private
	 */
	@:allow("dragonBones") private var textures:Map<String, TextureData> = new Map<String, TextureData>();
	/**
	 * @private
	 */
	@:allow("dragonBones") private function new() {}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		for (k in textures.keys())
		{
			textures[k].returnToPool();
			textures.remove(k);
		}
		
		autoSearch = false;
		scale = 1.0;
		width = 0.0;
		height = 0.0;
		//textures.clear();
		name = null;
		imagePath = null;
		
		if (bitmapData != null)
		{
			bitmapData.dispose();
			bitmapData = null;
		}
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function generateTexture():TextureData
	{
		throw new Error(DragonBones.ABSTRACT_METHOD_ERROR);
		return null;
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function addTexture(value:TextureData):Void
	{
		if (value != null && value.name != null && !textures.exists(value.name))
		{
			textures[value.name] = value;
			value.parent = this;
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function getTexture(name:String):TextureData
	{
		return textures[name];
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function copyFrom(value: TextureAtlasData):Void 
	{
		autoSearch = value.autoSearch;
		scale = value.scale;
		width = value.width;
		height = value.height;
		name = value.name;
		imagePath = value.imagePath;
		
		for (k in textures.keys())
		{
			textures[k].returnToPool();
			textures.remove(k);
		}
		
		var texture:TextureData;
		for (k in value.textures.keys()) 
		{
			texture = generateTexture();
			texture.copyFrom(value.textures[k]);
			textures[k] = texture;
		}
	}
}