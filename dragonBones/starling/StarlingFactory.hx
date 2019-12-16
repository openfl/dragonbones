package dragonBones.starling;

import openfl.display.BitmapData;
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
import dragonBones.objects.DisplayData;
import dragonBones.objects.SkinSlotData;
import dragonBones.objects.SlotData;
import dragonBones.parsers.DataParser;
import dragonBones.textures.TextureAtlasData;

import starling.core.Starling;
import starling.display.Image;
import starling.events.EnterFrameEvent;
import starling.textures.SubTexture;
import starling.textures.Texture;

#if (starling >= "2.0")
import starling.display.Mesh;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
#end


/**
 * @language zh_CN
 * Starling 工厂。
 * @version DragonBones 3.0
 */
@:allow(dragonBones) @:final class StarlingFactory extends BaseFactory
{
	/**
	 * @private
	 */
	private static var _eventManager:StarlingArmatureDisplay = new StarlingArmatureDisplay();
	/**
	 * @private
	 */
	static var _clock:WorldClock = new WorldClock();
	/**
	 * @language zh_CN
	 * 一个可以直接使用的全局工厂实例.
	 * @version DragonBones 4.7
	 */
	public static var factory:StarlingFactory = new StarlingFactory();
	/**
	 * @private
	 */
	private static function _clockHandler(event:EnterFrameEvent):Void 
	{
		_clock.advanceTime(event.passedTime);
	}
	
	public var generateMipMaps:Bool = true;
	
	/**
	 * @language zh_CN
	 * 创建一个工厂。
	 * @version DragonBones 3.0
	 */
	public function new(dataParser:DataParser = null)
	{
		super(dataParser);
	}
	/**
	 * @private
	 */
	override private function _generateTextureAtlasData(textureAtlasData:TextureAtlasData, textureAtlas:Dynamic):TextureAtlasData
	{
		if (textureAtlasData != null)
		{
			var starlingTextureAtlasData:StarlingTextureAtlasData = cast textureAtlasData;
			
			if (Std.is(textureAtlas, BitmapData))
			{
				starlingTextureAtlasData.texture = Texture.fromBitmapData(cast textureAtlas, generateMipMaps, false, textureAtlasData.scale);
				starlingTextureAtlasData._disposeTexture = true;
				
				#if (starling < "2.0")
				if (starlingTextureAtlasData.bitmapData != null && !Starling.handleLostContext)
				{
					starlingTextureAtlasData.bitmapData.dispose();
					starlingTextureAtlasData.bitmapData = null;
				}
				#end
			}
			else if (Std.is(textureAtlas, Texture))
			{
				cast(textureAtlasData, StarlingTextureAtlasData).texture = cast textureAtlas;
			}
		}
		else
		{
			textureAtlasData = cast BaseObject.borrowObject(StarlingTextureAtlasData);
		}
		
		return textureAtlasData;
	}
	/**
	 * @private
	 */
	override private function _generateArmature(dataPackage:BuildArmaturePackage):Armature
	{
		if (Starling.current != null && !Starling.current.stage.hasEventListener(EnterFrameEvent.ENTER_FRAME, _clockHandler))
		{
			Starling.current.stage.addEventListener(EnterFrameEvent.ENTER_FRAME, _clockHandler);
		}
		
		var armature:Armature = cast BaseObject.borrowObject(Armature);
		var armatureDisplay:StarlingArmatureDisplay = new StarlingArmatureDisplay();
		armatureDisplay._armature = armature;
		
		armature._init(
			dataPackage.armature, dataPackage.skin,
			armatureDisplay, armatureDisplay, _eventManager
		);
		
		return armature;
	}
	/**
	 * @private
	 */
	override private function _generateSlot(dataPackage:BuildArmaturePackage, skinSlotData:SkinSlotData, armature:Armature):Slot
	{
		var slot:StarlingSlot = cast BaseObject.borrowObject(StarlingSlot);
		var slotData:SlotData = skinSlotData.slot;
		var displayList:Vector<Object> = new Vector<Object>(skinSlotData.displays.length, true);
		
		#if (starling >= "2.0")
		slot._indexData = new IndexData();
		slot._vertexData = new VertexData();
		
		slot._init(skinSlotData, new Image(null), new Mesh(slot._vertexData, slot._indexData));
		#else
		slot._init(skinSlotData, new Image(StarlingSlot.getEmptyTexture()), null);
		#end
		
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
					if (displayData.texture == null #if (starling < "2.0") || dataPackage.textureAtlasName != null #end)
					{
						displayData.texture = _getTextureData(dataPackage.textureAtlasName != null ? dataPackage.textureAtlasName : dataPackage.dataName, displayData.name);
					}
					
					displayList[i] = #if (starling >= "2.0") slot.meshDisplay #else slot.rawDisplay #end;
				
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
	
	/**
	 * @language zh_CN
	 * 创建一个指定名称的骨架，并使用骨架的显示容器来更新骨架动画。
	 * @param armatureName 骨架数据名称。
	 * @param dragonBonesName 龙骨数据名称，如果未设置，将检索所有的龙骨数据，当多个数据中包含同名的骨架数据时，可能无法创建出准确的骨架。
	 * @param skinName 皮肤名称，如果未设置，则使用默认皮肤。
	 * @param textureAtlasName 贴图集数据名称，如果未设置，则使用龙骨数据名称。
	 * @return 骨架的显示容器。
	 * @see dragonBones.starling.StarlingArmatureDisplay
	 * @version DragonBones 4.5
	 */
	public function buildArmatureDisplay(armatureName:String, dragonBonesName:String = null, skinName:String = null, textureAtlasName:String = null):StarlingArmatureDisplay
	{
		var armature:Armature = buildArmature(armatureName, dragonBonesName, skinName, textureAtlasName);
		if (armature != null)
		{
			_clock.add(armature);
			return cast armature.display;
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
	public function getTextureDisplay(textureName:String, textureAtlasName:String = null):Image 
	{
		var textureData:StarlingTextureData = cast _getTextureData(textureAtlasName, textureName);
		if (textureData != null)
		{
			if (textureData.texture == null)
			{
				var textureAtlasTexture:Texture = cast(textureData.parent, StarlingTextureAtlasData).texture;
				textureData.texture = new SubTexture(textureAtlasTexture, textureData.region, false, null, textureData.rotated);
			}
			
			return new Image(textureData.texture);
		}
		
		return null;
	}
	/**
	 * @language zh_CN
	 * 获取全局声音事件管理器。
	 * @version DragonBones 4.5
	 */
	public var soundEventManager(get, never):StarlingArmatureDisplay;
	private function get_soundEventManager(): StarlingArmatureDisplay
	{
		return _eventManager;
	}
}