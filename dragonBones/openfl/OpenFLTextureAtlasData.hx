package dragonBones.openfl;

import openfl.display.BitmapData;

import dragonBones.core.BaseObject;
import dragonBones.textures.TextureAtlasData;
import dragonBones.textures.TextureData;

@:final class OpenFLTextureAtlasData extends TextureAtlasData
{
	public var texture:BitmapData;
	/**
	 * @private
	 */
	private function new() {}
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
		return cast BaseObject.borrowObject(OpenFLTextureData);
	}
}