package dragonBones.starling
{
import dragonBones.textures.TextureData;

import starling.textures.SubTexture;

/**
 * @private
 */
public final class StarlingTextureData extends TextureData
{
	public var texture:SubTexture = null;
	
	public function StarlingTextureData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		if (texture)
		{
			texture.dispose();
			texture = null;
		}
	}
}
}