package dragonBones.openfl;

import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.geom.Matrix;
//import openfl.utils.getTimer;
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
import dragonBones.objects.DisplayData;
import dragonBones.objects.SkinSlotData;
import dragonBones.objects.SlotData;
import dragonBones.parsers.DataParser;
import dragonBones.textures.TextureAtlasData;


/**
 * @language zh_CN
 * 基于 Flash 传统显示列表的工厂。
 * @version DragonBones 3.0
 */
@:allow(dragonBones) class OpenFLFactory extends BaseFactory
{
	/**
	 * @private
	 */
	private static var _eventManager:OpenFLArmatureDisplay = new OpenFLArmatureDisplay();
	/**
	 * @private
	 */
	static var _clock:WorldClock = new WorldClock();
	/**
	 * @language zh_CN
	 * 一个可以直接使用的全局工厂实例.
	 * @version DragonBones 4.7
	 */
	public static var factory:OpenFLFactory = new OpenFLFactory();
	/**
	 * @private
	 */
	private static function _clockHandler(event:Event):Void 
	{
		var time:Float = Lib.getTimer() * 0.001;
		var passedTime:Float = time - _clock.time;
		_clock.advanceTime(passedTime);
		_clock.time = time;
	}
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
			if (Std.is(textureAtlas, BitmapData))
			{
				cast(textureAtlasData, OpenFLTextureAtlasData).texture = cast textureAtlas;
			}
		}
		else
		{
			textureAtlasData = cast BaseObject.borrowObject(OpenFLTextureAtlasData);
		}
		
		return textureAtlasData;
	}
	/**
	 * @private
	 */
	override private function _generateArmature(dataPackage:BuildArmaturePackage):Armature
	{
		if (!_eventManager.hasEventListener(Event.ENTER_FRAME))
		{
			_clock.time = Lib.getTimer() * 0.001;
			_eventManager.addEventListener(Event.ENTER_FRAME, _clockHandler, false, -999999);
		}
		
		var armature:Armature = cast BaseObject.borrowObject(Armature);
		var armatureDisplay:OpenFLArmatureDisplay = new OpenFLArmatureDisplay();
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
		var slot:OpenFLSlot = cast BaseObject.borrowObject(OpenFLSlot);
		var slotData:SlotData = skinSlotData.slot;
		var displayList:Vector<Object> = new Vector<Object>(skinSlotData.displays.length, true);
		var slotDisplay:Shape = new Shape();
		
		slot._init(skinSlotData, slotDisplay, slotDisplay);
		
		var l:UInt = skinSlotData.displays.length;
		var displayData:DisplayData, childArmature:Armature, actions:Vector<ActionData>;
		for (i in 0...l)
		{
			displayData = skinSlotData.displays[i];
			switch (displayData.type)
			{
				case DisplayType.Image:
					if (displayData.texture == null)
					{
						displayData.texture = _getTextureData(dataPackage.dataName, displayData.path);
					}
					
					if (dataPackage.textureAtlasName != null)
					{
						slot._textureDatas[i] = _getTextureData(dataPackage.textureAtlasName, displayData.path);
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
					childArmature = buildArmature(displayData.path, dataPackage.dataName, null, dataPackage.textureAtlasName);
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
	 * @see dragonBones.flash.FlashArmatureDisplay
	 * @version DragonBones 4.5
	 */
	public function buildArmatureDisplay(armatureName:String, dragonBonesName:String = null, skinName:String = null, textureAtlasName:String = null):OpenFLArmatureDisplay
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
	public function getTextureDisplay(textureName:String, textureAtlasName:String = null):Shape 
	{
		var textureData:OpenFLTextureData = cast _getTextureData(textureAtlasName, textureName);
		if (textureData != null)
		{
			var width:Float = 0;
			var height:Float = 0;
			if (textureData.rotated)
			{
				width = textureData.region.height;
				height = textureData.region.width;
			}
			else
			{
				height = textureData.region.height;
				width = textureData.region.width;
			}
			
			var scale:Float = 1 / textureData.parent.scale;
			var helpMatrix:Matrix = new Matrix();
			
			if (textureData.rotated)
			{
				helpMatrix.a = 0;
				helpMatrix.b = -scale;
				helpMatrix.c = scale;
				helpMatrix.d = 0;
				helpMatrix.tx = - textureData.region.y;
				helpMatrix.ty = textureData.region.x + height;
			}
			else
			{
				helpMatrix.a = scale;
				helpMatrix.b = 0;
				helpMatrix.c = 0;
				helpMatrix.d = scale;
				helpMatrix.tx = - textureData.region.x;
				helpMatrix.ty = - textureData.region.y;
			}
			
			var shape:Shape = new Shape();
			shape.graphics.beginBitmapFill(cast(textureData.parent, OpenFLTextureAtlasData).texture, helpMatrix, false, true);
			shape.graphics.drawRect(0, 0, width, height);
			
			return shape;
		}
		
		return null;
	}
	/**
	 * @language zh_CN
	 * 获取全局声音事件管理器。
	 * @version DragonBones 3.0
	 */
	public var soundEventManager(get, never):OpenFLArmatureDisplay;
	private function get_soundEventManager(): OpenFLArmatureDisplay
	{
		return _eventManager;
	}
}
