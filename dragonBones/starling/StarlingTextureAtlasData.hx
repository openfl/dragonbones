package dragonBones.starling;

import dragonBones.core.BaseObject;
import dragonBones.textures.TextureAtlasData;
import dragonBones.textures.TextureData;

import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

@:allow(dragonBones) @:final class StarlingTextureAtlasData extends TextureAtlasData
{
	public static function fromTextureAtlas(textureAtlas:TextureAtlas):StarlingTextureAtlasData
	{
		var textureAtlasData:StarlingTextureAtlasData = cast BaseObject.borrowObject(StarlingTextureAtlasData);
		var textureData:StarlingTextureData;
		for (textureName in textureAtlas.getNames())
		{
			textureData = cast textureAtlasData.generateTexture();
			textureData.name = textureName;
			textureData.texture = cast textureAtlas.getTexture(textureName);
			textureData.rotated = textureAtlas.getRotation(textureName);
			textureData.region.copyFrom(textureAtlas.getRegion(textureName));
			//textureData.frame = textureAtlas.getFrame(textureName);
			textureAtlasData.addTexture(textureData);
		}
		
		textureAtlasData.texture = textureAtlas.texture;
		textureAtlasData.scale = textureAtlas.texture.scale;
		
		return textureAtlasData;
	}
	/**
	 * @private
	 */
	private var disposeTexture:Bool;
	
	public var texture:Texture;
	/**
	 * @private
	 */
	private function new()
	{
		super();
	}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		super._onClear();
		
		if (texture != null)
		{
			if (disposeTexture)
			{
				disposeTexture = false;
				texture.dispose();
			}
			
			texture = null;
		}
		else
		{
			disposeTexture = false;
		}
	}
	/**
	 * @private
	 */
	override public function generateTexture():TextureData
	{
		return cast BaseObject.borrowObject(StarlingTextureData);
	}
}