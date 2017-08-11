package dragonBones.flixel;

import dragonBones.Slot;
import dragonBones.core.BaseObject;
import dragonBones.enums.BlendMode;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;

@:allow(dragonBones) @:final class FlixelSlot extends Slot
 {
	private var _renderDisplay:FlixelArmatureDisplay = null;
	private var _meshTexture:BitmapData = null;
	private var _flxSpriteGroup:FlxTypedGroup<FlixelArmatureDisplay> = null;
	private var _path:FlixelArmatureDisplay;
	
	private function new() 
	{
		super();

	}

	private function _initFlxSpriteGroup(flxSpriteGroup:FlxTypedGroup<FlixelArmatureDisplay>):Void 
	{
		this._flxSpriteGroup = flxSpriteGroup;
	}

	override private function _onClear():Void 
	{
		super._onClear();
	}

	override private function _initDisplay(value:Dynamic):Void 
	{
	}

	override private function _disposeDisplay(value:Dynamic):Void
	{
	}
	
	override private function _onUpdateDisplay():Void
	{
		_renderDisplay = new FlixelArmatureDisplay();
		_renderDisplay._armature = _armature;
	}

	override private function _addDisplay():Void
	{
		this._flxSpriteGroup.add(_renderDisplay);
	}

	override private function _replaceDisplay(prevDisplay:Dynamic):Void
	{
		var displayObject:FlixelArmatureDisplay = cast(prevDisplay, FlixelArmatureDisplay);
		this._flxSpriteGroup.add(_renderDisplay);
		this._flxSpriteGroup.replace(_renderDisplay, displayObject);
		this._flxSpriteGroup.remove(displayObject);
	}

	override private function _removeDisplay():Void
	{
		this._flxSpriteGroup.remove(_renderDisplay);
	}

	override private function _updateZOrder():Void
	{
		var container:FlixelArmatureDisplay = cast _armature.display;

		for(i in 0...this._flxSpriteGroup.members.length) {
			if(this._flxSpriteGroup.members[i] == _renderDisplay) {
				if (i == _zOrder) 
				{
					return;
				}
			}
		}

		this._flxSpriteGroup.insert(_zOrder, _renderDisplay);
	}

	override private function _updateVisible():Void
	{
		_renderDisplay.visible = _parent.visible;
	}
	
	override private function _updateBlendMode():Void
	{
		switch (_blendMode) 
		{
			case dragonBones.enums.BlendMode.Normal:						
				_renderDisplay.blend = openfl.display.BlendMode.NORMAL;
			
			case dragonBones.enums.BlendMode.Add:
				_renderDisplay.blend = openfl.display.BlendMode.ADD;
			
			case dragonBones.enums.BlendMode.Alpha:
				_renderDisplay.blend = openfl.display.BlendMode.ALPHA;
			
			case dragonBones.enums.BlendMode.Darken:
				_renderDisplay.blend = openfl.display.BlendMode.DARKEN;
			
			case dragonBones.enums.BlendMode.Difference:
				_renderDisplay.blend = openfl.display.BlendMode.DIFFERENCE;
			
			case dragonBones.enums.BlendMode.Erase:
				_renderDisplay.blend = openfl.display.BlendMode.ERASE;
			
			case dragonBones.enums.BlendMode.HardLight:
				_renderDisplay.blend = openfl.display.BlendMode.HARDLIGHT;
			
			case dragonBones.enums.BlendMode.Invert:
				_renderDisplay.blend = openfl.display.BlendMode.INVERT;
			
			case dragonBones.enums.BlendMode.Layer:
				_renderDisplay.blend = openfl.display.BlendMode.LAYER;
			
			case dragonBones.enums.BlendMode.Lighten:
				_renderDisplay.blend = openfl.display.BlendMode.LIGHTEN;
			
			case dragonBones.enums.BlendMode.Multiply:
				_renderDisplay.blend = openfl.display.BlendMode.MULTIPLY;
			
			case dragonBones.enums.BlendMode.Overlay:
				_renderDisplay.blend = openfl.display.BlendMode.OVERLAY;
			
			case dragonBones.enums.BlendMode.Screen:
				_renderDisplay.blend = openfl.display.BlendMode.SCREEN;
			
			case dragonBones.enums.BlendMode.Subtract:
				_renderDisplay.blend = openfl.display.BlendMode.SUBTRACT;
			
			default:
		}
	}

	override private function _updateFrame():Void
	{
		var isMeshDisplay:Bool = _meshData != null && _renderDisplay == _meshDisplay;
		var currentTextureData:FlixelTextureData = _textureData != null ? cast _textureData : null;
		var normalDisplay:FlixelArmatureDisplay;
		
		var imageData:BitmapData = cast(currentTextureData.parent, FlixelTextureAtlasData).texture;
		
		var bitmapCrop = new BitmapData(Std.int(currentTextureData.region.width), Std.int(currentTextureData.region.height));
		bitmapCrop.copyPixels(imageData, currentTextureData.region, new openfl.geom.Point(0, 0));

		normalDisplay = cast _renderDisplay;
		normalDisplay.loadGraphic(cast bitmapCrop);
		

		this._flxSpriteGroup.add(normalDisplay);
		_updateVisible();
	}

	override private function _updateMesh():Void
	{
		
	}

	/**
	 * @private
	 */
	private var scaleX:Float;
	private var rad:Float;
	private var deg:Float;
	private var sign:Float;
	private var rotation:Float;
	private var rotationInDegree:Float;
	private static var degree:Float = (180 / Math.PI);
	private static var radian:Float = (Math.PI / 180);

	private function getAngle(matrix:Matrix):Float
	{
		scaleX = Math.sqrt((matrix.a * matrix.a) + (matrix.c * matrix.c));
		//scaleY = Math.sqrt((matrix.b * matrix.b) + (matrix.d * matrix.d));
		
		sign = Math.atan(-matrix.c / matrix.a);
		rad  = Math.acos(matrix.a / scaleX);
		deg  = rad * degree;

		if (deg > 90 && sign > 0)
		{
				rotation = (360 - deg) * radian;
		}
		else if (deg < 90 && sign < 0)
		{
				rotation = (360 - deg) * radian;
		}
		else
		{
				rotation = rad;
		}

		rotationInDegree = rotation * degree;

		return rotationInDegree;
	}

	private function getGlobalScaleX(scalable:Float) {
		return scalable * _renderDisplay.gScaleY;
	}

	private function getGlobalScaleY(scalable:Float) {
		return scalable * _renderDisplay.gScaleY;
	}

	override private function _updateTransform(isSkinnedMesh:Bool):Void
	{
		_renderDisplay.x = (_renderDisplay.worldX + -(_pivotX) + this.getGlobalScaleX(globalTransformMatrix.tx));
		_renderDisplay.y = (_renderDisplay.worldY + -(_pivotY) + this.getGlobalScaleY(globalTransformMatrix.ty));
		_renderDisplay.angle = this.getAngle(globalTransformMatrix);
		_renderDisplay.scale.set( 
			this.getGlobalScaleX(Math.sqrt(Math.pow(globalTransformMatrix.a, 2) + Math.pow(globalTransformMatrix.c, 2))),  
			this.getGlobalScaleY(Math.sqrt(Math.pow(globalTransformMatrix.b, 2) + Math.pow(globalTransformMatrix.d, 2)))
		);
	}

	override private function _updateColor():Void
	{
		_renderDisplay.setColorTransform(
			_colorTransform.redMultiplier, 
			_colorTransform.greenMultiplier, 
			_colorTransform.blueMultiplier, 
			_colorTransform.alphaMultiplier, 
			Std.int(_colorTransform.redOffset), 
			Std.int(_colorTransform.greenOffset), 
			Std.int(_colorTransform.blueOffset), 
			Std.int(_colorTransform.alphaOffset)
		);
	}

}