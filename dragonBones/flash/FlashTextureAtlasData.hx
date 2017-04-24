package dragonBones.flash
{
import openfl.display.BitmapData;

import dragonBones.core.BaseObject;
import dragonBones.textures.TextureAtlasData;
import dragonBones.textures.TextureData;

public final class FlashTextureAtlasData extends TextureAtlasData
{
	public var texture:BitmapData;
	/**
	 * @private
	 */
	public function FlashTextureAtlasData()
	{
		super(this);
	}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		super._onClear();
		
		if (texture)
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
		return BaseObject.borrowObject(FlashTextureData) as FlashTextureData;
	}
}
}