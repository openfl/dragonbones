package dragonBones.starling;

import openfl.geom.Matrix;
import openfl.Vector;

import dragonBones.Slot;
import dragonBones.core.BaseObject;
import dragonBones.enums.BlendMode;

import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.textures.SubTexture;
import starling.textures.Texture;

#if (starling >= "2.0")
import dragonBones.Bone;
import starling.display.Mesh;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.styles.MeshStyle;
#end


/**
 * @language zh_CN
 * Starling 插槽。
 * @version DragonBones 3.0
 */
@:allow(dragonBones) @:final class StarlingSlot extends Slot
{
	#if (starling < "2.0")
	private static var _emptyEtexture:Texture = null;
	/**
	 * @private
	 */
	private static function getEmptyTexture():Texture
	{
		if (_emptyEtexture == null)
		{
			_emptyEtexture = Texture.empty(1, 1);
		}
		
		return _emptyEtexture;
	}
	#end
	
	public var transformUpdateEnabled:Bool;
	
	#if (starling >= "2.0")
	/**
	 * @private
	 */
	private var _indexData:IndexData;
	/**
	 * @private
	 */
	private var _vertexData:VertexData;
	#end
	
	private var _renderDisplay:DisplayObject;
	/**
	 * @private
	 */
	@:keep private function new()
	{
		super();
	}
	/**
	 * @private
	 */
	override private function _onClear():Void
	{
		super._onClear();
		
		transformUpdateEnabled = false;
		
		#if (starling >= "2.0")
		if (_indexData != null)
		{
			_indexData.clear();
			_indexData = null;
		}
		
		if (_vertexData != null)
		{
			_vertexData.clear();
			_vertexData = null;
		}
		#end
		
		_renderDisplay = null;
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
		cast(value, DisplayObject).dispose();
	}
	/**
	 * @private
	 */
	override private function _onUpdateDisplay():Void
	{
		_renderDisplay = _display != null ? _display : _rawDisplay;
	}
	/**
	 * @private
	 */
	override private function _addDisplay():Void
	{
		var container:StarlingArmatureDisplay = cast _armature.display;
		container.addChild(_renderDisplay);
	}
	/**
	 * @private
	 */
	override private function _replaceDisplay(value:Dynamic):Void
	{
		var container:StarlingArmatureDisplay = cast _armature.display;
		var prevDisplay:DisplayObject = cast(value, DisplayObject);
		container.addChild(_renderDisplay);
		container.swapChildren(_renderDisplay, prevDisplay);
		container.removeChild(prevDisplay);
	}
	/**
	 * @private
	 */
	override private function _removeDisplay():Void
	{
		_renderDisplay.removeFromParent();
	}
	/**
	 * @private
	 */
	override private function _updateZOrder():Void
	{
		var container:StarlingArmatureDisplay = cast _armature.display;
		var index:Int = container.getChildIndex(_renderDisplay);
		if (index == _zOrder) 
		{
			return;
		}
		
		container.addChildAt(_renderDisplay, _zOrder);
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
				_renderDisplay.blendMode = starling.display.BlendMode.AUTO;
			
			case dragonBones.enums.BlendMode.Add:
				_renderDisplay.blendMode = starling.display.BlendMode.ADD;
			
			case dragonBones.enums.BlendMode.Erase:
				_renderDisplay.blendMode = starling.display.BlendMode.ERASE;
			
			case dragonBones.enums.BlendMode.Multiply:
				_renderDisplay.blendMode = starling.display.BlendMode.MULTIPLY;
			
			case dragonBones.enums.BlendMode.Screen:
				_renderDisplay.blendMode = starling.display.BlendMode.SCREEN;
			
			default:
		}
	}
	/**
	 * @private
	 */
	override private function _updateColor():Void
	{
		_renderDisplay.alpha = _colorTransform.alphaMultiplier;
		
		var quad:Quad = Std.is(_renderDisplay, Quad) ? cast _renderDisplay : null;
		if (quad != null)
		{
			var color:UInt = (Std.int(_colorTransform.redMultiplier * 0xFF) << 16) + (Std.int(_colorTransform.greenMultiplier * 0xFF) << 8) + Std.int(_colorTransform.blueMultiplier * 0xFF);
			if (quad.color != color)
			{
				quad.color = color;
			}
		}
	}
	/**
	 * @private
	 */
	override private function _updateFrame():Void
	{
		var isMeshDisplay:Bool = _meshData != null && _renderDisplay == _meshDisplay;
		var currentTextureData:StarlingTextureData = _textureData != null ? cast _textureData : null;
		var normalDisplay:Image;

		#if (starling >= "2.0")
		var meshDisplay:Mesh = cast _meshDisplay;
		#end
		
		if (_displayIndex >= 0 && _display != null && currentTextureData != null)
		{
			var currentTextureAtlasData:StarlingTextureAtlasData = currentTextureData.parent != null ? cast currentTextureData.parent : null;
			
			// Update replaced texture atlas.
			if (_armature.replacedTexture != null && _displayData != null && currentTextureAtlasData == _displayData.texture.parent) 
			{
				currentTextureAtlasData = _armature._replaceTextureAtlasData != null ? cast(_armature._replaceTextureAtlasData, StarlingTextureAtlasData) : null;
				if (currentTextureAtlasData == null) 
				{
					currentTextureAtlasData = cast BaseObject.borrowObject(StarlingTextureAtlasData);
					currentTextureAtlasData.copyFrom(_textureData.parent);
					currentTextureAtlasData.texture = cast _armature.replacedTexture;
					_armature._replaceTextureAtlasData = currentTextureAtlasData;
				}
				
				currentTextureData = cast currentTextureAtlasData.getTexture(currentTextureData.name);
			}
			
			var currentTextureAtlas:Texture = currentTextureAtlasData.texture;
			if (currentTextureAtlas != null)
			{
				if (currentTextureData.texture == null) // Create texture.
				{
					currentTextureData.texture = new SubTexture(currentTextureAtlas, currentTextureData.region, false, null, currentTextureData.rotated);
				}
				
				if (isMeshDisplay) // Mesh.
				{
					#if (starling >= "2.0")
					_indexData.clear();
					_vertexData.clear();
					
					var l:UInt = _meshData.vertexIndices.length;
					for (i in 0...l)
					{
						_indexData.setIndex(i, _meshData.vertexIndices[i]);
					}
					
					var meshStyle:MeshStyle = meshDisplay.style;
					var i:UInt = 0;
					l = _meshData.uvs.length;
					var iH:UInt;
					while (i < l)
					{
						iH = Std.int(i / 2);
						meshStyle.setTexCoords(iH, _meshData.uvs[i], _meshData.uvs[i + 1]);
						meshStyle.setVertexPosition(iH, _meshData.vertices[i], _meshData.vertices[i + 1]);
						i += 2;
					}
					
					meshDisplay.texture = currentTextureData.texture;
					meshDisplay.pivotX = _pivotX;
					meshDisplay.pivotY = _pivotY;
					#end
				}
				else // Normal texture.
				{
					normalDisplay = cast _renderDisplay;
					normalDisplay.texture = currentTextureData.texture;
					normalDisplay.readjustSize();
					normalDisplay.pivotX = _pivotX;
					normalDisplay.pivotY = _pivotY;
				}
				
				_updateVisible();
				
				return;
			}
		}
		
		if (isMeshDisplay)
		{
			#if (starling >= "2.0")
			meshDisplay = cast _renderDisplay;
			meshDisplay.visible = false;
			meshDisplay.texture = null;
			meshDisplay.x = 0.0;
			meshDisplay.y = 0.0;
			#end
		}
		else
		{
			normalDisplay = cast _renderDisplay;
			normalDisplay.visible = false;
			normalDisplay.texture = #if (starling < "2.0") getEmptyTexture() #else null #end;
			normalDisplay.readjustSize();
			normalDisplay.x = 0.0;
			normalDisplay.y = 0.0;
		}
	}
	/**
	 * @private
	 */
	override private function _updateMesh():Void
	{
		#if (starling >= "2.0")
		var meshDisplay:Mesh = cast _renderDisplay;
		var meshStyle:MeshStyle = meshDisplay.style;
		var hasFFD:Bool = _ffdVertices.length > 0;
		
		var i:UInt = 0, iH:UInt = 0, iF:UInt = 0, l:UInt = _meshData.vertices.length;
		var xG:Float = 0, yG:Float = 0;
		if (_meshData.skinned)
		{
			var boneIndices:Vector<UInt>, boneVertices:Vector<Float>, weights:Vector<Float>, lB:UInt;
			var bone:Bone, matrix:Matrix, weight:Float, xL:Float, yL:Float;
			i = 0;
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
				
				meshStyle.setVertexPosition(iH, xG, yG);
				i += 2;
			}
		}
		else if (hasFFD)
		{
			var vertices:Vector<Float> = _meshData.vertices;
			i = 0;
			while (i < l)
			{
				xG = vertices[i] + _ffdVertices[i];
				yG = vertices[i + 1] + _ffdVertices[i + 1];
				meshStyle.setVertexPosition(Math.floor(i / 2), xG, yG);
				i += 2;
			}
		}
		#end
	}
	/**
	 * @private
	 */
	override private function _updateTransform(isSkinnedMesh:Bool):Void
	{
		var displayMatrix:Matrix;
		
		if (isSkinnedMesh)
		{
			displayMatrix = _renderDisplay.transformationMatrix;
			displayMatrix.identity();
			_renderDisplay.transformationMatrix = displayMatrix;
		}
		else
		{
			if (transformUpdateEnabled)
			{
				_renderDisplay.transformationMatrix = globalTransformMatrix;
				
				if (_pivotX != 0 || _pivotY != 0)
				{
					_renderDisplay.pivotX = _pivotX;
					_renderDisplay.pivotY = _pivotY;
				}
			}
			else
			{
				displayMatrix = _renderDisplay.transformationMatrix;
				displayMatrix.a = globalTransformMatrix.a;
				displayMatrix.b = globalTransformMatrix.b;
				displayMatrix.c = globalTransformMatrix.c;
				displayMatrix.d = globalTransformMatrix.d;
				displayMatrix.tx = globalTransformMatrix.tx - (globalTransformMatrix.a * _pivotX + globalTransformMatrix.c * _pivotY);
				displayMatrix.ty = globalTransformMatrix.ty - (globalTransformMatrix.b * _pivotX + globalTransformMatrix.d * _pivotY);
				
				#if (starling >= "2.0")
				//
				_renderDisplay.setRequiresRedraw();
				#end
			}
		}
	}
}