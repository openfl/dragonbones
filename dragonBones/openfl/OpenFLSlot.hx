package dragonBones.openfl;

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.GraphicsTrianglePath;
import openfl.display.Shape;
import openfl.geom.Matrix;
import openfl.Vector;

import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.core.BaseObject;
import dragonBones.enums.BlendMode;


/**
 * @language zh_CN
 * 基于 OpenFL 传统显示列表的插槽。
 * @version DragonBones 3.0
 */
@:allow(dragonBones) class OpenFLSlot extends Slot
{
	private var _renderDisplay:DisplayObject;
	private var _meshTexture:BitmapData;
	private var _path:GraphicsTrianglePath;
	/**
	 * @private
	 */
	private function new() {}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		super._onClear();
		
		_renderDisplay = null;
		_meshTexture = null;
		_path = null;
	}
	/**
	 * @private
	 */
	override private function _initDisplay(value:Dynamic):Void
	{
	}
	/**
	 * @private
	 */
	override private function _disposeDisplay(value:Dynamic):Void
	{
	}
	/**
	 * @private
	 */
	override private function _onUpdateDisplay():Void
	{
		_renderDisplay = cast((_display? _display : _rawDisplay), DisplayObject);
	}
	/**
	 * @private
	 */
	override private function _addDisplay():Void
	{
		var container:OpenFLArmatureDisplay = cast(_armature.display, OpenFLArmatureDisplay);
		container.addChild(_renderDisplay);
	}
	/**
	 * @private
	 */
	override private function _replaceDisplay(prevDisplay:Dynamic):Void
	{
		var container:OpenFLArmatureDisplay = cast(_armature.display, OpenFLArmatureDisplay);
		var displayObject:DisplayObject = cast(prevDisplay, DisplayObject);
		container.addChild(_renderDisplay);
		container.swapChildren(_renderDisplay, displayObject);
		container.removeChild(displayObject);
	}
	/**
	 * @private
	 */
	override private function _removeDisplay():Void
	{
		_renderDisplay.parent.removeChild(_renderDisplay);
	}
	/**
	 * @private
	 */
	override private function _updateZOrder():Void
	{
		var container:OpenFLArmatureDisplay = cast(_armature.display, OpenFLArmatureDisplay);
		var index:Int = container.getChildIndex(_renderDisplay);
		if (index == _zOrder) 
		{
			return;
		}
		
		container.addChildAt(_renderDisplay, _zOrder < index ? _zOrder : _zOrder + 1);
	}
	/**
	 * @private
	 */
	override private function _updateVisible():Void
	{
		_renderDisplay.visible = _parent.visible;
	}
	/**
	 * @private
	 */
	override private function _updateBlendMode():Void
	{
		switch (_blendMode) 
		{
			case dragonBones.enums.BlendMode.Normal:
				_renderDisplay.blendMode = openfl.display.BlendMode.NORMAL;
			
			case dragonBones.enums.BlendMode.Add:
				_renderDisplay.blendMode = openfl.display.BlendMode.ADD;
			
			case dragonBones.enums.BlendMode.Alpha:
				_renderDisplay.blendMode = openfl.display.BlendMode.ALPHA;
			
			case dragonBones.enums.BlendMode.Darken:
				_renderDisplay.blendMode = openfl.display.BlendMode.DARKEN;
			
			case dragonBones.enums.BlendMode.Difference:
				_renderDisplay.blendMode = openfl.display.BlendMode.DIFFERENCE;
			
			case dragonBones.enums.BlendMode.Erase:
				_renderDisplay.blendMode = openfl.display.BlendMode.ERASE;
			
			case dragonBones.enums.BlendMode.HardLight:
				_renderDisplay.blendMode = openfl.display.BlendMode.HARDLIGHT;
			
			case dragonBones.enums.BlendMode.Invert:
				_renderDisplay.blendMode = openfl.display.BlendMode.INVERT;
			
			case dragonBones.enums.BlendMode.Layer:
				_renderDisplay.blendMode = openfl.display.BlendMode.LAYER;
			
			case dragonBones.enums.BlendMode.Lighten:
				_renderDisplay.blendMode = openfl.display.BlendMode.LIGHTEN;
			
			case dragonBones.enums.BlendMode.Multiply:
				_renderDisplay.blendMode = openfl.display.BlendMode.MULTIPLY;
			
			case dragonBones.enums.BlendMode.Overlay:
				_renderDisplay.blendMode = openfl.display.BlendMode.OVERLAY;
			
			case dragonBones.enums.BlendMode.Screen:
				_renderDisplay.blendMode = openfl.display.BlendMode.SCREEN;
			
			case dragonBones.enums.BlendMode.Subtract:
				_renderDisplay.blendMode = openfl.display.BlendMode.SUBTRACT;
			
			default:
		}
	}
	/**
	 * @private
	 */
	override private function _updateColor():Void
	{
		_renderDisplay.transform.colorTransform = _colorTransform;
	}
	/**
	 * @private
	 */
	override private function _updateFrame():Void
	{
		var isMeshDisplay:Bool = _meshData != null && _renderDisplay == _meshDisplay;
		var currentTextureData:OpenFLTextureData = cast(_textureData, OpenFLTextureData);
		
		if (_displayIndex >= 0 && _display != null && currentTextureData != null)
		{
			var currentTextureAtlasData:OpenFLTextureAtlasData = cast(currentTextureData.parent, OpenFLTextureAtlasData);
			
			// Update replaced texture atlas.
			if (_armature.replacedTexture != null && _displayData != null && currentTextureAtlasData == _displayData.texture.parent) 
			{
				currentTextureAtlasData = cast(_armature._replaceTextureAtlasData, OpenFLTextureAtlasData);
				if (currentTextureAtlasData == null) 
				{
					currentTextureAtlasData = cast BaseObject.borrowObject(OpenFLTextureAtlasData);
					currentTextureAtlasData.copyFrom(_textureData.parent);
					currentTextureAtlasData.texture = cast(_armature.replacedTexture, BitmapData);
					_armature._replaceTextureAtlasData = currentTextureAtlasData;
				}
				
				currentTextureData = cast(currentTextureAtlasData.getTexture(currentTextureData.name), OpenFLTextureData);
			}
			
			var currentTextureAtlas:BitmapData = currentTextureAtlasData.texture;
			if (currentTextureAtlas != null)
			{
				var textureAtlasWidth:Float = currentTextureAtlasData.width > 0.0 ? currentTextureAtlasData.width : currentTextureAtlas.width;
				var textureAtlasHeight:Float = currentTextureAtlasData.height > 0.0 ? currentTextureAtlasData.height : currentTextureAtlas.height;
				
				if (isMeshDisplay != null) // Mesh.
				{
					var meshDisplay:Shape = cast(_renderDisplay, Shape);
					
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
					
					var i:UInt = 0, l:UInt = _path.uvtData.length;
					var u:Float, v:Float;
					while (i < l)
					{
						u = _meshData.uvs[i];
						v = _meshData.uvs[i + 1];
						_path.uvtData[i] = (currentTextureData.region.x + u * currentTextureData.region.width) / textureAtlasWidth;
						_path.uvtData[i + 1] = (currentTextureData.region.y + v * currentTextureData.region.height) / textureAtlasHeight;
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
					
					meshDisplay.graphics.clear();
					
					if (currentTextureAtlas != null)
					{
						meshDisplay.graphics.beginBitmapFill(currentTextureAtlas, null, false, true);
						meshDisplay.graphics.drawTriangles(_path.vertices, _path.indices, _path.uvtData);
					}
					
					_meshTexture = currentTextureAtlas;
				}
				else // Normal texture.
				{
					var width:Float = 0;
					var height:Float = 0;
					if (currentTextureData.rotated)
					{
						width = currentTextureData.region.height;
						height = currentTextureData.region.width;
					}
					else
					{
						height = currentTextureData.region.height;
						width = currentTextureData.region.width;
					}
					
					var scale:Float = 1 / currentTextureData.parent.scale;
					
					if (currentTextureData.rotated)
					{
						_helpMatrix.a = 0;
						_helpMatrix.b = -scale;
						_helpMatrix.c = scale;
						_helpMatrix.d = 0;
						_helpMatrix.tx = -_pivotX - currentTextureData.region.y;
						_helpMatrix.ty = -_pivotY + currentTextureData.region.x + height;
					}
					else
					{
						_helpMatrix.a = scale;
						_helpMatrix.b = 0;
						_helpMatrix.c = 0;
						_helpMatrix.d = scale;
						_helpMatrix.tx = -_pivotX - currentTextureData.region.x;
						_helpMatrix.ty = -_pivotY - currentTextureData.region.y;
					}
					
					var normalDisplay:Shape = cast(_renderDisplay, Shape);
					
					normalDisplay.graphics.clear();
					
					if (currentTextureAtlas != null)
					{
						normalDisplay.graphics.beginBitmapFill(currentTextureAtlas, _helpMatrix, false, true);
						normalDisplay.graphics.drawRect(-_pivotX, -_pivotY, width, height);
					}
				}
				
				_updateVisible();
				
				return;
			}
		}
		
		if (isMeshDisplay)
		{
			meshDisplay = cast _renderDisplay;
			meshDisplay.graphics.clear();
			meshDisplay.visible = false;
			meshDisplay.x = 0.0;
			meshDisplay.y = 0.0;
		}
		else
		{
			normalDisplay = cast _renderDisplay;
			normalDisplay.graphics.clear();
			normalDisplay.visible = false;
			normalDisplay.x = 0.0;
			normalDisplay.y = 0.0;
		}
	}
	/**
	 * @private
	 */
	override private function _updateMesh():Void
	{
		var meshDisplay:Shape = _renderDisplay as Shape;
		
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
				
				xG = 0, yG = 0;
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
	}
	/**
	 * @private
	 */
	override private function _updateTransform(isSkinnedMesh:Bool):Void
	{
		if (isSkinnedMesh)
		{
			_renderDisplay.transform.matrix = null;
		}
		else
		{
			_renderDisplay.transform.matrix = globalTransformMatrix;
		}
	}
}