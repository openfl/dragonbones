package dragonBones.flixel;

import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.Lib;
import openfl.Vector;
import openfl.utils.Object;

import dragonBones.Armature;
import dragonBones.Slot;
import dragonBones.animation.WorldClock;
import dragonBones.core.BaseObject;
import dragonBones.enums.DisplayType;
import dragonBones.factories.BaseFactory;
import dragonBones.factories.BuildArmaturePackage;
import dragonBones.objects.ActionData;
import dragonBones.objects.BoneData;
import dragonBones.objects.DisplayData;
import dragonBones.objects.SkinSlotData;
import dragonBones.objects.SlotData;
import dragonBones.parsers.DataParser;
import dragonBones.textures.TextureAtlasData;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.DragonBonesData;
import dragonBones.objects.SkinData;

import dragonBones.flixel.FlixelTextureAtlasData;
import dragonBones.flixel.FlixelTextureData;

import flixel.FlxG;
import flixel.FlxObject;

@:allow(dragonBones) @:final class FlixelFactory extends BaseFactory {

	public static var _eventManager:FlixelArmatureDisplay = new FlixelArmatureDisplay();
	public static var factory:FlixelFactory = new FlixelFactory();
	public static var _clock:WorldClock = new WorldClock();

	private function _clockHandler(event:Event):Void 
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
	private function _generateArmatureFlixel(dataPackage:FlixelBuildArmaturePackage):Armature
	{
		if (!FlxG.stage.hasEventListener(Event.ENTER_FRAME))
		{
			_clock.time = Lib.getTimer() * 0.001;
			FlxG.stage.addEventListener(Event.ENTER_FRAME, _clockHandler, false, -999999);
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
	
	private function _generateSlotFlixel(dataPackage:FlixelBuildArmaturePackage, skinSlotData:SkinSlotData, armature:Armature):Slot
	{
		var slot:FlixelSlot = cast BaseObject.borrowObject(FlixelSlot);
		var slotData:SlotData = skinSlotData.slot;
		var displayList:Vector<Object> = new Vector<Object>();
		var flxDataPackage:FlixelBuildArmaturePackage = cast dataPackage;

		// Make last parameter mesh display.
		slot._initFlixel(flxDataPackage.flxArmatureGroup, skinSlotData, new FlixelArmatureDisplay(), new FlixelArmatureDisplay());

		var l:UInt = skinSlotData.displays.length;
		var displayData:DisplayData, childArmature:Armature, actions:Vector<ActionData>;
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
								childArmature.animation.play();
							}
						}
						
						displayData.armature = childArmature.armatureData;
					}
					
					displayList[i] = childArmature;
				default:
					displayList[i] = null;
			}
		}
		
		slot._setDisplayList(displayList);
		
		return slot;
	}

	public function buildArmatureDisplay(collider:FlixelArmatureCollider, armatureName:String, dragonBonesName:String = null, skinName:String = null, textureAtlasName:String = null):Dynamic
	{
		var flxArmatureGroup:FlixelArmatureGroup = new FlixelArmatureGroup(collider);

		var armature:Armature = buildArmatureFlixel(armatureName, dragonBonesName, skinName, textureAtlasName, flxArmatureGroup);

		if (armature != null)
		{
			_clock.add(armature);
			return flxArmatureGroup;
		}
		
		return null;
	}

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

	public function buildArmatureFlixel(armatureName:String, dragonBonesName:String = null, skinName:String = null, textureAtlasName:String = null, flxArmatureGroup:FlixelArmatureGroup):Armature
	{
		var dataPackage:FlixelBuildArmaturePackage = new FlixelBuildArmaturePackage();
		if (_fillBuildArmaturePackageFlixel(flxArmatureGroup, dataPackage, dragonBonesName, armatureName, skinName, textureAtlasName))
		{
			var armature:Armature = _generateArmatureFlixel(dataPackage);
			_buildBonesFlixel(dataPackage, armature);
			_buildSlotsFlixel(dataPackage, armature);
			
			armature.invalidUpdate(null, true);
			armature.advanceTime(0.0); // Update armature pose.
			return armature;
		}
		
		return null;
	}

	private function _fillBuildArmaturePackageFlixel(flxArmatureGroup:FlixelArmatureGroup, dataPackage:FlixelBuildArmaturePackage, dragonBonesName:String, armatureName:String, skinName:String, textureAtlasName:String):Bool
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
			dataPackage.flxArmatureGroup = flxArmatureGroup;
			
			return true;
		}
		
		return false;
	}
	/** 
	 * @private
	 */
	private function _buildBonesFlixel(dataPackage:FlixelBuildArmaturePackage, armature:Armature):Void
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
	private function _buildSlotsFlixel(dataPackage:FlixelBuildArmaturePackage, armature:Armature):Void
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
			slot = _generateSlotFlixel(dataPackage, skinSlotData, armature);
			if (slot != null)
			{
				armature._addSlot(slot, slotData.parent.name);
				slot._armature = armature;
				slot._setDisplayIndex(slotData.displayIndex);
			}
		}
	}
}