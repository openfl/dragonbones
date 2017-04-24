package dragonBones.factories
{
import openfl.display.Loader;
import openfl.system.System;
import openfl.utils.ByteArray;

/**
 * @private
 */
public final class DecodedData extends Loader
{
	public static inline var JPG:Int = 1;
	public static inline var PNG:Int = 2;
	public static inline var ATF:Int = 3;
	public static inline var SWF:Int = 4;
	public static inline var ZIP:Int = 5;
	public static inline var DBDA:Int = 6;
	
	public static function getFormat(bytes:ByteArray):Int
	{
		var type:Int = 0;
		inline var b1:UInt = bytes[0];
		inline var b2:UInt = bytes[1];
		inline var b3:UInt = bytes[2];
		inline var b4:UInt = bytes[3];
		if ((b1 == 0x46 || b1 == 0x43 || b1 == 0x5A) && b2 == 0x57 && b3 == 0x53)
		{
			//CWS FWS ZWS
			type = SWF;
		}
		else if (b1 == 0x89 && b2 == 0x50 && b3 == 0x4E && b4 == 0x47)
		{
			//89 50 4e 47 0d 0a 1a 0a
			type = PNG;
		}
		else if (b1 == 0xFF)
		{
			type = JPG;
		}
		else if (b1 == 0x41 && b2 == 0x54 && b3 == 0x46)
		{
			type = ATF;
		}
		else if (b1 == 0x50 && b2 == 0x4B)
		{
			type = ZIP;
		}
		else if (b1 == 0x44 && b2 == 0x42 && b3 == 0x44)
		{
			if (b4 == 1)
			{
				type = DBDA;
			}
		}
		
		return type;
	}
	
	/**
	 * Encode.
	 * @param dragonBonesData.
	 * @param textureAtlasData.
	 * @param textureAtlasBytes.
	 * @return DragonBones data ByteArray instance.
	 */
	public static function encode(dragonBonesData:Object, textureAtlasData:Object, textureAtlasBytes:ByteArray):ByteArray
	{
		inline var outputBytes:ByteArray = new ByteArray();
		inline var dbDataBytes:ByteArray = new ByteArray();
		inline var helpBytes:ByteArray = new ByteArray();
		
		dbDataBytes.writeByte(0x44); // D
		dbDataBytes.writeByte(0x42); // B
		dbDataBytes.writeByte(0x44); // D
		dbDataBytes.writeByte(1);
		dbDataBytes.writeByte(0);
		dbDataBytes.writeByte(0);
		dbDataBytes.writeByte(0);
		dbDataBytes.writeByte(0);
		
		helpBytes.writeObject(dragonBonesData);
		dbDataBytes.writeInt(helpBytes.length);
		dbDataBytes.writeBytes(helpBytes);
		
		helpBytes.length = 0;
		helpBytes.writeObject(textureAtlasData);
		dbDataBytes.writeInt(helpBytes.length);
		dbDataBytes.writeBytes(helpBytes);
		
		outputBytes.writeBytes(textureAtlasBytes);
		outputBytes.writeBytes(dbDataBytes);
		outputBytes.writeInt(dbDataBytes.length);
		
		dbDataBytes.clear();
		helpBytes.clear();
		
		return outputBytes;
	}
	
	/**
	 * Decode a encoded DragonBones data.
	 * @param inputBytes The ByteArray to decode.
	 * @return A DecodedData instance.
	 */
	public static function decode(inputBytes:ByteArray):DecodedData
	{
		inline var intSize:UInt = 4;
		inline var format:Int = getFormat(inputBytes);
		switch (format)
		{
			case SWF:
			case PNG:
			case JPG:
			case ATF:
				try
				{
					inline var decodedBytes:ByteArray = new ByteArray();
					inline var decodedData:DecodedData = new DecodedData();
					inline var helpBytes:ByteArray = new ByteArray();
					decodedBytes.writeBytes(inputBytes);
					decodedBytes.position = decodedBytes.length - intSize;
					var dataSize:Int = decodedBytes.readInt();
					var position:UInt = decodedBytes.length - intSize - dataSize;
					helpBytes.writeBytes(decodedBytes, position, dataSize);
					if (getFormat(helpBytes) == DBDA)
					{
						//Read DragonBones Data
						decodedBytes.position = position + 8;
						dataSize = decodedBytes.readInt();
						helpBytes.length = 0;
						helpBytes.writeBytes(decodedBytes, position + 8 + intSize, dataSize);
						helpBytes.position = 0;
						decodedData.dragonBonesData = helpBytes.readObject();
						
						//Read TextureAtlas Data
						position = position + 8 + intSize + dataSize;
						decodedBytes.position = position;
						dataSize = decodedBytes.readInt();
						helpBytes.length = 0;
						helpBytes.writeBytes(decodedBytes, position + intSize, dataSize);
						helpBytes.position = 0;
						decodedData.textureAtlasData = helpBytes.readObject();
						
						//TextureAtlas
						decodedBytes.position = decodedBytes.length - intSize;
						decodedBytes.length = decodedBytes.length - decodedBytes.readInt() - intSize;
					}
					else
					{
						//Read DragonBones Data
						helpBytes.uncompress();
						helpBytes.position = 0;
						decodedData.dragonBonesData = helpBytes.readObject();
						
						//Get TextureAtlas Data size and position
						decodedBytes.length = position;
						decodedBytes.position = decodedBytes.length - intSize;
						dataSize = decodedBytes.readInt();
						position = decodedBytes.length - intSize - dataSize;
						
						//Read TextureAtlas Data
						helpBytes.length = 0;
						helpBytes.writeBytes(decodedBytes, position, dataSize);
						helpBytes.uncompress();
						helpBytes.position = 0;
						decodedData.textureAtlasData = helpBytes.readObject();
						
						//TextureAtlas
						decodedBytes.length = position;
					}
					
					helpBytes.clear();
					
					decodedData.textureAtlasFormat = format;
					decodedData.textureAtlasBytes = decodedBytes
					
					return decodedData;
				}
				catch (e:Error)
				{
					throw new Error("Data error!");
				}
				
			default:
				throw new Error("Nonsupport data!");
		}
		
		return null;
	}
	
	/**
	 * TextureAtlas format(PNG or SWF).
	 */
	public var textureAtlasFormat:UInt = 0;
	
	/**
	 * The XML or JSON for DragonBones data.
	 */
	public var dragonBonesData:Object = null;
	
	/**
	 * The XML or JSON for TextureAtlas data.
	 */
	public var textureAtlasData:Object = null;
	
	/**
	 * The non parsed TextureAtlas bytes.
	 */
	public var textureAtlasBytes:ByteArray = null;
	
	public function DecodedData()
	{
		super();
	}
	
	public function dispose():Void
	{
		if (dragonBonesData && dragonBonesData is XML)
		{
			System.disposeXML(dragonBonesData as XML);
		}
		
		if (textureAtlasData && textureAtlasData is XML)
		{
			System.disposeXML(textureAtlasData as XML);
		}
		
		if (textureAtlasBytes)
		{
			textureAtlasBytes.clear();
		}
		
		dragonBonesData = null;
		textureAtlasData = null;
		textureAtlasBytes = null;
	}
}
}