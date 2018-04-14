package dragonBones.flixel;

import dragonBones.Slot;
import dragonBones.core.BaseObject;
import dragonBones.enums.BlendMode;
import dragonBones.utils.Utility;
import dragonBones.objects.SkinSlotData;	

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.Vector;
import openfl.display.GraphicsTrianglePath;

using flixel.util.FlxArrayUtil;

@:allow(dragonBones) @:final class FlixelSlot extends Slot
 {
	private var _renderDisplay:FlixelArmatureDisplay = null;
	private var _meshTexture:BitmapData = null;
	private var _flxArmatureGroup:FlixelArmatureGroup = null;
	private var _path:GraphicsTrianglePath;
	private var textureCache:Map<String, BitmapData> = new Map<String, BitmapData>();
	
	@:keep private function new() 
	{
		super();
	}

	private function _initFlixel(flxArmatureGroup:FlixelArmatureGroup, skinSlotData: SkinSlotData, rawDisplay:FlixelArmatureDisplay, meshDisplay:FlixelArmatureDisplay):Void {
		_flxArmatureGroup = flxArmatureGroup;

		this._init(skinSlotData, rawDisplay, meshDisplay);
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
		_renderDisplay = _display != null ? _display : _rawDisplay;
		_renderDisplay._armature = _armature;
	}

	override private function _addDisplay():Void
	{
		_flxArmatureGroup.add(_renderDisplay);
	}

	override private function _replaceDisplay(prevDisplay:Dynamic):Void
	{
		var displayObject:FlixelArmatureDisplay = cast prevDisplay;
		_flxArmatureGroup.add(_renderDisplay);
		_flxArmatureGroup.replace(_renderDisplay, displayObject);
		_flxArmatureGroup.remove(displayObject);
	}

	override private function _removeDisplay():Void
	{
		_flxArmatureGroup.remove(_renderDisplay);
	}

	override private function _updateZOrder():Void
	{	
		var index:Int = _flxArmatureGroup.members.indexOf(_renderDisplay);
		if(index == _zOrder) {
			return;
		}

		_flxArmatureGroup.members.fastSplice(_renderDisplay);
		_flxArmatureGroup.insert(_zOrder, _renderDisplay);
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
		var isMeshDisplay:Bool = _meshData != null;
		var lastSlotImage:String = this._displayData.texture.name;
		var bitmapCrop:BitmapData;

		if(textureCache.exists(lastSlotImage)){
			bitmapCrop = textureCache.get(lastSlotImage);
		} else {
			var currentTextureData:FlixelTextureData = _textureData != null ? cast _textureData : null;
			var currentTextureAtlasData:FlixelTextureAtlasData = cast(currentTextureData.parent, FlixelTextureAtlasData);

			var imageData:BitmapData = cast(currentTextureData.parent, FlixelTextureAtlasData).texture;
				
			bitmapCrop = new BitmapData(Std.int(currentTextureData.region.width), Std.int(currentTextureData.region.height));
			bitmapCrop.copyPixels(imageData, currentTextureData.region, new openfl.geom.Point(0, 0));
			
			textureCache.set(lastSlotImage, bitmapCrop);
		}
		
		// Mesh results inconsistent until Flixel branch is stable.
		/* 
		if (isMeshDisplay) // Mesh.
		{
			_renderDisplay = new FlixelArmatureDisplay();
			_renderDisplay._armature = _armature;

			var currentTextureAtlas:BitmapData = currentTextureAtlasData.texture;
			var textureAtlasWidth:Float = currentTextureAtlasData.width > 0.0 ? currentTextureAtlasData.width : currentTextureAtlas.width;
			var textureAtlasHeight:Float = currentTextureAtlasData.height > 0.0 ? currentTextureAtlasData.height : currentTextureAtlas.height;

			if (_path != null)
			{
				_path.uvtData.fixed = false;
				_path.vertices.fixed = false;
				_path.indices.fixed = false;
				
				_path.uvtData.length = _meshData.uvs.length;
				_path.vertices.length = _meshData.vertices.length;
				_path.indices.length = _meshData.vertexIndices.length;
				
				_path.uvtData.fixed = true;
				_path.vertices.fixed = true;
				_path.indices.fixed = true;
			}
			else
			{
				_path = new GraphicsTrianglePath(
					new Vector<Float>(_meshData.uvs.length, true),
					new Vector<Int>(_meshData.vertexIndices.length, true),
					new Vector<Float>(_meshData.vertices.length, true)
				);
			}

			var i:Int = 0, l:Int = _path.uvtData.length;
			var u:Float, v:Float;
			while (i < l)
			{
				u = _meshData.uvs[i];
				v = _meshData.uvs[i + 1];
				_path.uvtData[i] = u;
				_path.uvtData[i + 1] = v;
				i += 2;
			}
			
			i = 0;
			l = _path.vertices.length;
			while (i < l)
			{
				_path.vertices[i] = _meshData.vertices[i] - _pivotX;
				_path.vertices[i + 1] = _meshData.vertices[i + 1] - _pivotY;
				i += 2;
			}
			
			l = _path.indices.length;
			for (i in 0...l)
			{
				_path.indices[i] = _meshData.vertexIndices[i];
			}

			_renderDisplay.vertices = _path.vertices;
			_renderDisplay.indices = _path.indices;
			_renderDisplay.uvtData = _path.uvtData;
			
			_renderDisplay.loadGraphic(cast bitmapCrop);

			_flxArmatureGroup.add(cast _renderDisplay);
			
		} else 
		{ 
		*/

		var normalDisplay:FlixelArmatureDisplay = _renderDisplay;
		normalDisplay.loadGraphic(cast bitmapCrop);
		
		_updateVisible();
	}

	override private function _updateMesh():Void
	{
		// Mesh results inconsistent until Flixel branch is stable.
		/* 
		var meshDisplay:FlixelArmatureDisplay = cast _renderDisplay;
		var hasFFD:Bool = _ffdVertices.length > 0;
		
		var i:Int = 0, iH:Int = 0, iF:Int = 0, l:Int = _meshData.vertices.length;
		var xG:Float = 0, yG:Float = 0;

		if (hasFFD)
		{
			var vertices:Vector<Float> = _meshData.vertices;
			while (i < l)
			{
				xG = vertices[i] + _ffdVertices[i];
				yG = vertices[i + 1] + _ffdVertices[i + 1];
				_path.vertices[i] = getGlobalScaleX(xG - _pivotX);
				_path.vertices[i + 1] = getGlobalScaleY(yG - _pivotY);
				i += 2;
			}
			
			meshDisplay.vertices = _path.vertices;
			meshDisplay.indices = _path.indices;
			meshDisplay.uvtData = _path.uvtData;
			meshDisplay.draw();
		}	
		*/
	}

	/**
	 * @private
	 */
	
	private function getGlobalScaleX(scalable:Float) {
		return scalable * _renderDisplay.scaleX;
	}

	private function getGlobalScaleY(scalable:Float) {
		return scalable * _renderDisplay.scaleY;
	}

	private function updatePosition():Void
	{
		_renderDisplay.offset.x = -(-(_pivotX) + getGlobalScaleX(globalTransformMatrix.tx));
		_renderDisplay.offset.y = -(-(_pivotY) + getGlobalScaleY(globalTransformMatrix.ty));
	}

	override private function _updateTransform(isSkinnedMesh:Bool):Void
	{
		_renderDisplay.offset.x = -(-(_pivotX) + getGlobalScaleX(globalTransformMatrix.tx));
		_renderDisplay.offset.y = -(-(_pivotY) + getGlobalScaleY(globalTransformMatrix.ty));

		_renderDisplay.angle = Utility.getAngle(globalTransformMatrix);
		_renderDisplay.scale.set( 
			getGlobalScaleX(Math.sqrt(Math.pow(globalTransformMatrix.a, 2) + Math.pow(globalTransformMatrix.c, 2))),  
			getGlobalScaleY(Math.sqrt(Math.pow(globalTransformMatrix.b, 2) + Math.pow(globalTransformMatrix.d, 2)))
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