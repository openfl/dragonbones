package dragonBones.starling;

import dragonBones.textures.TextureData;

import starling.textures.SubTexture;

/**
 * @private
 */
@:allow(dragonBones) @:final class StarlingTextureData extends TextureData
{
	public var texture:SubTexture = null;
	
	private function new()
	{
		super();
	}
	
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