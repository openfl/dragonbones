package dragonBones.textures;

import flash.display.BitmapData;
import dragonBones.objects.DataParser;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
/**
	 * The StarlingTextureAtlas creates and manipulates TextureAtlas from starling.display.DisplayObject.
	 */
class StarlingTextureAtlas extends TextureAtlas implements ITextureAtlas
{
    public var name(get, never):String;

    public var bitmapData(get, set):BitmapData;
    public function get_bitmapData():BitmapData {
        return _bitmapData;
    }
    public function set_bitmapData(bmd:BitmapData):BitmapData {
        _bitmapData = bmd;
        return _bitmapData;
    }
    private var _bitmapData:BitmapData;
    /**
		 * @private
		 */
    private var _subTextureDic:Dynamic;
    /**
		 * @private
		 */
    private var _isDifferentConfig:Bool;
    /**
		 * @private
		 */
    private var _scale:Float;
    /**
		 * @private
		 */
    private var _name:String;
    /**
		 * The name of this StarlingTextureAtlas instance.
		 */
    public function get_name():String
    {
        return _name;
    }
    /**
		 * Creates a new StarlingTextureAtlas instance.
		 * @param texture A texture instance.
		 * @param textureAtlasRawData A textureAtlas config data
		 * @param isDifferentXML
		 */
    public function new(texture:Texture, textureAtlasRawData:Dynamic, isDifferentConfig:Bool = false)
    {
        super(texture, null);
        if (texture != null)
        {
            _scale = texture.scale;
            _isDifferentConfig = isDifferentConfig;
        }
        _subTextureDic = { };
        parseData(textureAtlasRawData);
    }
    /**
		 * Clean up all resources used by this StarlingTextureAtlas instance.
		 */
    override public function dispose():Void
    {
        super.dispose();
        /*
        for (subTexture in _subTextureDic)
        {
            subTexture.dispose();
        }
        */
        _subTextureDic = null;
        
        if (_bitmapData != null)
        {
            _bitmapData.dispose();
        }
        _bitmapData = null;
    }
    
    /**
		 * Get the Texture with that name.
		 * @param name The name ofthe Texture instance.
		 * @return The Texture instance.
		 */
    override public function getTexture(name:String):Texture
    {
        var texture:Texture = Reflect.field(_subTextureDic, name);
        if (texture == null)
        {
            texture = super.getTexture(name);
            if (texture != null)
            {
                Reflect.setField(_subTextureDic, name, texture);
            }
        }
        return texture;
    }
    /**
		 * @private
		 */
    private function parseData(textureAtlasRawData:Dynamic):Void
    {
        var textureAtlasData:Dynamic = DataParser.parseTextureAtlas(textureAtlasRawData, (_isDifferentConfig) ? _scale:1);
        _name = textureAtlasData.name;
        var actualAtlas:Map<String, TextureData> = textureAtlasData.textureAtlasData;
        //This is an intentional compilation error. See the README for handling the delete keyword
        //delete textureAtlasData.__name;
        for (subTextureName in actualAtlas.keys())
        {
            var textureData:TextureData = actualAtlas[subTextureName];
            //, textureData.rotated
            this.addRegion(subTextureName, textureData.region, textureData.frame);
        }
    }
}
