package dragonBones.factorys;

import openfl.display.BitmapData;
import dragonBones.objects.XMLDataParser;
import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.BoneData;
import dragonBones.objects.DataParser;
import dragonBones.objects.DecompressedData;
import dragonBones.objects.DisplayData;
import dragonBones.objects.SkeletonData;
import dragonBones.objects.SkinData;
import dragonBones.objects.SlotData;
import dragonBones.textures.ITextureAtlas;

import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.system.ApplicationDomain;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;
import openfl.utils.Dictionary;


/** Dispatched after a sucessful call to parseData(). */
//[Event(name="complete", type="flash.events.Event")]

class BaseFactory extends EventDispatcher
{
	/** @private */
	public static var _helpMatrix:Matrix = new Matrix();
	private static var _loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

	/** @private */
	public var _dataDic:Map<String, SkeletonData>;
	/** @private */
	public var _textureAtlasDic:Map<String, Dynamic>;
	/** @private */
	public var _currentDataName:String;
	/** @private */
	public var _currentTextureAtlasName:String;

	public function new(self:BaseFactory)
	{
		super(this);

		if(self != this)
		{
			throw "Abstract class can not be instantiated!";
		}

		_loaderContext.allowCodeImport = true;

		_dataDic = new Map<String, SkeletonData>();
		_textureAtlasDic = new Map<String, Dynamic>();

		_currentDataName = null;
		_currentTextureAtlasName = null;
	}

	/**
	 * Returns a SkeletonData instance.
	 * @param The name of an existing SkeletonData instance.
	 * @return A SkeletonData instance with given name (if exist).
	 */
	public function getSkeletonData(name:String):SkeletonData
	{
		return _dataDic.get(name);
	}

	/**
	 * Add a SkeletonData instance to this BaseFactory instance.
	 * @param A SkeletonData instance.
	 * @param (optional) A name for this SkeletonData instance.
	 */
	public function addSkeletonData(data:SkeletonData, name:String = null):Void
	{
		if(data == null)
		{
			throw "ArgumentError";
		}
		if (name == null) {
			name = data.name;
		}
		if(name == null)
		{
			throw "Unnamed data!";
		}
		if(_dataDic.exists(name))
		{
			throw "ArgumentError";
		}
		_dataDic.set(name, data);
	}

	/**
	 * Remove a SkeletonData instance from this BaseFactory instance.
	 * @param The name for the SkeletonData instance to remove.
	 */
	public function removeSkeletonData(name:String):Void
	{
		 _dataDic.remove(name);
	}

	/**
	 * Return the TextureAtlas by that name.
	 * @param The name of the TextureAtlas to return.
	 * @return A textureAtlas.
	 */
	public function getTextureAtlas(name:String):Dynamic
	{
		return _textureAtlasDic.get(name);
	}

	/**
	 * Add a textureAtlas to this BaseFactory instance.
	 * @param A textureAtlas to add to this BaseFactory instance.
	 * @param (optional) A name for this TextureAtlas.
	 */
	public function addTextureAtlas(textureAtlas:Dynamic, name:String = null):Void
	{
		if(textureAtlas == null)
		{
			throw "ArgumentError";
		}
		if(name == null && Std.is(textureAtlas, ITextureAtlas))
		{
			name = textureAtlas.name;
		}
		if(name == null)
		{
			throw "Unnamed data!";
		}
		if(_textureAtlasDic.exists(name))
		{
			throw "ArgumentError";
		}
		_textureAtlasDic.set(name, textureAtlas);
	}

	/**
	 * Remove a textureAtlas from this baseFactory instance.
	 * @param The name of the TextureAtlas to remove.
	 */
	public function removeTextureAtlas(name:String):Void
	{
		_textureAtlasDic.remove(name);
	}

	/**
	 * Cleans up resources used by this BaseFactory instance.
	 * @param (optional) Destroy all internal references.
	 */
	public function dispose(disposeData:Bool = true):Void
	{
		if(disposeData)
		{
			for(skeletonName in _dataDic.keys())
			{
			    var skeletonData = _dataDic.get(skeletonName);
				if (skeletonData != null) {
					skeletonData.dispose();
				}
				_dataDic.remove(skeletonName);
			}

			for(textureAtlasName in _textureAtlasDic.keys())
			{
			    var textureAtlas = cast(_textureAtlasDic.get(textureAtlasName), ITextureAtlas);
				if (textureAtlas != null) {
				    textureAtlas.dispose();
				}
				_textureAtlasDic.remove(textureAtlasName);
			}
		}

		_dataDic = null;
		_textureAtlasDic = null;
		_currentDataName = null;
		_currentTextureAtlasName = null;
	}

