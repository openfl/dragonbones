package dragonBones.starling;

import dragonBones.textures.TextureData;

import starling.textures.SubTexture;

/**
 * @private
 */
@:final class StarlingTextureData extends TextureData
{
	public var texture:SubTexture = null;
	
	private function new() {}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		if (texture != null)
		{
			texture.dispose();
			texture = null;
		}
	}
}