package dragonBones.flixel;

import dragonBones.Slot;
import dragonBones.core.BaseObject;
import dragonBones.enums.BlendMode;
import dragonBones.utils.Utility;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.Vector;

using flixel.util.FlxArrayUtil;

typedef GraphicsTrianglePath = {
	uvtData:Vector<Float>,
	indices:Vector<Int>,
	vertices:Vector<Float>
}

@:allow(dragonBones) @:final class FlixelSlot extends Slot
 {
	private var _renderDisplay:FlixelMeshDisplay = null;
	private var _meshTexture:BitmapData = null;
	private var _flxSpriteGroup:FlxTypedGroup<FlixelMeshDisplay> = null;
	private var _path:GraphicsTrianglePath;
	
	private function new() 
	{
		super();
	}

	private function _initFlxSpriteGroup(flxSpriteGroup:FlxTypedGroup<FlixelMeshDisplay>):Void 
	{
		_flxSpriteGroup = flxSpriteGroup;
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
		_renderDisplay = _armature.display;
	}

	override private function _addDisplay():Void
	{
	}

	override private function _replaceDisplay(prevDisplay:Dynamic):Void
	{
		var displayObject:FlixelMeshDisplay = cast prevDisplay;
		_flxSpriteGroup.add(_renderDisplay);
		_flxSpriteGroup.replace(_renderDisplay, displayObject);
		_flxSpriteGroup.remove(displayObject);
	}

	override private function _removeDisplay():Void
	{
		_flxSpriteGroup.remove(_renderDisplay);
	}

	override private function _updateZOrder():Void
	{	
		var index:Int = _flxSpriteGroup.members.indexOf(_renderDisplay);
		if(index == _zOrder) {
			return;
		}

		//_flxSpriteGroup.members.splice(index, 1);
		_flxSpriteGroup.members.fastSplice(_renderDisplay);

		//_flxSpriteGroup.members.insert(_zOrder, _renderDisplay);
		_flxSpriteGroup.insert(_zOrder, _renderDisplay);
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
		var currentTextureData:FlixelTextureData = _textureData != null ? cast _textureData : null;
		var currentTextureAtlasData:FlixelTextureAtlasData = cast(currentTextureData.parent, FlixelTextureAtlasData);

		var imageData:BitmapData = cast(currentTextureData.parent, FlixelTextureAtlasData).texture;
			
		var bitmapCrop = new BitmapData(Std.int(currentTextureData.region.width), Std.int(currentTextureData.region.height));
		bitmapCrop.copyPixels(imageData, currentTextureData.region, new openfl.geom.Point(0, 0));

		if (isMeshDisplay) // Mesh.
		{
			_renderDisplay = new FlixelMeshDisplay();
			_renderDisplay._armature = _armature;

			var currentTextureAtlas:BitmapData = currentTextureAtlasData.texture;
			var textureAtlasWidth:Float = currentTextureAtlasData.width > 0.0 ? currentTextureAtlasData.width : currentTextureAtlas.width;
			var textureAtlasHeight:Float = currentTextureAtlasData.height > 0.0 ? currentTextureAtlasData.height : currentTextureAtlas.height;

			_path = {
				uvtData : new Vector<Float>(_meshData.uvs.length, true),
				indices : new Vector<Int>(_meshData.vertexIndices.length, true),
				vertices : new Vector<Float>(_meshData.vertices.length, true)
			};

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

			_flxSpriteGroup.add(cast _renderDisplay);
			
		} else 
		{ 
			_renderDisplay = cast (new FlixelArmatureDisplay());
			_renderDisplay._armature = _armature;
			
			_renderDisplay.loadGraphic(cast bitmapCrop);

			_flxSpriteGroup.add(cast _renderDisplay);
		}
		_updateVisible();
	}

	override private function _updateMesh():Void
	{
		
		var meshDisplay:FlixelMeshDisplay = cast _renderDisplay;
		var hasFFD:Bool = _ffdVertices.length > 0;
		
		var i:Int = 0, iH:Int = 0, iF:Int = 0, l:Int = _meshData.vertices.length;
		var xG:Float = 0, yG:Float = 0;

		if (hasFFD)
		{
			var vertices:Array<Float> = _meshData.vertices;
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
		
	}

	/**
	 * @private
	 */
	
	private function getGlobalScaleX(scalable:Float) {
		return scalable * _renderDisplay.gScaleX;
	}

	private function getGlobalScaleY(scalable:Float) {
		return scalable * _renderDisplay.gScaleY;
	}

	override private function _updateTransform(isSkinnedMesh:Bool):Void
	{
		_renderDisplay.x = (_renderDisplay.globalX + -(_pivotX) + getGlobalScaleX(globalTransformMatrix.tx));
		_renderDisplay.y = (_renderDisplay.globalY + -(_pivotY) + getGlobalScaleY(globalTransformMatrix.ty));
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