	/**
	 * Build and returns a new Armature instance.
	 * @example
	 * <listing>
	 * var armature:Armature = factory.buildArmature('dragon');
	 * </listing>
	 * @param armatureName The name of this Armature instance.
	 * @param The name of this animation.
	 * @param The name of this SkeletonData.
	 * @param The name of this textureAtlas.
	 * @param The name of this skin.
	 * @return A Armature instance.
	 */
	public function buildArmature(armatureName:String, animationName:String = null, skeletonName:String = null, textureAtlasName:String = null, skinName:String = null):Armature
	{
		var data:SkeletonData = null;
		var armatureData:ArmatureData = null;
		var animationArmatureData:ArmatureData = null;
		var skinData:SkinData = null;
		var skinDataCopy:SkinData = null;

		if(skeletonName != null)
		{
			data = _dataDic.get(skeletonName);
			if(data != null)
			{
				armatureData = data.getArmatureData(armatureName);
			}
		}
		else
		{
			for(sName in _dataDic.keys())
			{
				data = _dataDic.get(sName);
				armatureData = data.getArmatureData(armatureName);
				if(armatureData != null)
				{
					skeletonName = sName;
					break;
				}
			}
		}

		if(armatureData == null)
		{
			return null;
		}

		_currentDataName = skeletonName;
		_currentTextureAtlasName = textureAtlasName != null ? textureAtlasName : skeletonName;

		if(animationName != null && animationName != armatureName)
		{
			animationArmatureData = data.getArmatureData(animationName);
			if(animationArmatureData != null)
			{
				for (skeletonName in _dataDic.keys())
				{
					data = _dataDic.get(skeletonName);
					animationArmatureData = data.getArmatureData(animationName);
					if(animationArmatureData != null)
					{
						break;
					}
				}
			}

			if(animationArmatureData != null)
			{
				skinDataCopy = animationArmatureData.getSkinData("");
			}
		}

		skinData = armatureData.getSkinData(skinName);

		var armature:Armature = generateArmature();
		armature.name = armatureName;
		armature._armatureData = armatureData;

		if(animationArmatureData != null)
		{
			armature.animation.animationDataList = animationArmatureData.animationDataList;
		}
		else
		{
			armature.animation.animationDataList = armatureData.animationDataList;
		}

		//
		buildBones(armature, armatureData);

		//
		if(skinData != null)
		{
			buildSlots(armature, armatureData, skinData, skinDataCopy);
		}

		// update armature pose
		armature.advanceTime(0);
		return armature;
	}

	/**
	 * Add a new animation to armature.
	 * @param animationRawData (XML, JSON).
	 * @param target armature.
	 */
	public function addAnimationToArmature(animationRawData:Dynamic, armature:Armature, isGlobalData:Bool = false):Void
	{
		armature._armatureData.addAnimationData(DataParser.parseAnimationDataByAnimationRawData(animationRawData,armature._armatureData, isGlobalData));
	}

	/**
	 * Return the TextureDisplay.
	 * @param The name of this Texture.
	 * @param The name of the TextureAtlas.
	 * @param The registration pivotX position.
	 * @param The registration pivotY position.
	 * @return An Object.
	 */
	public function getTextureDisplay(textureName:String, textureAtlasName:String = null, ?pivotX:Float, ?pivotY:Float):Dynamic
	{
		var textureAtlas:Dynamic = null;
		if(textureAtlasName != null)
		{
			textureAtlas = _textureAtlasDic.get(textureAtlasName);
		}

		if(textureAtlas == null && textureAtlasName == null)
		{
			for (textureAtlasName in _textureAtlasDic.keys())
			{
				textureAtlas = _textureAtlasDic.get(textureAtlasName);
				if(textureAtlas.getRegion(textureName))
				{
					break;
				}
				textureAtlas = null;
			}
		}

		if(textureAtlas != null)
		{
			if(pivotX == null || pivotY == null)
			{
				var data:SkeletonData = _dataDic.get(textureAtlasName);
				if(data != null)
				{
					var pivot:Point = data.getSubTexturePivot(textureName);
					if(pivot != null)
					{
						pivotX = pivot.x;
						pivotY = pivot.y;
					}
				}
			}

			return generateDisplay(textureAtlas, textureName, pivotX, pivotY);
		}
		return null;
	}

