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
	private var _path:FlixelArmatureDisplay;

	private function new() 
	{
		super();

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
		/*
		var meshDisplay:Shape = cast _renderDisplay;
		
		if (_meshTexture == null)
		{
			return;	
		}
		
		var hasFFD:Bool = _ffdVertices.length > 0;
		
		var i:UInt = 0, iH:UInt = 0, iF:UInt = 0, l:UInt = _meshData.vertices.length;
		var xG:Float = 0, yG:Float = 0;
		if (_meshData.skinned)
		{
			meshDisplay.graphics.clear();
			
			var boneIndices:Vector<UInt>, boneVertices:Vector<Float>, weights:Vector<Float>;
			var lB:UInt, bone:Bone, matrix:Matrix, weight:Float, xL:Float, yL:Float;
			
			while (i < l)
			{
				iH = Std.int(i / 2);
				
				boneIndices = _meshData.boneIndices[iH];
				boneVertices = _meshData.boneVertices[iH];
				weights = _meshData.weights[iH];
				
				xG = 0;
				yG = 0;
				lB = boneIndices.length;
				
				for (iB in 0...lB)
				{
					bone = _meshBones[boneIndices[iB]];
					matrix = bone.globalTransformMatrix;
					weight = weights[iB];
					
					xL = 0;
					yL = 0;
					if (hasFFD)
					{
						xL = boneVertices[iB * 2] + _ffdVertices[iF];
						yL = boneVertices[iB * 2 + 1] + _ffdVertices[iF + 1];
					}
					else
					{
						xL = boneVertices[iB * 2];
						yL = boneVertices[iB * 2 + 1];
					}
					
					
					xG += (matrix.a * xL + matrix.c * yL + matrix.tx) * weight;
					yG += (matrix.b * xL + matrix.d * yL + matrix.ty) * weight;
					
					iF += 2;
				}
				
				_path.vertices[i] = xG - _pivotX;
				_path.vertices[i + 1] = yG - _pivotY;
				
				i += 2;
			}
			
			meshDisplay.graphics.beginBitmapFill(_meshTexture, null, false, true);
			meshDisplay.graphics.drawTriangles(_path.vertices, _path.indices, _path.uvtData);
		}
		else if (hasFFD)
		{
			meshDisplay.graphics.clear();
			
			var vertices:Vector<Float> = _meshData.vertices;
			while (i < l)
			{
				xG = vertices[i] + _ffdVertices[i];
				yG = vertices[i + 1] + _ffdVertices[i + 1];
				_path.vertices[i] = xG - _pivotX;
				_path.vertices[i + 1] = yG - _pivotY;
				i += 2;
			}
			
			meshDisplay.graphics.beginBitmapFill(_meshTexture, null, true, true);
			meshDisplay.graphics.drawTriangles(_path.vertices, _path.indices, _path.uvtData);
		}
		*/
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

	override private function _updateTransform(isSkinnedMesh:Bool):Void
	{
		_renderDisplay.x = _renderDisplay.worldX + -(_pivotX) + globalTransformMatrix.tx;
		_renderDisplay.y = _renderDisplay.worldY + -(_pivotY) + globalTransformMatrix.ty;
		_renderDisplay.angle = this.getAngle(globalTransformMatrix);
		_renderDisplay.scale.set( 
			Math.sqrt(Math.pow(globalTransformMatrix.a, 2) + Math.pow(globalTransformMatrix.c, 2)),  
			Math.sqrt(Math.pow(globalTransformMatrix.b, 2) + Math.pow(globalTransformMatrix.d, 2))
		);
	}

	override private function _updateColor():Void
	{

	}

}