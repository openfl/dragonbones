package dragonBones.factorys;

import openfl.display.MovieClip;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

import dragonBones.Armature;
import dragonBones.Slot;
import dragonBones.display.NativeSlot;
import dragonBones.textures.ITextureAtlas;
import dragonBones.textures.NativeTextureAtlas;


/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0, Flash 10
* @langversion 3.0
* @version 2.0
*/

class NativeFactory extends BaseFactory
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
		var textureAtlas:NativeTextureAtlas = new NativeTextureAtlas(content, textureAtlasRawData, 1, false);
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
		var nativeTextureAtlas:NativeTextureAtlas = null;
		if(Std.is(textureAtlas, NativeTextureAtlas))
		{
			nativeTextureAtlas = cast(textureAtlas, NativeTextureAtlas);
		}

		if(nativeTextureAtlas != null)
		{
			var movieClip:MovieClip = nativeTextureAtlas.movieClip;
			if(useBitmapDataTexture && movieClip != null)
			{
				nativeTextureAtlas.movieClipToBitmapData();
			}

			if (useBitmapDataTexture  && movieClip != null && movieClip.totalFrames >= 3)
			{
				movieClip.gotoAndStop(movieClip.totalFrames);
				movieClip.gotoAndStop(fullName);
				if (movieClip.numChildren > 0)
				{
					try
					{
						var displaySWF:MovieClip = cast(movieClip.getChildAt(0), MovieClip);
						displaySWF.x = 0;
						displaySWF.y = 0;
						return displaySWF;
					}
					catch(e:String)
					{
						throw "Can not get the movie clip, please make sure the version of the resource compatible with app version!";
					}
				}
			}
			else if(nativeTextureAtlas.bitmapData != null)
			{
				var subTextureRegion:Rectangle = nativeTextureAtlas.getRegion(fullName);
				if (subTextureRegion != null)
				{
					var subTextureFrame:Rectangle = nativeTextureAtlas.getFrame(fullName);
					if(subTextureFrame != null)
					{
						pivotX += subTextureFrame.x;
						pivotY += subTextureFrame.y;
					}

					var displayShape:Shape = new Shape();
					BaseFactory._helpMatrix.a = 1;
					BaseFactory._helpMatrix.b = 0;
					BaseFactory._helpMatrix.c = 0;
					BaseFactory._helpMatrix.d = 1;
					BaseFactory._helpMatrix.scale(1 / nativeTextureAtlas.scale, 1 / nativeTextureAtlas.scale);
					BaseFactory._helpMatrix.tx = -pivotX - subTextureRegion.x;
					BaseFactory._helpMatrix.ty = -pivotY - subTextureRegion.y;

					displayShape.graphics.beginBitmapFill(nativeTextureAtlas.bitmapData, BaseFactory._helpMatrix, false, fillBitmapSmooth);
					displayShape.graphics.drawRect(-pivotX, -pivotY, subTextureRegion.width, subTextureRegion.height);

					return displayShape;
				}
			}
			else
			{
				throw "Error";
			}
		}
		return null;
	}
}
