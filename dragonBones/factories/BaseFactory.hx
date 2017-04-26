package dragonBones.factories;

import haxe.Timer;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.LoaderInfo;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
//import openfl.utils.clearTimeout;
//import openfl.utils.setTimeout;
import openfl.Vector;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.core.BaseObject;
import dragonBones.core.DragonBones;
import dragonBones.enums.DisplayType;
import dragonBones.objects.AnimationData;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.BoneData;
import dragonBones.objects.DisplayData;
import dragonBones.objects.DragonBonesData;
import dragonBones.objects.SkinData;
import dragonBones.objects.SkinSlotData;
import dragonBones.objects.SlotData;
import dragonBones.parsers.DataParser;
import dragonBones.parsers.ObjectDataParser;
import dragonBones.textures.TextureAtlasData;
import dragonBones.textures.TextureData;


/** 
 * Dispatched after a sucessful call to parseDragonBonesData().
 */
//[Event(name="complete", type="flash.events.Event")]

/**
 * @language zh_CN
 * 创建骨架的基础工厂。
 * @see dragonBones.objects.DragonBonesData
 * @see dragonBones.textures.TextureAtlasData
 * @see dragonBones.objects.ArmatureData
 * @see dragonBones.Armature
 * @version DragonBones 3.0
 */
