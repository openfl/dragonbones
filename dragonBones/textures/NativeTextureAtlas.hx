package dragonBones.textures;

/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0, Flash 10
* @langversion 3.0
* @version 2.0
*/
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.geom.Rectangle;

import dragonBones.objects.DataParser;

/**
 * The NativeTextureAtlas creates and manipulates TextureAtlas from traditional flash.display.DisplayObject.
 */
class NativeTextureAtlas implements ITextureAtlas
{
	/**
	 * @private
	 */
	public var _subTextureDataDic:Map<String, Dynamic>;
	/**
	 * @private
	 */
	public var _isDifferentConfig:Bool;
	/**
	 * @private
	 */
	public var _name:String;
	/**
	 * The name of this NativeTextureAtlas instance.
	 */
    public var name(get, null):String;
	public function get_name():String
	{
		return _name;
	}

	public var _movieClip:MovieClip;
	/**
	 * The MovieClip created by this NativeTextureAtlas instance.
	 */
    public var movieClip(get, null):MovieClip;
	public function get_movieClip():MovieClip
	{
		return _movieClip;
	}

	public var _bitmapData:BitmapData;
	/**
	 * The BitmapData created by this NativeTextureAtlas instance.
	 */
	public var bitmapData(get, null):BitmapData;
	public function get_bitmapData():BitmapData
	{
		return _bitmapData;
	}

	public var _scale:Float;
	/**
	 * @private
	 */
	public var scale(get, null):Float;
	public function get_scale():Float
	{
		return _scale;
	}
	/**
	 * Creates a new NativeTextureAtlas instance.
	 * @param texture A MovieClip or Bitmap.
	 * @param textureAtlasRawData The textureAtlas config data.
	 * @param textureScale A scale value (x and y axis)
	 * @param isDifferentConfig
	 */
	public function new(texture:Dynamic, textureAtlasRawData:Dynamic, textureScale:Float = 1, isDifferentConfig:Bool = false)
	{
		_scale = textureScale;
		_isDifferentConfig = isDifferentConfig;
		if (Std.is(texture, BitmapData))
		{
			_bitmapData = cast(texture, BitmapData);
		}
		else if (Std.is(texture, MovieClip))
		{
			_movieClip = cast(texture, MovieClip);
			_movieClip.stop();
		}
		parseData(textureAtlasRawData);
	}
	/**
	 * Clean up all resources used by this NativeTextureAtlas instance.
	 */
	public function dispose():Void
	{
		_movieClip = null;
		if (_bitmapData != null)
		{
			_bitmapData.dispose();
		}
		_bitmapData = null;
	}
	/**
	 * The area occupied by all assets related to that name.
	 * @param name The name of these assets.
	 * @return Rectangle The area occupied by all assets related to that name.
	 */
	public function getRegion(name:String):Rectangle
	{
		var textureData:TextureData = cast(_subTextureDataDic[name],TextureData);
		if(textureData != null)
		{
			return textureData.region;
		}

		return null;
	}

	public function getFrame(name:String):Rectangle
	{
		var textureData:TextureData = cast(_subTextureDataDic[name],TextureData);
		if(textureData != null)
		{
			return textureData.frame;
		}

		return null;
	}

	public function parseData(textureAtlasRawData:Dynamic):Void
	{
		var namedTextureAtlasData = DataParser.parseTextureAtlas(textureAtlasRawData, _isDifferentConfig ? _scale : 1);
		_name = namedTextureAtlasData.name;
		_subTextureDataDic = namedTextureAtlasData.textureAtlasData;
	}

	public function movieClipToBitmapData():Void
	{
		if (_bitmapData == null && _movieClip != null)
		{
			_movieClip.gotoAndStop(1);
			// TODO _bitmapData = new BitmapData(getNearest2N(_movieClip.width), getNearest2N(_movieClip.height), true, 0xFF00FF);
			_bitmapData.draw(_movieClip);
			_movieClip.gotoAndStop(_movieClip.totalFrames);
		}
	}

	private function getNearest2N(_n:UInt):UInt
	{
		return (_n & _n - 1 != 0) ? 1 << Std.string(_n).length:_n; // TODO
	}
}
