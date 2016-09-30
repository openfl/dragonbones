package dragonBones.factorys;

import dragonBones.textures.OpenFLTextureAtlas;
import openfl.display.MovieClip;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

import dragonBones.Armature;
import dragonBones.Slot;
import dragonBones.display.NativeSlot;
import dragonBones.textures.ITextureAtlas;



/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0, Flash 10
* @langversion 3.0
* @version 2.0
*/

class OpenFLFactory extends BaseFactory
{
/**
	 * If enable BitmapSmooth
	 */
	public var fillBitmapSmooth:Bool;

/**
	 * If use bitmapData Texture（When using dbswf，you can use vector element，if enable useBitmapDataTexture，dbswf will be force converted to BitmapData）
	 */
	public var useBitmapDataTexture:Bool;

	public function new()
	{
		super(this);
	}

/** @private */
	override public function generateTextureAtlas(content:Dynamic, textureAtlasRawData:Dynamic):ITextureAtlas
	{
		var textureAtlas:OpenFLTextureAtlas = new OpenFLTextureAtlas(content, textureAtlasRawData, 1, false);
		return textureAtlas;
	}

/** @private */
	override public function generateArmature():Armature
	{
		var display:Sprite = new Sprite();
		var armature:Armature = new Armature(display);
		return armature;
	}

/** @private */
	override public function generateSlot():Slot
	{
		var slot:Slot = new NativeSlot();
		return slot;
	}

/** @private */
	override public function generateDisplay(textureAtlas:Dynamic, fullName:String, pivotX:Float, pivotY:Float):Dynamic
	{
		var openflTextureAtlas:OpenFLTextureAtlas = null;
		if(Std.is(textureAtlas, OpenFLTextureAtlas))
		{
			openflTextureAtlas = cast(textureAtlas, OpenFLTextureAtlas);
		}

		if(openflTextureAtlas != null)
		{

			var displaySprite:Sprite = new Sprite();
			openflTextureAtlas.renderTexture(displaySprite, fullName, pivotX, pivotY);

			return displaySprite;
			/*
			var subTextureRegion:Rectangle = openflTextureAtlas.getRegion(fullName);
			if (subTextureRegion != null)
			{
				var subTextureFrame:Rectangle = openflTextureAtlas.getFrame(fullName);
				if(subTextureFrame != null)
				{
					pivotX += subTextureFrame.x;
					pivotY += subTextureFrame.y;
				}


				BaseFactory._helpMatrix.a = 1;
				BaseFactory._helpMatrix.b = 0;
				BaseFactory._helpMatrix.c = 0;
				BaseFactory._helpMatrix.d = 1;
				BaseFactory._helpMatrix.scale(1 / openflTextureAtlas.scale, 1 / openflTextureAtlas.scale);
				BaseFactory._helpMatrix.tx = -pivotX - subTextureRegion.x;
				BaseFactory._helpMatrix.ty = -pivotY - subTextureRegion.y;

				//openflTextureAtlas.tilesheet.drawTiles(displaySprite.graphics, [0, 0, 0], false);
				openflTextureAtlas.renderTexture(displaySprite, fullName);


			}
			*/

		}
		return null;
	}
}
