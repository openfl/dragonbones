package dragonBones.objects;

import dragonBones.utils.BytesType;
import dragonBones.utils.ConstValues;
import openfl.utils.ByteArray;

typedef NamedTextureAtlasData = {
	var name:String;
    var textureAtlasData:Map<String, Dynamic>;
};

class DataParser
{
	/**
	 * Compress all data into a ByteArray for serialization.
	 * @param The DragonBones data.
	 * @param The TextureAtlas data.
	 * @param The ByteArray representing the map.
	 * @return ByteArray. A DragonBones compatible ByteArray.
	 */
	public static function compressData(dragonBonesData:Dynamic, textureAtlasData:Dynamic, textureDataBytes:ByteArray):ByteArray
	{
		var retult:ByteArray = new ByteArray();
		retult.writeBytes(textureDataBytes);

		var dataBytes:ByteArray = new ByteArray();
		dataBytes.writeUTF(textureAtlasData);
		dataBytes.compress();

		retult.position = retult.length;
		retult.writeBytes(dataBytes);
		retult.writeInt(dataBytes.length);

		//dataBytes.length = 0;
		dataBytes.writeUTF(dragonBonesData);
		dataBytes.compress();

		retult.position = retult.length;
		retult.writeBytes(dataBytes);
		retult.writeInt(dataBytes.length);

		return retult;
	}

	/**
	 * Decompress a compatible DragonBones data.
	 * @param compressedByteArray The ByteArray to decompress.
	 * @return A DecompressedData instance.
	 */
	public static function decompressData(bytes:ByteArray):DecompressedData
	{
		var dataType:String = BytesType.getType(bytes);
		switch (dataType)
		{
			//case BytesType.SWF:
			case BytesType.PNG:
			//case BytesType.JPG:
			//case BytesType.ATF:
				var dragonBonesData:Dynamic;
				var textureAtlasData:Dynamic;
				try
				{
					var bytesCopy:ByteArray = new ByteArray();
					bytesCopy.writeBytes(bytes);
					bytes = bytesCopy;

					bytes.position = bytes.length - 4;
					var strSize:Int = bytes.readInt();
					var position:UInt = bytes.length - 4 - strSize;

					var dataBytes:ByteArray = new ByteArray();
					dataBytes.writeBytes(bytes, position, strSize);
					dataBytes.uncompress();

					//var obj = dataBytes.readObject();
					//dataBytes.position = 0;
/*
					function toHexString(d:ByteArray) {
						var out:String = "";

						for (i in 0...d.length) {
							var c = d.readByte();
							if (c < 0x20) {
								out += "0x" + StringTools.hex(c, 2);
							}
							else {
								var utf8 = new haxe.Utf8();
								utf8.addChar(c);
								out += utf8.toString();
							}
						}
						return out;
					}

					trace(toHexString(dataBytes));
*/
					//bytes.length = position;
					var endData = position;

#if flash
				var bytesInput = new haxe.io.BytesInput(haxe.io.Bytes.ofData(dataBytes));
#else
				var bytesInput = new haxe.io.BytesInput(dataBytes);
#end



					//var
					var reader = new format.amf3.Reader(bytesInput);
					var data = reader.read();
					dragonBonesData = format.amf3.Tools.decode(data);


					bytes.position = endData - 4;
					strSize = bytes.readInt();
					position = endData - 4 - strSize;

					//dataBytes.length = 0;
					dataBytes = new ByteArray();
					dataBytes.writeBytes(bytes, position, strSize);
					dataBytes.uncompress();
					endData = position;
					dataBytes.position = 0;
					//bytes.length = position;

#if flash
				var bytesInput2 = new haxe.io.BytesInput(haxe.io.Bytes.ofData(dataBytes));
#else
				var bytesInput2 = new haxe.io.BytesInput(dataBytes);
#end


					var reader2 =  new format.amf3.Reader(bytesInput2);
					var data2 = reader2.read();
					textureAtlasData = format.amf3.Tools.decode(data2);
				}
				catch (e:String)
				{
					throw "Data error! " + e;
				}

				var decompressedData:DecompressedData = new DecompressedData(dragonBonesData, textureAtlasData, bytes);
				decompressedData.textureBytesDataType = dataType;
				return decompressedData;

			case BytesType.ZIP:
				throw "Can not decompress zip!";

			default:
				throw "Nonsupport data!";
		}
		return null;
	}

	public static function parseTextureAtlas(rawData:Dynamic, scale:Float = 1):NamedTextureAtlasData
	{
		if(Std.is(rawData, Xml))
		{
			return XMLDataParser.parseTextureAtlasData(cast(rawData, Xml), scale);
		}
		else
		{
			return ObjectDataParser.parseTextureAtlasData(rawData, scale);
		}
		return null;
	}

	public static function parseData(rawData:Dynamic, ifSkipAnimationData:Bool = false, outputAnimationDictionary:Map<String, Map<String, Xml>> = null):SkeletonData
	{
		if(Std.is(rawData, Xml))
		{
			return XMLDataParser.parseSkeletonData(cast(rawData, Xml), ifSkipAnimationData, outputAnimationDictionary);
		}
		else
		{
			return ObjectDataParser.parseSkeletonData(rawData, ifSkipAnimationData, outputAnimationDictionary);
		}
		return null;
	}

	public static function parseAnimationDataByAnimationRawData(animationRawData:Dynamic, armatureData:ArmatureData, isGlobalData:Bool = false):AnimationData
	{
		var animationData:AnimationData = armatureData.animationDataList[0];

		if(Std.is(animationRawData, Xml))
		{
			return XMLDataParser.parseAnimationData(cast(animationRawData, Xml), armatureData, animationData.frameRate, isGlobalData);
		}
		else
		{
			return ObjectDataParser.parseAnimationData(animationRawData, armatureData, animationData.frameRate, isGlobalData);
		}
		return null;
	}

	public static function parseFrameRate(rawData:Dynamic):UInt
	{
		if(Std.is(rawData, Xml))
		{
			return Std.parseInt(cast(rawData, Xml).get(ConstValues.A_FRAME_RATE));
		}
		else
		{
			return Std.parseInt(rawData.get(ConstValues.A_FRAME_RATE));
		}
		return 0;
	}
}
