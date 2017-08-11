package dragonBones.flixel;

import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.Lib;

import dragonBones.Armature;
import dragonBones.Slot;
import dragonBones.animations.WorldClock;
import dragonBones.core.BaseObject;
import dragonBones.enums.DisplayType;
import dragonBones.factories.BaseFactory;
import dragonBones.factories.BuildArmaturePackage;
import dragonBones.objects.ActionData;
import dragonBones.objects.DisplayData;
import dragonBones.objects.SkinSlotData;
import dragonBones.objects.SlotData;
import dragonBones.parsers.DataParser;
import dragonBones.textures.TextureAtlasData;

import dragonBones.flixel.FlixelTextureAtlasData;
import dragonBones.flixel.FlixelTextureData;

import flixel.group.FlxGroup;

@:allow(dragonBones) @:final class FlixelFactory extends BaseFactory {

	private static var _eventManager:EventDispatcher = new EventDispatcher();
	private static var _clock:WorldClock = new WorldClock();

	public static var factory:FlixelFactory = new FlixelFactory();
	public static var _flxSpriteGroup:FlxTypedGroup<FlixelArmatureDisplay> = new FlxTypedGroup<FlixelArmatureDisplay>();

	private static function _clockHandler(event:Event):Void 
	{
		var time:Float = Lib.getTimer() * 0.001;
		var passedTime:Float = time - _clock.time;
		_clock.advanceTime(passedTime);
		_clock.time = time;
	}

	public function new(dataParser:DataParser = null)
	{
		super(dataParser);
	}
	// BaseFactory.hx: parseTextureAtlasData();
	override private function _generateTextureAtlasData(textureAtlasData:TextureAtlasData, textureAtlas:Dynamic):TextureAtlasData
	{
		if (textureAtlasData != null)
		{
			if (Std.is(textureAtlas, BitmapData))
			{
				cast(textureAtlasData, FlixelTextureAtlasData).texture = cast textureAtlas;
			}
		}
		else
		{
			textureAtlasData = cast BaseObject.borrowObject(FlixelTextureAtlasData);
		}
		
		return textureAtlasData;
	}
	/**
	 * @private
	 */
	 //BaseFactory.hx: buildArmature(): _generateArmature()
	override private function _generateArmature(dataPackage:BuildArmaturePackage):Armature
	{
		if (!_eventManager.hasEventListener(Event.ENTER_FRAME))
		{
			_clock.time = Lib.getTimer() * 0.001;
			_eventManager.addEventListener(Event.ENTER_FRAME, _clockHandler, false, -999999);
		}
		
		var armature:Armature = cast BaseObject.borrowObject(Armature);
		var armatureDisplay:FlixelArmatureDisplay = new FlixelArmatureDisplay();
		armatureDisplay._armature = armature;
		
		armature._init(
			dataPackage.armature, dataPackage.skin,
			armatureDisplay, armatureDisplay, cast _eventManager
		);
		
		return armature;
	}
	//BaseFactory.hx: buildArmature(): _buildSlots(): _generateSlot()
	override private function _generateSlot(dataPackage:BuildArmaturePackage, skinSlotData:SkinSlotData, armature:Armature):Slot
	{
		var slot:FlixelSlot = cast BaseObject.borrowObject(FlixelSlot);
		var slotData:SlotData = skinSlotData.slot;
		var displayList:Array<Dynamic> = new Array<Dynamic>();
		
		slot._initFlxSpriteGroup(_flxSpriteGroup);
		slot._init(skinSlotData, null, null);
		var l:UInt = skinSlotData.displays.length;
		var displayData:DisplayData, childArmature:Armature, actions:Array<ActionData>;
		for (i in 0...l)
		{
			displayData = skinSlotData.displays[i];
			switch (displayData.type)
			{
				case DisplayType.Image:
					if (displayData.texture == null || dataPackage.textureAtlasName != null)
					{
						displayData.texture = _getTextureData(dataPackage.textureAtlasName != null ? dataPackage.textureAtlasName : dataPackage.dataName, displayData.name);
					}
					
					displayList[i] = slot.rawDisplay;
				case DisplayType.Mesh:
					if (displayData.texture == null)
					{
						displayData.texture = _getTextureData(dataPackage.dataName, displayData.path);
					}
					
					if (dataPackage.textureAtlasName != null)
					{
						slot._textureDatas[i] = _getTextureData(dataPackage.textureAtlasName, displayData.path);
					}
					
					displayList[i] = slot.meshDisplay;
				case DisplayType.Armature:
					childArmature = buildArmature(displayData.name, dataPackage.dataName, null, dataPackage.textureAtlasName);
					if (childArmature != null) 
					{
						if (!childArmature.inheritAnimation)
						{
							actions = slotData.actions.length > 0? slotData.actions: childArmature.armatureData.actions;
							if (actions.length > 0) 
							{
								for (action in actions) 
								{
									childArmature._bufferAction(action);
								}
							} 
							else 
							{
								childArmature.animations.play();
							}
						}
						
						displayData.armature = childArmature.armatureData; // 
					}
					
					displayList[i] = childArmature;
				default:
					displayList[i] = null;
			}
		}
		
		slot._setDisplayList(displayList);
		
		return slot;
	}

	public function buildArmatureDisplay(armatureName:String, dragonBonesName:String = null, skinName:String = null, textureAtlasName:String = null):Dynamic
	{
		var armature:Armature = buildArmature(armatureName, dragonBonesName, skinName, textureAtlasName);
		if (armature != null)
		{
			_clock.add(armature);
			trace(_flxSpriteGroup.members);
			return cast _flxSpriteGroup;
		}
		
		return null;
	}
	/**
	 * @language zh_CN
	 * 获取带有指定贴图的显示对象。
	 * @param textureName 指定的贴图名称。
	 * @param textureAtlasName 指定的贴图集数据名称，如果未设置，将检索所有的贴图集数据。
	 * @version DragonBones 3.0
	 */
	public function getTextureDisplay(textureName:String, textureAtlasName:String = null):BitmapData
	{
		var textureData:FlixelTextureData = cast _getTextureData(textureAtlasName, textureName);
		if (textureData != null)
		{
			if (textureData.texture == null)
			{
				return null;
			}
			
			return textureData.texture;
		}
		
		return null;
	}

}