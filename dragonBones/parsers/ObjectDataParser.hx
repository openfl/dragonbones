package dragonBones.parsers;

import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.Vector;

import dragonBones.core.BaseObject;
import dragonBones.core.DragonBones;
import dragonBones.enum.ActionType;
import dragonBones.enum.ArmatureType;
import dragonBones.enum.BlendMode;
import dragonBones.enum.BoundingBoxType;
import dragonBones.enum.DisplayType;
import dragonBones.enum.EventType;
import dragonBones.geom.Transform;
import dragonBones.objects.ActionData;
import dragonBones.objects.AnimationConfig;
import dragonBones.objects.AnimationData;
import dragonBones.objects.AnimationFrameData;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.BoneData;
import dragonBones.objects.BoneFrameData;
import dragonBones.objects.BoneTimelineData;
import dragonBones.objects.BoundingBoxData;
import dragonBones.objects.CustomData;
import dragonBones.objects.DisplayData;
import dragonBones.objects.DragonBonesData;
import dragonBones.objects.EventData;
import dragonBones.objects.ExtensionFrameData;
import dragonBones.objects.FFDTimelineData;
import dragonBones.objects.FrameData;
import dragonBones.objects.MeshData;
import dragonBones.objects.SkinData;
import dragonBones.objects.SkinSlotData;
import dragonBones.objects.SlotData;
import dragonBones.objects.SlotFrameData;
import dragonBones.objects.SlotTimelineData;
import dragonBones.objects.TimelineData;
import dragonBones.objects.TweenFrameData;
import dragonBones.objects.ZOrderFrameData;
import dragonBones.objects.ZOrderTimelineData;
import dragonBones.textures.TextureAtlasData;
import dragonBones.textures.TextureData;

/**
 * 
 */
class ObjectDataParser extends DataParser
{
	/**
	 * @private
	 */
	private static #if !js inline #end function _getBoolean(rawData:Dynamic, key:String, defaultValue:Bool):Bool
	{
		if (Reflect.hasField(rawData, key))
		{
			var value:Dynamic = Reflect.field(rawData, key);
			if (Std.is(value, Bool) || Std.is(value, Float))
			{
				return value;
			}
			else if (Std.is(value, String))
			{
				switch(value)
				{
					case "0":
					case "NaN":
					case "":
					case "false":
					case "null":
					case "undefined":
						return false;
						
					default:
						return true;
				}
			}
			else 
			{
				return value; // Boolean(value);
			}
		}
		
		return defaultValue;
	}
	/**
	 * @private
	 */
	private static #if !js inline #end function _getNumber(rawData:Dynamic, key:String, defaultValue:Float):Float
	{
		if (Reflect.hasField(rawData, key))
		{
			var value:Dynamic = Reflect.field(rawData, key);
			if (value == null || value == "NaN")
			{
				return defaultValue;
			}
			
			return value; // Number(value);
		}
		
		return defaultValue;
	}
	/**
	 * @private
	 */
	private static #if !js inline #end function _getString(rawData:Dynamic, key:String, defaultValue:String):String
	{
		if (Reflect.hasField(key, rawData))
		{
			return Std.string(Reflect.field(rawData, key)); // String(rawData[key]);
		}
		
		return defaultValue;
	}
	/**
	 * @private
	 */
	private function new() {}
	/**
	 * @private
	 */
	private function _parseArmature(rawData:Dynamic, scale:Float):ArmatureData
	{
		var armature:ArmatureData = cast BaseObject.borrowObject(ArmatureData);
		armature.name = _getString(rawData, NAME, null);
		armature.frameRate = _getNumber(rawData, FRAME_RATE, _data.frameRate) || _data.frameRate;
		armature.scale = scale;
		
		if (Reflect.hasField(rawData, TYPE) && Std.is(Reflect.field(rawData, TYPE), String)) 
		{
			armature.type = _getArmatureType(Reflect.field(rawData, TYPE));
		} 
		else 
		{
			armature.type = _getNumber(rawData, TYPE, ArmatureType.Armature);
		}
		
		_armature = armature;
		_rawBones.length = 0;
		
		if (Reflect.hasField (rawData, BONE))
		{
			var bone:BoneData;
			for (boneObject in cast(Reflect.field(rawData, BONE), Array<Dynamic>))
			{
				bone = _parseBone(boneObject);
				armature.addBone(bone, _getString(boneObject, PARENT, null));
				_rawBones.push(bone);
			}
		}
		
		if (Reflect.hasField(rawData, IK))
		{
			for (ikObject in cast(Reflect.field(rawData, IK), Array<Dynamic>))
			{
				_parseIK(ikObject);
			}
		}
		
		if (Reflect.hasField(rawData, SLOT))
		{
			var zOrder:Int = 0;
			for (slotObject in cast(Reflect.field(rawData, SLOT), Array<Dynamic>))
			{
				armature.addSlot(_parseSlot(slotObject, zOrder++));
			}
		}
		
		if (Reflect.hasField(rawData, SKIN))
		{
			for (skinObject in cast(Reflect.field(rawData, SKIN), Array<Dynamic>))
			{
				armature.addSkin(_parseSkin(skinObject));
			}
		}
		
		if (Reflect.hasField(rawData, ANIMATION))
		{
			for (animationObject in cast(Reflect.field(rawData, ANIMATION), Array<Dynamic>))
			{
				armature.addAnimation(_parseAnimation(animationObject));
			}
		}
		
		if (Reflect.hasField(rawData, ACTIONS) || Reflect.hasField(rawData, DEFAULT_ACTIONS))
		{
			_parseActionData(rawData, armature.actions, null, null);
		}
		
		if (_isOldData && _isGlobalTransform) // Support 2.x ~ 3.x data.
		{
			_globalToLocal(armature);
		}
		
		_armature = null;
		_rawBones.length = 0;
		
		return armature;
	}
	
	/**
	 * @private
	 */
	private function _parseBone(rawData:Dynamic):BoneData
	{
		var bone:BoneData = cast BaseObject.borrowObject(BoneData);
		bone.name = _getString(rawData, NAME, null);
		bone.inheritTranslation = _getBoolean(rawData, INHERIT_TRANSLATION, true);
		bone.inheritRotation = _getBoolean(rawData, INHERIT_ROTATION, true);
		bone.inheritScale = _getBoolean(rawData, INHERIT_SCALE, true);
		bone.length = _getNumber(rawData, LENGTH, 0) * _armature.scale;
		
		if (Reflect.hasField(rawData, TRANSFORM))
		{
			_parseTransform(Reflect.field(rawData, TRANSFORM), bone.transform);
		}
		
		if (_isOldData) // Support 2.x ~ 3.x data.
		{
			bone.inheritScale = false;
		}
		
		return bone;
	}
	