	/** @private */
	public function buildBones(armature:Armature, armatureData:ArmatureData):Void
	{
		//按照从属关系的顺序建立
		for(i in 0...armatureData.boneDataList.length)
		{
			var boneData:BoneData = armatureData.boneDataList[i];
			var bone:Bone = new Bone();
			bone.name = boneData.name;
			bone.inheritRotation = boneData.inheritRotation;
			bone.inheritScale = boneData.inheritScale;
			bone.origin.copy(boneData.transform);
			if(armatureData.getBoneData(boneData.parent) != null)
			{
				armature.addBone(bone, boneData.parent);
			}
			else
			{
				armature.addBone(bone);
			}
		}
	}

	/** @private */
	public function buildSlots(armature:Armature, armatureData:ArmatureData, skinData:SkinData, skinDataCopy:SkinData):Void
	{
		var helpArray:Array<Dynamic> = null;
		for (slotData in skinData.slotDataList)
		{
			var bone:Bone = armature.getBone(slotData.parent);
			if(bone == null)
			{
				continue;
			}
			var slot:Slot = generateSlot();
			slot.name = slotData.name;
			slot.blendMode = slotData.blendMode;
			slot._originZOrder = slotData.zOrder;
			slot._displayDataList = slotData.displayDataList;

			helpArray = new Array<Dynamic>();
			var i:Int = slotData.displayDataList.length;
			while(i -- > 0)
			{
				var displayData:DisplayData = slotData.displayDataList[i];

				switch(displayData.type)
				{
					case DisplayData.ARMATURE:
						var displayDataCopy:DisplayData = null;
						if(skinDataCopy != null)
						{
							var slotDataCopy:SlotData = skinDataCopy.getSlotData(slotData.name);
							if(slotDataCopy != null)
							{
								displayDataCopy = slotDataCopy.displayDataList[i];
							}
						}

						var childArmature:Armature = buildArmature(displayData.name, displayDataCopy != null?displayDataCopy.name:null, _currentDataName, _currentTextureAtlasName);
						helpArray.push(childArmature);


					case DisplayData.IMAGE:
						helpArray.push(generateDisplay(_textureAtlasDic[_currentTextureAtlasName], displayData.name, displayData.pivot.x, displayData.pivot.y));


					default:
						helpArray.push(null);


				}
			}

			//==================================================
			//如果显示对象有name属性并且name属性可以设置的话，将name设置为与slot同名，dragonBones并不依赖这些属性，只是方便开发者
			for (i in 0...helpArray.length)
			{
				var displayObject = helpArray[i];
				if(Std.is(displayObject, Armature))
				{
					// XXXCBR: causes crash with Haxe 3.2 compiler on native
					cast(displayObject, Armature).display.name = slot.name;
				}
				else
				{

					if(displayObject != null)
					{
						try
						{
                            // XXXCBR: causes crash with Haxe 3.2 compiler on native
							//displayObject.name = slot.name;
						}
						catch(e:String)
						{
						}
					}
				}
			}
			//==================================================


			bone.addChild(slot);
			slot.displayList = helpArray;
			slot.changeDisplay(0);
		}
	}

	/** @private */
	public function generateTextureAtlas(content:Dynamic, textureAtlasRawData:Dynamic):ITextureAtlas
	{
		return null;
	}

	/**
	 * @private
	 * Generates an Armature instance.
	 * @return Armature An Armature instance.
	 */
	public function generateArmature():Armature
	{
		return null;
	}

	/**
	 * @private
	 * Generates an Slot instance.
	 * @return Slot An Slot instance.
	 */
	public function generateSlot():Slot
	{
		return null;
	}

	/**
	 * @private
	 * Generates a DisplayObject
	 * @param textureAtlas The TextureAtlas.
	 * @param fullName A qualified name.
	 * @param pivotX A pivot x based value.
	 * @param pivotY A pivot y based value.
	 * @return
	 */
	public function generateDisplay(textureAtlas:Dynamic, fullName:String, pivotX:Float, pivotY:Float):Dynamic
	{
		return null;
	}

