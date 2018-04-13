package dragonBones.flixel;

import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.display.BitmapData;

import dragonBones.core.BaseObject;
import dragonBones.textures.TextureAtlasData;
import dragonBones.textures.TextureData;

@:allow(dragonBones) @:final class FlixelTextureAtlasData extends TextureAtlasData
{
	public var texture:BitmapData;
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
		super._onClear();
		
		if (texture != null)
		{
			texture.dispose();
			texture = null;
		}
	}
	/**
	 * @private
	 */
	override public function generateTexture():TextureData
	{
		return cast BaseObject.borrowObject(FlixelTextureData);
	}
}