	/**
	 * @private
	 */
	private function _parseIK(rawData:Dynamic):Void
	{
		var bone:BoneData = _armature.getBone(_getString(rawData, Reflect.hasField(rawData, BONE)? BONE: NAME, null));
		if (bone != null)
		{
			bone.ik = _armature.getBone(_getString(rawData, TARGET, null));
			bone.bendPositive = _getBoolean(rawData, BEND_POSITIVE, true);
			bone.chain = _getNumber(rawData, CHAIN, 0);
			bone.weight = _getNumber(rawData, WEIGHT, 1);
			
			if (bone.chain > 0 && bone.parent != null && bone.parent.ik == null)
			{
				bone.parent.ik = bone.ik;
				bone.parent.chainIndex = 0;
				bone.parent.chain = 0;
				bone.chainIndex = 1;
			}
			else
			{
				bone.chain = 0;
				bone.chainIndex = 0;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function _parseSlot(rawData:Dynamic, zOrder:Int):SlotData
	{
		inline var slot:SlotData = cast BaseObject.borrowObject(SlotData);
		slot.name = _getString(rawData, NAME, null);
		slot.parent = _armature.getBone(_getString(rawData, PARENT, null));
		slot.displayIndex = _getNumber(rawData, DISPLAY_INDEX, 0);
		slot.zOrder = _getNumber(rawData, Z, zOrder); // Support 2.x ~ 3.x data.
		
		if (Reflect.hasField(rawData, COLOR))
		{
			slot.color = SlotData.generateColor();
			_parseColorTransform(Reflect.field(rawData, COLOR), slot.color);
		}
		else
		{
			slot.color = SlotData.DEFAULT_COLOR;
		}
		
		if (Reflect.hasField(rawData, BLEND_MODE) && Std.is(Reflect.field(rawData, BLEND_MODE), String))
		{
			
			slot.blendMode = _getBlendMode(Reflect.field(rawData, BLEND_MODE));
		}
		else
		{
			slot.blendMode = _getNumber(rawData, BLEND_MODE, BlendMode.Normal);
		}
		
		if (Reflect.hasField(rawData, ACTIONS) || Reflect.hasField(rawData, DEFAULT_ACTIONS))
		{
			_parseActionData(rawData, slot.actions, null, null);
		}
		
		if (_isOldData) // Support 2.x ~ 3.x data.
		{
			if (Reflect.hasField(rawData, COLOR_TRANSFORM)) 
			{
				slot.color = SlotData.generateColor();
				_parseColorTransform(Reflect.field(rawData, COLOR_TRANSFORM), slot.color);
			} 
			else 
			{
				slot.color = SlotData.DEFAULT_COLOR;
			}
		}
		
		return slot;
	}
	
	/**
	 * @private
	 */
	private function _parseSkin(rawData:Dynamic):SkinData
	{
		inline var skin:SkinData = cast BaseObject.borrowObject(SkinData);
		skin.name = _getString(rawData, NAME, DEFAULT_NAME);
		if (skin.name == null) skin.name = DEFAULT_NAME;
		
		if (Reflect.hasField(rawData, SLOT))
		{
			_skin = skin;
			var zOrder:Int = 0;
			for (slotObject in cast(Reflect.field(rawData, SLOT), Array<Dynamic>))
			{
				if (_isOldData != null) // Support 2.x ~ 3.x data.
				{
					_armature.addSlot(_parseSlot(slotObject, zOrder++));
				}
				
				skin.addSlot(_parseSlotDisplaySet(slotObject));
			}
			
			_skin = null;
		}
		
		return skin;
	}
	
	/**
	 * @private
	 */
	private function _parseSlotDisplaySet(rawData:Dynamic):SkinSlotData
	{
		var slotDisplayDataSet:SkinSlotData = cast BaseObject.borrowObject(SkinSlotData);
		slotDisplayDataSet.slot = _armature.getSlot(_getString(rawData, NAME, null));
		
		if (Reflect.hasField(rawData, DISPLAY))
		{
			var displayObjectSet:Array<Dynamic> = Reflect.field(rawData, DISPLAY);
			var displayDataSet:Vector<DisplayData> = slotDisplayDataSet.displays;
			
			_skinSlotData = slotDisplayDataSet;
			
			for (displayObject in displayObjectSet)
			{
				displayDataSet.push(_parseDisplay(displayObject));
			}
			
			displayDataSet.fixed = true;
			
			_skinSlotData = null;
		}
		
		return slotDisplayDataSet;
	}
	/**
	 * @private
	 */
	private function _parseDisplay(rawData:Dynamic):DisplayData
	{
		var display:DisplayData = cast BaseObject.borrowObject(DisplayData);
		display.name = _getString(rawData, NAME, null);
		display.path = _getString(rawData, PATH, display.name);
		
		if (Reflect.hasField(rawData, TYPE) && Std.is(Reflect.field(rawData, TYPE), String))
		{
			
			display.type = _getDisplayType(Reflect.field(rawData, TYPE));
		}
		else
		{
			display.type = _getNumber(rawData, TYPE, DisplayType.Image);
		}
		
		display.isRelativePivot = true;
		
		if (Reflect.hasField(rawData, PIVOT))
		{
			var rawPivot:Dynamic = Reflect.field(rawData, PIVOT);
			display.pivot.x = _getNumber(rawPivot, X, 0);
			display.pivot.y = _getNumber(rawPivot, Y, 0);
		}
		else if (_isOldData) // Support 2.x ~ 3.x data.
		{
			var rawTransform:Dynamic = Reflect.field(rawData, TRANSFORM);
			display.isRelativePivot = false;
			display.pivot.x = _getNumber(rawTransform, PIVOT_X, 0) * _armature.scale;
			display.pivot.y = _getNumber(rawTransform, PIVOT_Y, 0) * _armature.scale;
		}
		else
		{
			display.pivot.x = 0.5;
			display.pivot.y = 0.5;
		}
		
		if (Reflect.hasField(rawData, TRANSFORM))
		{
			_parseTransform(Reflect.field(rawData, TRANSFORM), display.transform);
		}
		
		switch (display.type)
		{
			case DisplayType.Image:
			
			case DisplayType.Armature:
			
			case DisplayType.Mesh:
				display.share = _getString(rawData, SHARE, null);
				if (!display.share) 
				{
					display.mesh = _parseMesh(rawData);
					_skinSlotData.addMesh(display.mesh);
				}
			
			case DisplayType.BoundingBox:
				display.boundingBox = _parseBoundingBox(rawData);
		}
		
		return display;
	}
	/**
	 * @private
	 */
	private function _parseBoundingBox(rawData:Dynamic): BoundingBoxData 
	{
		var boundingBox:BoundingBoxData = cast BaseObject.borrowObject(BoundingBoxData);
		
		if (Reflect.hasField (rawData, SUB_TYPE) && Std.is(Reflect.field(rawData, SUB_TYPE), String)) {
			boundingBox.type = _getBoundingBoxType(Reflect.field(rawData, SUB_TYPE));
		}
		else 
		{
			boundingBox.type = _getNumber(rawData, SUB_TYPE, BoundingBoxType.Rectangle);
		}
		
		boundingBox.color = _getNumber(rawData, COLOR, 0x000000);
		
		switch (boundingBox.type) 
		{
			case BoundingBoxType.Rectangle, BoundingBoxType.Ellipse:
				boundingBox.width = _getNumber(rawData, WIDTH, 0.0);
				boundingBox.height = _getNumber(rawData, HEIGHT, 0.0);
			
			case BoundingBoxType.Polygon:
				if (Reflect.hasField(rawData, VERTICES)) 
				{
					var rawVertices:Array<Dynamic> = Reflect.field(rawData, VERTICES);
					boundingBox.vertices.length = rawVertices.length;
					boundingBox.vertices.fixed = true;
					
					var i:UInt = 0;
					var l:UInt = boundingBox.vertices.length;
					var iN:UInt, x:Float, y:Float;
					while (i < l)
					{
						iN = i + 1;
						x = rawVertices[i];
						y = rawVertices[iN];
						boundingBox.vertices[i] = x;
						boundingBox.vertices[iN] = y;
						
						// AABB.
						if (i == 0) {
							boundingBox.x = x;
							boundingBox.y = y;
							boundingBox.width = x;
							boundingBox.height = y;
						}
						else 
						{
							if (x < boundingBox.x) 
							{
								boundingBox.x = x;
							}
							else if (x > boundingBox.width) 
							{
								boundingBox.width = x;
							}
							
							if (y < boundingBox.y) 
							{
								boundingBox.y = y;
							}
							else if (y > boundingBox.height) 
							{
								boundingBox.height = y;
							}
						}
						i += 2;
					}
				}
			
			default:
		}
		
		return boundingBox;
	}
	/**
	 * @private
	 */
	private function _parseMesh(rawData:Dynamic):MeshData
	{
		var mesh:MeshData = cast BaseObject.borrowObject(MeshData);
		
		var rawVertices:Array<Dynamic> = Reflect.field(rawData, VERTICES);
		var rawUVs:Array<Dynamic> = Reflect.field(rawData, UVS);
		var rawTriangles:Array<Dynamic> = Reflect.field(rawData, TRIANGLES);
		
		var numVertices:UInt = Std.int(rawVertices.length / 2);
		var numTriangles:UInt = Std.int(rawTriangles.length / 3);
		
		var inverseBindPose:Vector<Matrix> = new Vector<Matrix>(_armature.sortedBones.length, true);
		
		mesh.skinned = Reflect.hasField(rawData, WEIGHTS)&& cast(Reflect.field(rawData, WEIGHTS), Array<Dynamic>).length > 0;
		mesh.name = _getString(rawData, NAME, null);
		mesh.uvs.length = numVertices * 2;
		mesh.uvs.fixed = true;
		mesh.vertices.length = numVertices * 2;
		mesh.vertices.fixed = true;
		mesh.vertexIndices.length = numTriangles * 3;
		mesh.vertexIndices.fixed = true;
		
		var l:UInt = 0;
		var i:UInt = 0;
		
		if (mesh.skinned)
		{
			mesh.boneIndices.length = numVertices;
			mesh.boneIndices.fixed = true;
			mesh.weights.length = numVertices;
			mesh.weights.fixed = true;
			mesh.boneVertices.length = numVertices;
			mesh.boneVertices.fixed = true;
			
			if (Reflect.hasField(rawData, SLOT_POSE))
			{
				var rawSlotPose:Array<Dynamic> = Reflect.field(rawData, SLOT_POSE);
				mesh.slotPose.a = rawSlotPose[0];
				mesh.slotPose.b = rawSlotPose[1];
				mesh.slotPose.c = rawSlotPose[2];
				mesh.slotPose.d = rawSlotPose[3];
				mesh.slotPose.tx = rawSlotPose[4] * _armature.scale;
				mesh.slotPose.ty = rawSlotPose[5] * _armature.scale;
			}
			
			if (Reflect.hasField(rawData, BONE_POSE))
			{
				var rawBonePose:Array<Dynamic> = Reflect.field(rawData, BONE_POSE);
				i = 0;
				l = rawBonePose.length;
				var boneMatrix:Matrix;
				while (i < l)
				{
					//inline var rawBoneIndex:UInt = rawBonePose[i];
					boneMatrix = inverseBindPose[rawBonePose[i]] = new Matrix();
					boneMatrix.a = rawBonePose[i + 1];
					boneMatrix.b = rawBonePose[i + 2];
					boneMatrix.c = rawBonePose[i + 3];
					boneMatrix.d = rawBonePose[i + 4];
					boneMatrix.tx = rawBonePose[i + 5] * _armature.scale;
					boneMatrix.ty = rawBonePose[i + 6] * _armature.scale;
					boneMatrix.invert();
					i += 7;
				}
			}
		}
		
		var iW:UInt = 0;
		
		i = 0;
		l = rawVertices.length;
		var iN:UInt, vertexIndex:UInt, x:Float, y:Float, rawWeights:Array<Dynamic>, numBones:UInt;
		var indices:Vector<UInt>, weights:Vector<Float>, boneVertices:Vector<Float>, iI:UInt;
		var rawBoneIndex:UInt, boneData:BoneData, boneIndex:Int;
		while (i < l)
		{
			iN = i + 1;
			vertexIndex = i / 2;
			
			x = mesh.vertices[i] = rawVertices[i] * _armature.scale;
			y = mesh.vertices[iN] = rawVertices[iN] * _armature.scale;
			mesh.uvs[i] = rawUVs[i];
			mesh.uvs[iN] = rawUVs[iN];
			
			if (mesh.skinned)
			{
				rawWeights = Reflect.field(rawData, WEIGHTS);
				numBones = rawWeights[iW];
				indices = mesh.boneIndices[vertexIndex] = new Vector<UInt>(numBones, true);
				weights = mesh.weights[vertexIndex] = new Vector<Float>(numBones, true);
				boneVertices = mesh.boneVertices[vertexIndex] = new Vector<Float>(numBones * 2, true);
				
				Transform.transformPoint(mesh.slotPose, x, y, _helpPoint);
				x = mesh.vertices[i] = _helpPoint.x;
				y = mesh.vertices[iN] = _helpPoint.y;
				
				for (iB in 0...numBones)
				{
					iI = iW + 1 + iB * 2;
					rawBoneIndex = rawWeights[iI];
					boneData = _rawBones[rawBoneIndex];
					
					boneIndex = mesh.bones.indexOf(boneData);
					if (boneIndex < 0)
					{
						boneIndex = mesh.bones.length;
						mesh.bones[boneIndex] = boneData;
						mesh.inverseBindPose[boneIndex] = inverseBindPose[rawBoneIndex];
					}
					
					Transform.transformPoint(mesh.inverseBindPose[boneIndex], x, y, _helpPoint);
					
					indices[iB] = boneIndex;
					weights[iB] = rawWeights[iI + 1];
					boneVertices[iB * 2] = _helpPoint.x;
					boneVertices[iB * 2 + 1] = _helpPoint.y;
				}
				
				iW += numBones * 2 + 1;
				
				indices.fixed = true;
				weights.fixed = true;
				boneVertices.fixed = true;
			}
			i += 2;
		}
		
		mesh.bones.fixed = true;
		mesh.inverseBindPose.fixed = true;
		
		l = rawTriangles.length;
		for (i in 0...l)
		{
			mesh.vertexIndices[i] = rawTriangles[i];
		}
		
		return mesh;
	}
	
	/**
	 * @private
	 */
	private function _parseAnimation(rawData:Dynamic):AnimationData
	{
		var animation:AnimationData = cast BaseObject.borrowObject(AnimationData);
		animation.name = _getString(rawData, NAME, DEFAULT_NAME);
		if (animation.name == null) animation.name = DEFAULT_NAME;
		animation.frameCount = Math.max(_getNumber(rawData, DURATION, 1), 1);
		animation.duration = animation.frameCount / _armature.frameRate;
		animation.playTimes = _getNumber(rawData, PLAY_TIMES, 1);
		animation.fadeInTime = _getNumber(rawData, FADE_IN_TIME, 0);
		
		_animation = animation;
		
		_parseTimeline(rawData, animation, _parseAnimationFrame);
		
		if (Reflect.hasField(rawData, Z_ORDER)) 
		{
			animation.zOrderTimeline = cast BaseObject.borrowObject(ZOrderTimelineData);
			_parseTimeline(Reflect.field(rawData, Z_ORDER), animation.zOrderTimeline, _parseZOrderFrame);
		}
		
		if (Reflect.hasField(rawData, BONE))
		{
			for (rawBoneTimeline in cast(Reflect.field(rawData, BONE), Array<Dynamic>))
			{
				animation.addBoneTimeline(_parseBoneTimeline(rawBoneTimeline));
			}
		}
		
		if (Reflect.hasField(rawData, SLOT))
		{
			for (rawSlotTimeline in cast(Reflect.field(rawData, SLOT), Array<Dynamic>))
			{
				animation.addSlotTimeline(_parseSlotTimeline(rawSlotTimeline));
			}
			
		}
		
		if (Reflect.hasField(rawData, FFD))
		{
			for (rawFFDTimeline in cast(Reflect.field(rawData, FFD), Array<Dynamic>))
			{
				animation.addFFDTimeline(_parseFFDTimeline(rawFFDTimeline));
			}
		}
		
		if (_isOldData) // Support 2.x ~ 3.x data.
		{
			_isAutoTween = _getBoolean(rawData, AUTO_TWEEN, true);
			_animationTweenEasing = _getNumber(rawData, TWEEN_EASING, 0) || 0;
			animation.playTimes = _getNumber(rawData, LOOP, 1);
			
			if (Reflect.hasField(rawData, TIMELINE)) 
			{
				var rawTimelines:Array<Dynamic> = Reflect.field(rawData, TIMELINE);
				var l:UInt = rawTimelines.length;
				for (i in 0...l) {
					animation.addBoneTimeline(_parseBoneTimeline(rawTimelines[i]));
				}
				
				l = rawTimelines.length;
				for (i in 0...l) {
					animation.addSlotTimeline(_parseSlotTimeline(rawTimelines[i]));
				}
			}
		} 
		else 
		{
			_isAutoTween = false;
			_animationTweenEasing = 0;
		}
		
		for (bone in _armature.bones)
		{
			if (animation.getBoneTimeline(bone.name) == null)  // Add default bone timeline for cache if do not have one.
			{
				var boneTimeline:BoneTimelineData = cast BaseObject.borrowObject(BoneTimelineData);
				var boneFrame:BoneFrameData = cast BaseObject.borrowObject(BoneFrameData);
				boneTimeline.bone = bone;
				boneTimeline.frames.fixed = false;
				boneTimeline.frames[0] = boneFrame;
				boneTimeline.frames.fixed = true;
				animation.addBoneTimeline(boneTimeline);
			}
		}
		
		for (slot in _armature.slots)
		{
			if (animation.getSlotTimeline(slot.name) == null) // Add default slot timeline for cache if do not have one.
			{
				var slotTimeline:SlotTimelineData = cast BaseObject.borrowObject(SlotTimelineData);
				var slotFrame:SlotFrameData = cast BaseObject.borrowObject(SlotFrameData);
				slotTimeline.slot = slot;
				slotFrame.displayIndex = slot.displayIndex;
				//slotFrame.zOrder = -2;
				
				if (slot.color == SlotData.DEFAULT_COLOR)
				{
					slotFrame.color = SlotFrameData.DEFAULT_COLOR;
				}
				else
				{
					slotFrame.color = SlotFrameData.generateColor();
					slotFrame.color.alphaMultiplier = slot.color.alphaMultiplier;
					slotFrame.color.redMultiplier = slot.color.redMultiplier;
					slotFrame.color.greenMultiplier = slot.color.greenMultiplier;
					slotFrame.color.blueMultiplier = slot.color.blueMultiplier;
					slotFrame.color.alphaOffset = slot.color.alphaOffset;
					slotFrame.color.redOffset = slot.color.redOffset;
					slotFrame.color.greenOffset = slot.color.greenOffset;
					slotFrame.color.blueOffset = slot.color.blueOffset;
				}
				
				slotTimeline.frames.fixed = false;
				slotTimeline.frames[0] = slotFrame;
				slotTimeline.frames.fixed = true;
				animation.addSlotTimeline(slotTimeline);
				
				if (_isOldData) // Support 2.x ~ 3.x data.
				{
					slotFrame.displayIndex = -1;
				}
			}
		}
		
		_animation = null;
		
		return animation;
	}
	
	/**
	 * @private
	 */
	private function _parseBoneTimeline(rawData:Dynamic):BoneTimelineData
	{
		var timeline:BoneTimelineData = cast BaseObject.borrowObject(BoneTimelineData);
		timeline.bone = _armature.getBone(_getString(rawData, NAME, null));
		
		_parseTimeline(rawData, timeline, _parseBoneFrame);
		
		var originTransform:Transform = timeline.originalTransform;
		var prevFrame:BoneFrameData = null;
		
		for (frame in timeline.frames)
		{
			if (prevFrame == null)
			{
				originTransform.copyFrom(frame.transform);
				frame.transform.identity();
				
				if (originTransform.scaleX == 0) 
				{
					originTransform.scaleX = 0.001;
					//frame.transform.scaleX = 0;
				}
				
				if (originTransform.scaleY == 0) 
				{
					originTransform.scaleY = 0.001;
					//frame.transform.scaleY = 0;
				}
			}
			else if (prevFrame != frame)
			{
				frame.transform.minus(originTransform);
			}
			
			prevFrame = frame;
		}
		
		if (_isOldData && (Reflect.hasField(rawData, PIVOT_X) || Reflect.hasField(rawData, PIVOT_Y)))  // Support 2.x ~ 3.x data.
		{
			_timelinePivot.x = _getNumber(rawData, PIVOT_X, 0.0) * _armature.scale;
			_timelinePivot.y = _getNumber(rawData, PIVOT_Y, 0.0) * _armature.scale;
		} 
		else 
		{
			_timelinePivot.x = 0.0;
			_timelinePivot.y = 0.0;
		}
		
		return timeline;
	}
	
	/**
	 * @private
	 */
	private function _parseSlotTimeline(rawData:Dynamic):SlotTimelineData
	{
		var timeline:SlotTimelineData = cast BaseObject.borrowObject(SlotTimelineData);
		timeline.slot = _armature.getSlot(_getString(rawData, NAME, null));
		
		_parseTimeline(rawData, timeline, _parseSlotFrame);
		
		return timeline;
	}
	
	/**
	 * @private
	 */
	private function _parseFFDTimeline(rawData:Dynamic):FFDTimelineData
	{
		var timeline:FFDTimelineData = cast BaseObject.borrowObject(FFDTimelineData);
		timeline.skin = _armature.getSkin(_getString(rawData, SKIN, null));
		timeline.slot = timeline.skin.getSlot(_getString(rawData, SLOT, null)); // NAME;
		
		var meshName:String = _getString(rawData, NAME, null);
		var l:UInt = timeline.slot.displays.length;
		var display:DisplayData;
		for (i in 0...l)
		{
			display = timeline.slot.displays[i];
			if (display.mesh != null && display.name == meshName)
			{
				timeline.display = display;
				break;
			}
		}
		
		_parseTimeline(rawData, timeline, _parseFFDFrame);
		
		return timeline;
	}
	
	/**
	 * @private
	 */
	private function _parseAnimationFrame(rawData:Dynamic, frameStart:UInt, frameCount:UInt):AnimationFrameData
	{
		var frame:AnimationFrameData = cast BaseObject.borrowObject(AnimationFrameData);
		
		_parseFrame(rawData, frame, frameStart, frameCount);
		
		if (Reflect.hasField(rawData, ACTION) || Reflect.hasField(rawData, ACTIONS)) 
		{
			_parseActionData(rawData, frame.actions, null, null);
		}
		
		if (Reflect.hasField(rawData, EVENTS) || Reflect.hasField(rawData, EVENT) || Reflect.hasField(rawData, SOUND))
		{
			_parseEventData(rawData, frame.events, null, null);
		}
		
		return frame;
	}
	
	/**
	 * @private
	 */
	private function _parseZOrderFrame(rawData:Dynamic, frameStart:UInt, frameCount:UInt):ZOrderFrameData 
	{
		var frame:ZOrderFrameData = cast BaseObject.borrowObject(ZOrderFrameData);
		
		_parseFrame(rawData, frame, frameStart, frameCount);
		
		var zOrder:Array<Dynamic> = cast(Reflect.field(rawData, Z_ORDER), Array<Dynamic>);
		if (zOrder != null && zOrder.length > 0) {
			var slotCount:UInt = _armature.sortedSlots.length;
			var unchanged:Vector<Int> = new Vector<Int>(slotCount - zOrder.length / 2);
			
			frame.zOrder.length = slotCount;
			var l:UInt = slotCount;
			for (i in 0...l) {
				frame.zOrder[i] = -1;
			}
			
			var originalIndex:Int = 0;
			var unchangedIndex:Int = 0;
			var i = 0;
			l = zOrder.length;
			var slotIndex:Int, offset:Int;
			while (i < l)
			{
				slotIndex = zOrder[i];
				offset = zOrder[i + 1];
				
				while (originalIndex != slotIndex) 
				{
					unchanged[unchangedIndex++] = originalIndex++;
				}
				
				frame.zOrder[originalIndex + offset] = originalIndex++;
				i += 2
			}
			
			while (originalIndex < slotCount) 
			{
				unchanged[unchangedIndex++] = originalIndex++;
			}
			
			i = slotCount;
			while (i--) 
			{
				if (frame.zOrder[i] == -1) 
				{
					frame.zOrder[i] = unchanged[--unchangedIndex];
				}
			}
		}
		
		return frame;
	}
	
	/**
	 * @private
	 */
	private function _parseBoneFrame(rawData:Dynamic, frameStart:UInt, frameCount:UInt):BoneFrameData
	{
		var frame:BoneFrameData = cast BaseObject.borrowObject(BoneFrameData);
		frame.tweenRotate = _getNumber(rawData, TWEEN_ROTATE, 0.0);
		frame.tweenScale = _getBoolean(rawData, TWEEN_SCALE, true);
		
		_parseTweenFrame(rawData, frame, frameStart, frameCount);
		
		if (Reflect.hasField(rawData, TRANSFORM))
		{
			var transformObject:Dynamic = Reflect.field(rawData, TRANSFORM);
			_parseTransform(Reflect.field(rawData, TRANSFORM), frame.transform);
			
			if (_isOldData) // Support 2.x ~ 3.x data.
			{
				_helpPoint.x = _timelinePivot.x + _getNumber(transformObject, PIVOT_X, 0.0) * _armature.scale;
				_helpPoint.y = _timelinePivot.y + _getNumber(transformObject, PIVOT_Y, 0.0) * _armature.scale;
				frame.transform.toMatrix(_helpMatrix);
				Transform.transformPoint(_helpMatrix, _helpPoint.x, _helpPoint.y, _helpPoint, true);
				frame.transform.x += _helpPoint.x;
				frame.transform.y += _helpPoint.y;
			}
		}
		
		var bone:BoneData = cast(_timeline, BoneTimelineData).bone;
		var actions:Vector<ActionData> = new Vector<ActionData>();
		var events:Vector<EventData> = new Vector<EventData>();
		
		if (Reflect.hasField(rawData, ACTION) || Reflect.hasField(rawData, ACTIONS))
		{
			var slot:SlotData = _armature.getSlot(bone.name);
			_parseActionData(rawData, actions, bone, slot);
		}
		
		if (Reflect.hasField(rawData, EVENT) || Reflect.hasField(rawData, SOUND))
		{
			_parseEventData(rawData, events, bone, null);
		}
		
		if (actions.length > 0 || events.length > 0) 
		{
			_mergeFrameToAnimationTimeline(frame.position, actions, events); // Merge actions and events to animation timeline.
		}
		
		return frame;
	}
	
	/**
	 * @private
	 */
	private function _parseSlotFrame(rawData:Dynamic, frameStart:UInt, frameCount:UInt):SlotFrameData
	{
		var frame:SlotFrameData = cast BaseObject.borrowObject(SlotFrameData);
		frame.displayIndex = _getNumber(rawData, DISPLAY_INDEX, 0);
		
		_parseTweenFrame(rawData, frame, frameStart, frameCount);
		
		if (Reflect.hasField(rawData, COLOR) || Reflect.hasField(rawData, COLOR_TRANSFORM)) // Support 2.x ~ 3.x data. (colorTransform key)
		{
			frame.color = SlotFrameData.generateColor();
			_parseColorTransform(Reflect.field(rawData, COLOR) || Reflect.field(rawData, COLOR_TRANSFORM), frame.color);
		}
		else
		{
			frame.color = SlotFrameData.DEFAULT_COLOR;
		}
		
		if (_isOldData) // Support 2.x ~ 3.x data.
		{
			if (_getBoolean(rawData, HIDE, false)) 
			{
				frame.displayIndex = -1;
			}
		} 
		else if (Reflect.hasField(rawData, ACTION) || Reflect.hasField(rawData, ACTIONS))
		{
			var slot:SlotData = cast(_timeline, SlotTimelineData).slot;
			var actions:Vector<ActionData> = new Vector<ActionData>();
			_parseActionData(rawData, actions, slot.parent, slot);
			
			_mergeFrameToAnimationTimeline(frame.position, actions, null); // Merge actions and events to animation timeline.
		}
		
		return frame;
	}
	/**
	 * @private
	 */
	private function _parseFFDFrame(rawData:Dynamic, frameStart:UInt, frameCount:UInt):ExtensionFrameData
	{
		var ffdTimeline:FFDTimelineData = cast(_timeline, FFDTimelineData);
		var mesh:MeshData = ffdTimeline.display.mesh;
		var frame:ExtensionFrameData = cast BaseObject.borrowObject(ExtensionFrameData);
		
		_parseTweenFrame(rawData, frame, frameStart, frameCount);
		
		var rawVertices:Array<Dynamic> = Reflect.field(rawData, VERTICES);
		var offset:UInt = _getNumber(rawData, OFFSET, 0);
		var x:Float = 0.0;
		var y:Float = 0.0;
		var i:UInt = 0;
		var l:UInt = mesh.vertices.length;
		var boneIndices:Vector<UInt>, lB:UInt, boneIndex:UInt;
		while (i < l)
		{
			if (!rawVertices || i < offset || i - offset >= rawVertices.length)
			{
				x = 0.0;
				y = 0.0;
			}
			else
			{
				x = rawVertices[i - offset] * _armature.scale;
				y = rawVertices[i + 1 - offset] * _armature.scale;
			}
			
			if (mesh.skinned)
			{
				Transform.transformPoint(mesh.slotPose, x, y, _helpPoint, true);
				x = _helpPoint.x;
				y = _helpPoint.y;
				
				boneIndices> = mesh.boneIndices[i / 2];
				lB = boneIndices.length;
				for (iB in 0...lB)
				{
					boneIndex = boneIndices[iB];
					Transform.transformPoint(mesh.inverseBindPose[boneIndex], x, y, _helpPoint, true);
					frame.tweens.push(_helpPoint.x, _helpPoint.y);
				}
			}
			else
			{
				frame.tweens.push(x, y);
			}
			i += 2;
		}
		
		frame.tweens.fixed = true;
		
		return frame;
	}
	/**
	 * @private
	 */
	private function _parseTweenFrame(rawData:Dynamic, frame:TweenFrameData, frameStart:UInt, frameCount:UInt):Void
	{
		_parseFrame(rawData, frame, frameStart, frameCount);
		
		if (frame.duration > 0)
		{
			if (Reflect.hasField(rawData, TWEEN_EASING))
			{
				frame.tweenEasing = _getNumber(rawData, TWEEN_EASING, DragonBones.NO_TWEEN);
			}
			else if (_isOldData) // Support 2.x ~ 3.x data.
			{
				frame.tweenEasing = _isAutoTween ? _animationTweenEasing : DragonBones.NO_TWEEN;
			}
			else
			{
				frame.tweenEasing = DragonBones.NO_TWEEN;
			}
			
			if (_isOldData && _animation.scale == 1 && _timeline.scale == 1 && frame.duration * _armature.frameRate < 2) // Support 2.x ~ 3.x data.
			{
				frame.tweenEasing = DragonBones.NO_TWEEN;
			}
			
			if (Reflect.hasField(rawData, CURVE))
			{
				frame.curve = new Vector<Float>(frameCount * 2 - 1, true);
				TweenFrameData.samplingEasingCurve(Reflect.field(rawData, CURVE), frame.curve);
			}
		}
		else
		{
			frame.tweenEasing = DragonBones.NO_TWEEN;
			frame.curve = null;
		}
	}
	/**
	 * @private
	 */
	private function _parseFrame(rawData:Dynamic, frame:FrameData, frameStart:UInt, frameCount:UInt):Void
	{
		frame.position = frameStart / _armature.frameRate;
		frame.duration = frameCount / _armature.frameRate;
	}
	/**
	 * @private
	 */
	private function _parseTimeline(rawData:Dynamic, timeline:TimelineData, frameParser:Function):Void
	{
		timeline.scale = _getNumber(rawData, SCALE, 1);
		timeline.offset = _getNumber(rawData, OFFSET, 0);
		
		_timeline = timeline;
		
		if (Reflect.hasField(rawData, FRAME))
		{
			var rawFrames:Array<Dynamic> = Reflect.field(rawData, FRAME);
			if (rawFrames.length === 1)
			{
				timeline.frames.length = 1;
				timeline.frames[0] = frameParser(rawFrames[0], 0, _getNumber(rawFrames[0], DURATION, 1));
			}
			else if (rawFrames.length > 1)
			{
				timeline.frames.length = _animation.frameCount + 1;
				
				var frameStart:UInt = 0;
				var frameCount:UInt = 0;
				var frame:FrameData = null;
				var prevFrame:FrameData = null;
				
				var iW:UInt = 0;
				var l:UInt = timeline.frames.length;
				var rawFrame:Dynamic;
				for (i in 0...l)
				{
					if (frameStart + frameCount <= i && iW < rawFrames.length)
					{
						rawFrame = rawFrames[iW++];
						frameStart = i;
						frameCount = _getNumber(rawFrame, DURATION, 1);
						frame = frameParser(rawFrame, frameStart, frameCount);
						
						if (prevFrame != null)
						{
							prevFrame.next = frame;
							frame.prev = prevFrame;
							
							if (_isOldData) // Support 2.x ~ 3.x data.
							{
								if (Std.is(prevFrame, TweenFrameData) && rawFrame[DISPLAY_INDEX] == -1) 
								{
									cast(prevFrame, TweenFrameData).tweenEasing = DragonBones.NO_TWEEN;
								}
							}
						}
						
						prevFrame = frame;
					}
					
					timeline.frames[i] = frame;
				}
				
				frame.duration = _animation.duration - frame.position; // Modify last frame duration
				
				frame = timeline.frames[0];
				prevFrame.next = frame;
				frame.prev = prevFrame;
				
				if (_isOldData) // Support 2.x ~ 3.x data.
				{
					if (Std.is(prevFrame, TweenFrameData) && rawFrames[0][DISPLAY_INDEX] == -1) 
					{
						cast(prevFrame, TweenFrameData).tweenEasing = DragonBones.NO_TWEEN;
					}
				}
			}
			
			timeline.frames.fixed = true;
		}
		
		_timeline = null;
	}
	/**
	 * @private
	 */
	private function _parseActionData(rawData:Dynamic, actions:Vector<ActionData>, bone:BoneData, slot:SlotData):Void
	{
		var rawActions:Dynamic = Reflect.field(rawData, ACTION) || Reflect.field(rawData, ACTIONS) || Reflect.field(rawData, DEFAULT_ACTIONS);
		
		if (Std.is(rawActions, String))
		{
			var actionData:ActionData = cast BaseObject.borrowObject(ActionData);
			actionData.type = ActionType.Play;
			actionData.bone = bone;
			actionData.slot = slot;
			actionData.animationConfig = cast BaseObject.borrowObject(AnimationConfig);
			actionData.animationConfig.animationName = rawActions as String;
			actions.push(actionData);
		}
		else if (Std.is(rawActions, Array<Dynamic>)
		{
			var l:UInt = rawActions.length;
			var actionObject:Dynamic, isArray:Bool, animationName:String, actionType:Dynamic;
			for (i in 0...l)
			{
				actionObject = rawActions[i];
				isArray = Std.is(actionObject, Array);
				actionData = cast BaseObject.borrowObject(ActionData);
				animationName = isArray ? actionObject[1] : _getString(actionObject, "gotoAndPlay", null);
				
				if (isArray) 
				{
					actionType = actionObject[0];
					if (Std.is(actionType, String)) 
					{
						actionData.type = _getActionType(Std.string(actionType));
					} 
					else 
					{
						actionData.type = cast(actionType, Int);
					}
				} 
				else 
				{
					actionData.type = ActionType.Play;
				}
				
				switch (actionData.type)
				{
					case ActionType.Play:
						actionData.animationConfig = cast BaseObject.borrowObject(AnimationConfig);
						actionData.animationConfig.animationName = animationName;
					
					default:
				}
				
				actionData.bone = bone;
				actionData.slot = slot;
				actions.push(actionData);
			}
		}
	}
	/**
	 * @private
	 */
	private function _parseEventData(rawData:Dynamic, events:Vector<EventData>, bone:BoneData, slot:SlotData):Void
	{
		if (Reflect.hasField(rawData, SOUND))
		{
			var soundEventData:EventData = cast BaseObject.borrowObject(EventData);
			soundEventData.type = EventType.Sound;
			soundEventData.name = _getString(rawData, SOUND, null);
			soundEventData.bone = bone;
			soundEventData.slot = slot;
			events.push(soundEventData);
		}
		
		if (Reflect.hasField(rawData, EVENT))
		{
			var eventData:EventData = cast BaseObject.borrowObject(EventData);
			eventData.type = EventType.Frame;
			eventData.name = _getString(rawData, EVENT, null);
			eventData.bone = bone;
			eventData.slot = slot;
			
			events.push(eventData);
		}
		
		if (Reflect.hasField(rawData, EVENTS)) 
		{
			var boneName:String, slotName:String;
			for (rawEvent in cast(Reflect.field(rawData, EVENTS), Array<Dynamic>)) 
			{
				boneName = _getString(rawEvent, BONE, null);
				slotName = _getString(rawEvent, SLOT, null);
				eventData = cast BaseObject.borrowObject(EventData);
				
				eventData.type = EventType.Frame;
				eventData.name = _getString(rawEvent, NAME, null);
				eventData.bone = _armature.getBone(boneName);
				eventData.slot = _armature.getSlot(slotName);
				
				if (Reflect.hasField(rawEvent, INTS)) 
				{
					if (eventData.data == null) 
					{
						eventData.data = cast BaseObject.borrowObject(CustomData);
					}
					
					for (valueInt in cast(Reflect.field(rawEvent, INTS), Array<Dynamic>)) 
					{
						eventData.data.ints.push(valueInt);
					}
				}
				
				if (Reflect.hasField(rawEvent, FLOATS)) 
				{
					if (eventData.data == null) 
					{
						eventData.data = cast BaseObject.borrowObject(CustomData);
					}
					
					for (valueFloat in cast(Reflect.field(rawEvent, FLOATS), Array<Dynamic>)) 
					{
						eventData.data.floats.push(valueFloat);
					}
				}
				
				if (Reflect.hasField(rawEvent, STRINGS)) 
				{
					if (eventData.data == null) 
					{
						eventData.data = cast BaseObject.borrowObject(CustomData);
					}
					
					for (valueString in cast(Reflect.field(rawEvent, STRINGS), Array<Dynamic>)) 
					{
						eventData.data.strings.push(valueString);
					}
				}
				
				events.push(eventData);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function _parseTransform(rawData:Dynamic, transform:Transform):Void
	{
		transform.x = _getNumber(rawData, X, 0.0) * _armature.scale;
		transform.y = _getNumber(rawData, Y, 0.0) * _armature.scale;
		transform.skewX = _getNumber(rawData, SKEW_X, 0.0) * DragonBones.ANGLE_TO_RADIAN;
		transform.skewY = _getNumber(rawData, SKEW_Y, 0.0) * DragonBones.ANGLE_TO_RADIAN;
		transform.scaleX = _getNumber(rawData, SCALE_X, 1.0);
		transform.scaleY = _getNumber(rawData, SCALE_Y, 1.0);
	}
	
	/**
	 * @private
	 */
	private function _parseColorTransform(rawData:Dynamic, color:ColorTransform):Void
	{
		color.alphaMultiplier = _getNumber(rawData, ALPHA_MULTIPLIER, 100) * 0.01;
		color.redMultiplier = _getNumber(rawData, RED_MULTIPLIER, 100) * 0.01;
		color.greenMultiplier = _getNumber(rawData, GREEN_MULTIPLIER, 100) * 0.01;
		color.blueMultiplier = _getNumber(rawData, BLUE_MULTIPLIER, 100) * 0.01;
		color.alphaOffset = _getNumber(rawData, ALPHA_OFFSET, 0);
		color.redOffset = _getNumber(rawData, RED_OFFSET, 0);
		color.greenOffset = _getNumber(rawData, GREEN_OFFSET, 0);
		color.blueOffset = _getNumber(rawData, BLUE_OFFSET, 0);
	}
	/**
	 * @inheritDoc
	 */
	override public function parseDragonBonesData(rawData:Dynamic, scale:Float = 1):DragonBonesData
	{
		if (rawData)
		{
			var version:String = _getString(rawData, VERSION, null);
			var compatibleVersion:String = _getString(rawData, VERSION, null);
			_isOldData = version == DATA_VERSION_2_3 || version == DATA_VERSION_3_0;
			
			if (_isOldData) 
			{
				_isGlobalTransform = _getBoolean(rawData, IS_GLOBAL, true);
			} 
			else 
			{
				_isGlobalTransform = false;
			}
			
			if (
				version == DATA_VERSION || 
				version == DATA_VERSION_4_5 || 
				version == DATA_VERSION_4_0 || 
				version == DATA_VERSION_3_0 || 
				version == DATA_VERSION_2_3 ||
				compatibleVersion == DATA_VERSION_4_0
			)
			{
				var data:DragonBonesData = cast BaseObject.borrowObject(DragonBonesData);
				data.name = _getString(rawData, NAME, null);
				data.frameRate = _getNumber(rawData, FRAME_RATE, 24);
				if (data.frameRate === 0) 
				{
					data.frameRate = 24;
				}
				
				if (Reflect.hasField(rawData, ARMATURE))
				{
					_data = data;
					
					for (rawArmature in cast(Reflect.field(rawData, ARMATURE), Array<Dynamic>))
					{
						data.addArmature(_parseArmature(rawArmature, scale));
					}
					
					_data = null;
				}
				
				return data;
			}
			else
			{
				throw new Error("Nonsupport data version.");
			}
		}
		else
		{
			throw new ArgumentError();
		}
		
		return null;
	}
	/**
	 * @inheritDoc
	 */
	override public function parseTextureAtlasData(rawData:Dynamic, textureAtlasData:TextureAtlasData, scale:Float = 0, rawScale:Float = 0):Void
	{
		if (rawData != null)
		{
			textureAtlasData.name = _getString(rawData, NAME, null);
			textureAtlasData.imagePath = _getString(rawData, IMAGE_PATH, null);
			textureAtlasData.width = _getNumber(rawData, WIDTH, 0.0);
			textureAtlasData.height = _getNumber(rawData, HEIGHT, 0.0);
			
			// Texture format.
			
			if (scale > 0.0)
			{
				textureAtlasData.scale = scale;
			}
			else
			{
				scale = textureAtlasData.scale = _getNumber(rawData, SCALE, textureAtlasData.scale);
			}
			
			scale = 1.0 / (rawScale > 0.0 ? rawScale : scale);
			
			if (Reflect.hasField(rawData, SUB_TEXTURE))
			{
				var textureData:TextureData, frameWidth:Float, frameHeight:Float;
				for (rawTexture in cast(Reflect.field(rawData, SUB_TEXTURE), Array<Dynamic>))
				{
						textureData = textureAtlasData.generateTexture();
						textureData.name = _getString(rawTexture, NAME, null);
					textureData.rotated = _getBoolean(rawTexture, ROTATED, false);
					textureData.region.x = _getNumber(rawTexture, X, 0.0) * scale;
					textureData.region.y = _getNumber(rawTexture, Y, 0.0) * scale;
					textureData.region.width = _getNumber(rawTexture, WIDTH, 0.0) * scale;
					textureData.region.height = _getNumber(rawTexture, HEIGHT, 0.0) * scale;
					
					frameWidth = _getNumber(rawTexture, FRAME_WIDTH, -1.0);
					frameHeight = _getNumber(rawTexture, FRAME_HEIGHT, -1.0);
					if (frameWidth > 0.0 && frameHeight > 0.0)
					{
						textureData.frame = TextureData.generateRectangle();
						textureData.frame.x = _getNumber(rawTexture, FRAME_X, 0.0) * scale;
						textureData.frame.y = _getNumber(rawTexture, FRAME_Y, 0.0) * scale;
						textureData.frame.width = frameWidth * scale;
						textureData.frame.height = frameHeight * scale;
					}
					
						textureAtlasData.addTexture(textureData);
				}
			}
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @private
	 */
	private static var _instance:DynamicDataParser = null;
	/**
	 * @deprecated
	 * @see dragonBones.factories.BaseFactory#parseTextureAtlasData()
	 * @see dragonBones.factories.BaseFactory#parseDragonBonesData()
	 */
	public static function getInstance():DynamicDataParser
	{
		if (_instance == null)
		{
			_instance = new ObjectDataParser();
		}
		
		return _instance;
	}
}