	//==================================================
	//解析dbswf和dbpng，如果不能序列化amf3格式无法实现解析
	/** @private */
	public var _textureAtlasLoadingDic:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * Parses the raw data and returns a SkeletonData instance.
	 * @example
	 * <listing>
	 * import flash.events.Event;
	 * import dragonBones.factorys.NativeFactory;
	 *
	 * [Embed(source = "../assets/Dragon1.swf", mimeType = "application/octet-stream")]
	 *	private static const ResourcesData:Class;
	 * var factory:NativeFactory = new NativeFactory();
	 * factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	 * factory.parseData(new ResourcesData());
	 * </listing>
	 * @param ByteArray. Represents the raw data for the whole DragonBones system.
	 * @param String. (optional) The SkeletonData instance name.
	 * @param Boolean. (optional) flag if delay animation data parsing. Delay animation data parsing can reduce the data paring time to improve loading performance.
	 * @param Dictionary. (optional) output parameter. If it is not null, and ifSkipAnimationData is true, it will be fulfilled animationData, so that developers can parse it later.
	 * @return A SkeletonData instance.
	 */
	public function parseData(skeletonXmlString: String, textureXmlString: String, textureImgData: BitmapData):SkeletonData
	{
		var skeletonXML: Xml = Xml.parse(skeletonXmlString);
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(skeletonXML.firstElement());

		var atlas:Dynamic = {};

		_textureAtlasDic.set(atlas.name, atlas);
		//_currentTextureAtlas = atlas;
		_currentTextureAtlasName = atlas.name;

		_dataDic.set(skeletonData.name, skeletonData);
		//_currentSkeletonData = skeletonData;
		_currentDataName = skeletonData.name;


		return skeletonData;
	}

	public function parseDataAH(skeletonXmlString: String, textureAtlas:ITextureAtlas):SkeletonData
	{
		var skeletonXML: Xml = Xml.parse(skeletonXmlString);
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(skeletonXML.firstElement());

		_dataDic.set(skeletonData.name, skeletonData);
		_currentDataName = skeletonData.name;

		_textureAtlasDic.set(skeletonData.name, textureAtlas);
		_currentTextureAtlasName = skeletonData.name;


		return skeletonData;
	}

	public function parseDataB(bytes:ByteArray, dataName:String = null, ifSkipAnimationData:Bool = false, outputAnimationDictionary:Map<String, Map<String, Xml>> = null):SkeletonData
	{
		if(bytes == null)
		{
			throw "ArgumentError";
		}
		var decompressedData:DecompressedData = DataParser.decompressData(bytes);

		var data:SkeletonData = DataParser.parseData(decompressedData.dragonBonesData, ifSkipAnimationData, outputAnimationDictionary);

		if (dataName == null) {
			dataName = data.name;
		}
		addSkeletonData(data, dataName);
		var loader:Loader = new Loader();
		loader.name = dataName;
		_textureAtlasLoadingDic.set(dataName, decompressedData.textureAtlasData);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
		#if !html5
			loader.loadBytes(decompressedData.textureBytes, _loaderContext);
		#else
			loader.loadBytes(decompressedData.textureBytes);
		#end
		decompressedData.dispose();
		return data;
	}


	/** @private */
 //TODO
	public function loaderCompleteHandler(e:Event):Void
	{
		e.target.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
		var loader:Loader = e.target.loader;
		var content:Dynamic = e.target.content;
		//loader.unloadAndStop();

		var name:String = loader.name;
		var textureAtlasRawData:Dynamic = _textureAtlasLoadingDic.get(name);
		//delete _textureAtlasLoadingDic[name];
		if(name != null && textureAtlasRawData != null)
		{
			if (Std.is(content, Bitmap))
			{
				content =  cast(content, Bitmap).bitmapData;
			}
			else if (Std.is(content, Sprite))
			{
				content = cast(cast(content, Sprite).getChildAt(0), MovieClip);
			}
			else
			{
				//
			}

			var textureAtlas:Dynamic = generateTextureAtlas(content, textureAtlasRawData);
			addTextureAtlas(textureAtlas, name);

			name = null;

			//
			if(name == null && this.hasEventListener(Event.COMPLETE))
			{
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}
	//==================================================
}
