package dragonBones.flixel;

import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.display.BitmapData;
import dragonBones.textures.TextureData;

/**
 * @private
 */
@:allow(dragonBones) @:final class FlixelTextureData extends TextureData
{
	public var texture:BitmapData = null;
	@:keep private function new()
	{
		super();
	}
}