@:allow(dragonBones) class BaseFactory extends EventDispatcher
{
	/**
	 * @private
	 */
	private static var _defaultDataParser:DataParser = new ObjectDataParser();
	/**
	 * @language zh_CN
	 * 是否开启共享搜索。
	 * 如果开启，创建一个骨架时，可以从多个龙骨数据中寻找骨架数据，或贴图集数据中寻找贴图数据。 (通常在有共享导出的数据时开启)
	 * @see dragonBones.DragonBonesData#autoSearch
	 * @see dragonBones.TextureAtlasData#autoSearch
	 * @version DragonBones 4.5
	 */
	public var autoSearch:Bool = false;
	/** 
	 * @private 
	 */
	private var _dragonBonesDataMap:Map<String, DragonBonesData> = new Map<String, DragonBonesData>();
	/** 
	 * @private 
	 */
	private var _textureAtlasDataMap:Map<String, Vector<TextureAtlasData>> = new Map<String, Vector<TextureAtlasData>>();
	/** 
	 * @private 
	 */
	private var _dataParser:DataParser = null;
	/** 
	 * @private 
	 */
	private function new (dataParser:DataParser = null)
	{
		super();
		_dataParser = dataParser != null ? dataParser : _defaultDataParser;
	}
	/** 
	 * @private
	 */
	private function _getTextureData(textureAtlasName:String, textureName:String):TextureData
	{
		var textureData:TextureData;
		
		if (_textureAtlasDataMap.exists(textureAtlasName))
		{
			var textureAtlasDataList:Vector<TextureAtlasData> = _textureAtlasDataMap[textureAtlasName];
			
			var l:UInt = textureAtlasDataList.length;
			for (i in 0...l)
			{
				textureData = textureAtlasDataList[i].getTexture(textureName);
				if (textureData != null)
				{
					return textureData;
				}
			}
		}
		
		if (autoSearch)
		{
			for (textureAtlasDataList in _textureAtlasDataMap)
			{
				var l = textureAtlasDataList.length;
				var textureAtlasData:TextureAtlasData;
				for (i in 0...l)
				{
					textureAtlasData = textureAtlasDataList[i];
					if (textureAtlasData.autoSearch)
					{
						textureData = textureAtlasData.getTexture(textureName);
						if (textureData != null)
						{
							return textureData;
						}
					}
				}
			}
		}
		
		return null;
	}
	/** 
	 * @private
	 */
	private function _fillBuildArmaturePackage(dataPackage:BuildArmaturePackage, dragonBonesName:String, armatureName:String, skinName:String, textureAtlasName:String):Bool
	{
		var dragonBonesData:DragonBonesData = null;
		var armatureData:ArmatureData = null;
		
		if (dragonBonesName != null)
		{
			if (_dragonBonesDataMap.exists(dragonBonesName))
			{
				armatureData = _dragonBonesDataMap[dragonBonesName].getArmature(armatureName);
			}
		}
		
		if (armatureData == null && (dragonBonesName == null || autoSearch))
		{
			for (eachDragonBonesName in _dragonBonesDataMap.keys())
			{
				dragonBonesData = _dragonBonesDataMap[eachDragonBonesName];
				if (dragonBonesName == null || dragonBonesData.autoSearch)
				{
					armatureData = dragonBonesData.getArmature(armatureName);
					if (armatureData != null)
					{
						dragonBonesName = eachDragonBonesName;
						break;
					}
				}
			}
		}
		
		if (armatureData != null)
		{
			dataPackage.dataName = dragonBonesName;
			dataPackage.textureAtlasName = textureAtlasName;
			dataPackage.data = dragonBonesData;
			dataPackage.armature = armatureData;
			dataPackage.skin = armatureData.getSkin(skinName);
			if (dataPackage.skin == null) 
			{
				dataPackage.skin = armatureData.defaultSkin;
			}
			
			return true;
		}
		
		return false;
	}
	/** 
	 * @private
	 */
	private function _buildBones(dataPackage:BuildArmaturePackage, armature:Armature):Void
	{
		var bones:Vector<BoneData> = dataPackage.armature.sortedBones;
		var l:UInt = bones.length;
		var boneData:BoneData, bone:Bone;
		for (i in 0...l)
		{
			boneData = bones[i];
			bone = cast BaseObject.borrowObject(Bone);
			bone._init(boneData);
			
			if(boneData.parent != null)
			{
				armature._addBone(bone, boneData.parent.name);
			}
			else
			{
				armature._addBone(bone);
			}
			
			if (boneData.ik != null)
			{
				bone.ikBendPositive = boneData.bendPositive;
				bone.ikWeight = boneData.weight;
				bone._setIK(armature.getBone(boneData.ik.name), boneData.chain, boneData.chainIndex);
			}
		}
	}
	/**
	 * @private
	 */
	private function _buildSlots(dataPackage:BuildArmaturePackage, armature:Armature):Void
	{
		var currentSkin:SkinData = dataPackage.skin;
		var defaultSkin:SkinData = dataPackage.armature.defaultSkin;
		var slotDisplayDataSetMap = new Map<String, SkinSlotData> ();
		
		for (skinSlotData in defaultSkin.slots)
		{
			slotDisplayDataSetMap[skinSlotData.slot.name] = skinSlotData;
		}
		
		if (currentSkin != defaultSkin)
		{
			for (skinSlotData in currentSkin.slots)
			{
				slotDisplayDataSetMap[skinSlotData.slot.name] = skinSlotData;
			}
		}
		
		var slots:Vector<SlotData> = dataPackage.armature.sortedSlots;
		var l:UInt = slots.length;
		var slotData:SlotData, skinSlotData:SkinSlotData, slot:Slot;
		for (i in 0...l)
		{
			slotData = slots[i];
			if (!slotDisplayDataSetMap.exists(slotData.name))
			{
				continue;
			}
			
			skinSlotData = slotDisplayDataSetMap[slotData.name];
			slot = _generateSlot(dataPackage, skinSlotData, armature);
			if (slot != null)
			{
				armature._addSlot(slot, slotData.parent.name);
				slot._setDisplayIndex(slotData.displayIndex);
			}
		}
	}
	/**
	 * @private
	 */
	private function _replaceSlotDisplay(dataPackage:BuildArmaturePackage, displayData:DisplayData, slot:Slot, displayIndex:Int):Void
	{
		if (displayIndex < 0) 
		{
			displayIndex = slot.displayIndex;
		}
		
		if (displayIndex >= 0) 
		{
			var displayList:Vector<Dynamic> = slot.displayList; // Copy.
			if (displayList.length <= displayIndex) 
			{
				displayList.length = displayIndex + 1;
			}
			
			if (slot._replacedDisplayDatas.length <= displayIndex) 
			{
				slot._replacedDisplayDatas.length = displayIndex + 1;
			}
			
			slot._replacedDisplayDatas[displayIndex] = displayData;
			
			if (displayData.type == DisplayType.Armature) 
			{
				var childArmature:Armature = buildArmature(displayData.path, dataPackage.dataName, null, dataPackage.textureAtlasName);
				displayList[displayIndex] = childArmature;
			}
			else 
			{
				if (displayData.texture == null || dataPackage.textureAtlasName != null) 
				{
					displayData.texture = _getTextureData(dataPackage.textureAtlasName != null ? dataPackage.textureAtlasName : dataPackage.dataName, displayData.path);
				}
				
				var displayDatas:Vector<DisplayData> = slot.skinSlotData.displays;
				if (
					displayData.mesh != null ||
					(displayIndex < displayDatas.length && displayDatas[displayIndex].mesh != null)
				) 
				{
					displayList[displayIndex] = slot.meshDisplay;
				}
				else 
				{
					displayList[displayIndex] = slot.rawDisplay;
				}
			}
			
			slot.displayList = displayList;
		}
	}
	/**
	 * @private
	 */
	private function _generateTextureAtlasData(textureAtlasData:TextureAtlasData, textureAtlas:Dynamic):TextureAtlasData
	{
		throw new Error(DragonBones.ABSTRACT_METHOD_ERROR);
		return null;
	}
	/**
	 * @private
	 */
	private function _generateArmature(dataPackage:BuildArmaturePackage):Armature
	{
		throw new Error(DragonBones.ABSTRACT_METHOD_ERROR);
		return null;
	}
	/** 
	 * @private
	 */
	private function _generateSlot(dataPackage:BuildArmaturePackage, slotDisplayDataSet:SkinSlotData, armature:Armature):Slot
	{
		throw new Error(DragonBones.ABSTRACT_METHOD_ERROR);
		return null;
	}
	/**
	 * @language zh_CN
	 * 解析并添加龙骨数据。
	 * @param rawData 需要解析的原始数据。 (JSON，如果是 merged data 则需要监听 Event.COMPLETE 事件，因为这是一个异步的过程)
	 * @param dragonBonesName 为数据指定一个名称，以便可以通过这个名称来获取数据，如果未设置，则使用数据中的名称。
	 * @return DragonBonesData
	 * @see #getDragonBonesData()
	 * @see #addDragonBonesData()
	 * @see #removeDragonBonesData()
	 * @see dragonBones.objects.DragonBonesData
	 * @version DragonBones 4.5
	 */
	public function parseDragonBonesData(rawData:Dynamic, dragonBonesName:String = null, scale:Float = 1.0):DragonBonesData
	{
		//
		var isComplete:Bool = true;
		if (Std.is(rawData, ByteArrayData))
		{
			var decodeData:DecodedData = DecodedData.decode(cast rawData);
			if (decodeData != null)
			{
				_decodeDataList.push(decodeData);
				decodeData.name = dragonBonesName != null ? dragonBonesName : "";
				decodeData.contentLoaderInfo.addEventListener(Event.COMPLETE, _loadTextureAtlasHandler);
				decodeData.loadBytes(decodeData.textureAtlasBytes, null);
				rawData = decodeData.dragonBonesData;
				isComplete = false;
			}
			else
			{
				return null;
			}
		}
		
		var dragonBonesData:DragonBonesData = _dataParser.parseDragonBonesData(rawData, scale);
		addDragonBonesData(dragonBonesData, dragonBonesName);
		
		//
		if (isComplete)
		{
			if (_delay != null)
			{
				_delay.stop();
			}
			_delay = Timer.delay(dispatchEvent.bind(new Event(Event.COMPLETE)), 30);
		}
		
		return dragonBonesData;
	}
	/**
	 * @language zh_CN
	 * 解析并添加贴图集数据。
	 * @param rawData 需要解析的原始数据。 (JSON)
	 * @param textureAtlas 贴图。
	 * @param name 为数据指定一个名称，以便可以通过这个名称来访问数据，如果未设置，则使用数据中的名称。
	 * @param scale 为贴图集设置一个缩放值。
	 * @return 贴图集数据
	 * @see #getTextureAtlasData()
	 * @see #addTextureAtlasData()
	 * @see #removeTextureAtlasData()
	 * @see dragonBones.textures.TextureAtlasData
	 * @version DragonBones 4.5
	 */
	public function parseTextureAtlasData(rawData:Dynamic, textureAtlas:Dynamic, name:String = null, scale:Float = 0.0, rawScale:Float = 0.0):TextureAtlasData
	{
		var textureAtlasData:TextureAtlasData = _generateTextureAtlasData(null, null);
		_dataParser.parseTextureAtlasData(rawData, textureAtlasData, scale, rawScale);
		
		if (Std.is(textureAtlas, Bitmap))
		{
			textureAtlas = cast(textureAtlas, Bitmap).bitmapData;
		}
		else if (Std.is(textureAtlas, DisplayObject))
		{
			var displayObject:DisplayObject = cast textureAtlas;
			var rect:Rectangle = displayObject.getRect(displayObject);
			var matrix:Matrix = new Matrix();
			matrix.scale(textureAtlasData.scale, textureAtlasData.scale);
			textureAtlasData.bitmapData = new BitmapData(
				Std.int((rect.x + displayObject.width) * textureAtlasData.scale), 
				Std.int((rect.y + displayObject.height) * textureAtlasData.scale), 
				true, 
				0
			);
			
			textureAtlasData.bitmapData.draw(displayObject, matrix, null, null, null, smoothing);
			textureAtlas = textureAtlasData.bitmapData;
		}
		
		_generateTextureAtlasData(textureAtlasData, textureAtlas);
		addTextureAtlasData(textureAtlasData, name);
		
		return textureAtlasData;
	}
	/**
	 * @language zh_CN
	 * 获取指定名称的龙骨数据。
	 * @param name 数据名称
	 * @return DragonBonesData
	 * @see #parseDragonBonesData()
	 * @see #addDragonBonesData()
	 * @see #removeDragonBonesData()
	 * @see dragonBones.objects.DragonBonesData
	 * @version DragonBones 3.0
	 */
	public function getDragonBonesData(name:String):DragonBonesData
	{
		return _dragonBonesDataMap[name];
	}
	/**
	 * @language zh_CN
	 * 添加龙骨数据。
	 * @param data 龙骨数据。
	 * @param dragonBonesName 为数据指定一个名称，以便可以通过这个名称来访问数据，如果未设置，则使用数据中的名称。
	 * @see #parseDragonBonesData()
	 * @see #getDragonBonesData()
	 * @see #removeDragonBonesData()
	 * @see dragonBones.objects.DragonBonesData
	 * @version DragonBones 3.0
	 */
	public function addDragonBonesData(data:DragonBonesData, dragonBonesName:String = null):Void
	{
		if (data != null)
		{
			if (dragonBonesName == null) dragonBonesName = data.name;
			if (dragonBonesName != null)
			{
				if (!_dragonBonesDataMap.exists(dragonBonesName))
				{
					_dragonBonesDataMap[dragonBonesName] = data;
				}
				else
				{
					throw new Error("Same name data.");
				}
			}
			else
			{
				throw new Error("Unnamed data.");
			}
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @language zh_CN
	 * 移除龙骨数据。
	 * @param dragonBonesName 数据名称
	 * @param disposeData 是否释放数据。 [false: 不释放, true: 释放]
	 * @see #parseDragonBonesData()
	 * @see #getDragonBonesData()
	 * @see #addDragonBonesData()
	 * @see dragonBones.objects.DragonBonesData
	 * @version DragonBones 3.0
	 */
	public function removeDragonBonesData(dragonBonesName:String, disposeData:Bool = true):Void
	{
		var dragonBonesData:DragonBonesData = _dragonBonesDataMap[dragonBonesName];
		if (dragonBonesData != null)
		{
			if (disposeData)
			{
				dragonBonesData.returnToPool();
			}
			
			_dragonBonesDataMap.remove(dragonBonesName);
		}
	}
	/**
	 * @language zh_CN
	 * 获取指定名称的贴图集数据列表。
	 * @param dragonBonesName 数据名称。
	 * @return 贴图集数据列表。
	 * @see #parseTextureAtlasData()
	 * @see #addTextureAtlasData()
	 * @see #removeTextureAtlasData()
	 * @see dragonBones.textures.TextureAtlasData
	 * @version DragonBones 3.0
	 */
	public function getTextureAtlasData(dragonBonesName:String):Vector<TextureAtlasData>
	{
		return _textureAtlasDataMap[dragonBonesName];
	}
	/**
	 * @language zh_CN
	 * 添加贴图集数据。
	 * @param data 贴图集数据。
	 * @param dragonBonesName 为数据指定一个名称，以便可以通过这个名称来访问数据，如果未设置，则使用数据中的名称。
	 * @see #parseTextureAtlasData()
	 * @see #getTextureAtlasData()
	 * @see #removeTextureAtlasData()
	 * @see dragonBones.textures.TextureAtlasData
	 * @version DragonBones 3.0
	 */
	public function addTextureAtlasData(data:TextureAtlasData, dragonBonesName:String = null):Void
	{
		if (data != null)
		{
			if (dragonBonesName == null) dragonBonesName = data.name;
			if (dragonBonesName != null)
			{
				var textureAtlasList:Vector<TextureAtlasData>;
				if (_textureAtlasDataMap.exists(dragonBonesName))
				{
					textureAtlasList = _textureAtlasDataMap[dragonBonesName];
				}
				else
				{
					textureAtlasList = new Vector<TextureAtlasData>();
					_textureAtlasDataMap[dragonBonesName] = textureAtlasList;
				}
				
				if (textureAtlasList.indexOf(data) < 0)
				{
					textureAtlasList.push(data);
				}
			}
			else
			{
				throw new Error("Unnamed data.");
			}
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @language zh_CN
	 * 移除贴图集数据。
	 * @param dragonBonesName 数据名称。
	 * @param disposeData 是否释放数据。 [false: 不释放, true: 释放]
	 * @see #parseTextureAtlasData()
	 * @see #getTextureAtlasData()
	 * @see #addTextureAtlasData()
	 * @see dragonBones.textures.TextureAtlasData
	 * @version DragonBones 3.0
	 */
	public function removeTextureAtlasData(dragonBonesName:String, disposeData:Bool = true):Void
	{
		var textureAtlasDataList:Vector<TextureAtlasData> = _textureAtlasDataMap[dragonBonesName];
		if (textureAtlasDataList != null)
		{
			if (disposeData)
			{
				for (textureAtlasData in textureAtlasDataList)
				{
					textureAtlasData.returnToPool();
				}
			}
			
			_textureAtlasDataMap.remove(dragonBonesName);
		}
	}
	/**
	 * @language zh_CN
	 * 清除所有的数据。
	 * @param disposeData 是否释放数据。
	 * @version DragonBones 4.5
	 */
	public function clear(disposeData:Bool = true):Void
	{
		for (k  in _dragonBonesDataMap.keys())
		{
			if (disposeData)
			{
				_dragonBonesDataMap[k].returnToPool();
			}
			
			_dragonBonesDataMap.remove(k);
		}
		
		for (k in _textureAtlasDataMap.keys())
		{
			if (disposeData)
			{
				var textureAtlasDataList:Vector<TextureAtlasData> = _textureAtlasDataMap[k];
				var l:UInt = textureAtlasDataList.length;
				for (i in 0...l)
				{
					textureAtlasDataList[i].returnToPool();
				}
			}
			
			_textureAtlasDataMap.remove(k);
		}
	}
	/**
	 * @language zh_CN
	 * 创建一个指定名称的骨架。
	 * @param armatureName 骨架数据名称。
	 * @param dragonBonesName 龙骨数据名称，如果未设置，将检索所有的龙骨数据，当多个龙骨数据中包含同名的骨架数据时，可能无法创建出准确的骨架。
	 * @param skinName 皮肤名称，如果未设置，则使用默认皮肤。
	 * @param textureAtlasName 贴图集数据名称，如果未设置，则使用龙骨数据。
	 * @return 骨架。
	 * @see dragonBones.Armature
	 * @version DragonBones 3.0
	 */
	public function buildArmature(armatureName:String, dragonBonesName:String = null, skinName:String = null, textureAtlasName:String = null):Armature
	{
		var dataPackage:BuildArmaturePackage = new BuildArmaturePackage();
		if (_fillBuildArmaturePackage(dataPackage, dragonBonesName, armatureName, skinName, textureAtlasName))
		{
			var armature:Armature = _generateArmature(dataPackage);
			_buildBones(dataPackage, armature);
			_buildSlots(dataPackage, armature);
			
			armature.invalidUpdate(null, true);
			armature.advanceTime(0.0); // Update armature pose.
			return armature;
		}
		
		return null;
	}
	/**
	 * @language zh_CN
	 * 将指定骨架的动画替换成其他骨架的动画。 (通常这些骨架应该具有相同的骨架结构)
	 * @param toArmature 指定的骨架。
	 * @param fromArmatreName 其他骨架的名称。
	 * @param fromSkinName 其他骨架的皮肤名称，如果未设置，则使用默认皮肤。
	 * @param fromDragonBonesDataName 其他骨架属于的龙骨数据名称，如果未设置，则检索所有龙骨数据。
	 * @param ifRemoveOriginalAnimationList 是否移除原有的动画。 [true: 移除, false: 不移除]
	 * @return 是否替换成功。 [true: 成功, false: 不成功]
	 * @see dragonBones.Armature
	 * @version DragonBones 4.5
	 */
	public function copyAnimationsToArmature(
		toArmature:Armature, fromArmatreName:String, fromSkinName:String = null,
		fromDragonBonesDataName:String = null, ifRemoveOriginalAnimationList:Bool = true
	):Bool
	{
		var dataPackage:BuildArmaturePackage = new BuildArmaturePackage();
		if (_fillBuildArmaturePackage(dataPackage, fromDragonBonesDataName, fromArmatreName, fromSkinName, null))
		{
			var fromArmatureData:ArmatureData = dataPackage.armature;
			if (ifRemoveOriginalAnimationList)
			{
				toArmature.animation.animations = fromArmatureData.animations;
			}
			else
			{
				var animations = new Map<String, AnimationData>();
				var animationName:String = null;
				for (animationName in toArmature.animation.animations.keys())
				{
					animations[animationName] = toArmature.animation.animations[animationName];
				}
				
				for (animationName in fromArmatureData.animations.keys())
				{
					animations[animationName] = fromArmatureData.animations[animationName];
				}
				
				toArmature.animation.animations = animations;
			}
			
			if (dataPackage.skin != null)
			{
				var slots:Vector<Slot> = toArmature.getSlots();
				var l:UInt = slots.length;
				var toSlot:Slot, toSlotDisplayList:Vector<Dynamic>, lA:UInt, toDisplayObject:Dynamic, displays:Vector<DisplayData>, fromDisplayData:DisplayData;
				for (i in 0...l)
				{
					toSlot = slots[i];
					toSlotDisplayList = toSlot.displayList;
					lA = toSlotDisplayList.length;
					for (iA in 0...lA)
					{
						toDisplayObject = toSlotDisplayList[iA];
						if (Std.is(toDisplayObject, Armature))
						{
							displays = dataPackage.skin.getSlot(toSlot.name).displays;
							if (iA < displays.length)
							{
								fromDisplayData = displays[iA];
								if (fromDisplayData.type == DisplayType.Armature)
								{
									copyAnimationsToArmature(cast(toDisplayObject, Armature), fromDisplayData.path, fromSkinName, fromDragonBonesDataName, ifRemoveOriginalAnimationList);
								}
							}
						}
					}
				}
				
				return true;
			}
		}
		
		return false;
	}
	/**
	 * @language zh_CN
     * 用指定资源替换插槽的显示对象。
	 * @param dragonBonesName 指定的龙骨数据名称。
	 * @param armatureName 指定的骨架名称。
	 * @param slotName 指定的插槽名称。
	 * @param displayName 指定的显示对象名称。
	 * @param slot 指定的插槽实例。
	 * @param displayIndex 要替换的显示对象的索引，如果未设置，则替换当前正在显示的显示对象。
	 * @version DragonBones 4.5
	 */
	public function replaceSlotDisplay(dragonBonesName:String, armatureName:String, slotName:String, displayName:String, slot:Slot, displayIndex:Int = -1):Void
	{
		var dataPackage:BuildArmaturePackage = new BuildArmaturePackage();
		if (_fillBuildArmaturePackage(dataPackage, dragonBonesName, armatureName, null, null))
		{
			var skinSlotData:SkinSlotData = dataPackage.skin.getSlot(slotName);
			if (skinSlotData != null)
			{
				var l:UInt = skinSlotData.displays.length;
				var displayData:DisplayData;
				for (i in 0...l)
				{
					displayData = skinSlotData.displays[i];
					if (displayData.name == displayName)
					{
						_replaceSlotDisplay(dataPackage, displayData, slot, displayIndex);
						break;
					}
				}
			}
		}
	}
	/**
	 * @language zh_CN
     * 用指定资源列表替换插槽的显示对象列表。
	 * @param dragonBonesName 指定的 DragonBonesData 名称。
	 * @param armatureName 指定的骨架名称。
	 * @param slotName 指定的插槽名称。
	 * @param slot 指定的插槽实例。
	 * @version DragonBones 4.5
	 */
	public function replaceSlotDisplayList(dragonBonesName:String, armatureName:String, slotName:String, slot:Slot):Void
	{
		var dataPackage:BuildArmaturePackage = new BuildArmaturePackage();
		if (_fillBuildArmaturePackage(dataPackage, dragonBonesName, armatureName, null, null))
		{
			var skinSlotData:SkinSlotData = dataPackage.skin.getSlot(slotName);
			if (skinSlotData != null)
			{
				var l:UInt = skinSlotData.displays.length;
				var displayData:DisplayData;
				for (i in 0...l)
				{
					displayData = skinSlotData.displays[i];
					_replaceSlotDisplay(dataPackage, displayData, slot, i);
				}
			}
		}
	}
	/** 
	 * @private 
	 */
	private var allDragonBonesData (get, never):Map<String, DragonBonesData>;
	private function get_allDragonBonesData():Dynamic
	{
		return _dragonBonesDataMap;
	}
	/** 
	 * @private 
	 */
	private var allTextureAtlasData (get, never):Map<String, TextureAtlasData>;
	private function get_allTextureAtlasData():Dynamic
	{
		return _textureAtlasDataMap;
	}
	
	/** 
	 * @language zh_CN
	 * Draw smoothing.
	 * @version DragonBones 3.0
	 */
	public var smoothing:Bool = true;
	/** 
	 * @language zh_CN
	 * Scale for texture.
	 * @version DragonBones 3.0
	 */
	public var scaleForTexture:Float = 0;
	
	private var _delay:Timer;
	//private var _delayID:UInt = 0;
	private var _decodeDataList:Vector<DecodedData> = new Vector<DecodedData>();
	private function _loadTextureAtlasHandler(event:Event):Void
	{
		var loaderInfo:LoaderInfo = cast(event.target, LoaderInfo);
		var decodeData:DecodedData = cast(loaderInfo.loader, DecodedData);
		loaderInfo.removeEventListener(Event.COMPLETE, _loadTextureAtlasHandler);
		parseTextureAtlasData(decodeData.textureAtlasData, decodeData.content, decodeData.name, scaleForTexture, 1);
		decodeData.dispose();
		_decodeDataList.splice(_decodeDataList.indexOf(decodeData), 1);
		if (_decodeDataList.length == 0)
		{
			dispatchEvent(event);
		}
	}
}