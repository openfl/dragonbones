package dragonBones.parsers
{
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

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
public class ObjectDataParser extends DataParser
{
	/**
	 * @private
	 */
	[inline]
	private static function _getBoolean(rawData:Dynamic, key:String, defaultValue:Bool):Bool
	{
		if (key in rawData)
		{
			inline var value:* = rawData[key];
			if (value is Boolean || value is Number)
			{
				return value;
			}
			else if (value is String)
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
	[inline]
	private static function _getNumber(rawData:Dynamic, key:String, defaultValue:Float):Float
	{
		if (key in rawData)
		{
			inline var value:* = rawData[key];
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
	[inline]
	private static function _getString(rawData:Dynamic, key:String, defaultValue:String):String
	{
		if (key in rawData)
		{
			return rawData[key]; // String(rawData[key]);
		}
		
		return defaultValue;
	}
	/**
	 * @private
	 */
	public function ObjectDataParser()
	{
		super(this);
	}
	/**
	 * @private
	 */
	private function _parseArmature(rawData:Dynamic, scale:Float):ArmatureData
	{
		inline var armature:ArmatureData = BaseObject.borrowObject(ArmatureData) as ArmatureData;
		armature.name = _getString(rawData, NAME, null);
		armature.frameRate = _getNumber(rawData, FRAME_RATE, _data.frameRate) || _data.frameRate;
		armature.scale = scale;
		
		if (TYPE in rawData && rawData[TYPE] is String) 
		{
			armature.type = _getArmatureType(rawData[TYPE]);
		} 
		else 
		{
			armature.type = _getNumber(rawData, TYPE, ArmatureType.Armature);
		}
		
		_armature = armature;
		_rawBones.length = 0;
		
		if (BONE in rawData)
		{
			for each (var boneObject:Dynamic in rawData[BONE])
			{
				inline var bone:BoneData = _parseBone(boneObject);
				armature.addBone(bone, _getString(boneObject, PARENT, null));
				_rawBones.push(bone);
			}
		}
		
		if (IK in rawData)
		{
			for each (var ikObject:Dynamic in rawData[IK])
			{
				_parseIK(ikObject);
			}
		}
		
		if (SLOT in rawData)
		{
			var zOrder:Int = 0;
			for each (var slotObject:Dynamic in rawData[SLOT])
			{
				armature.addSlot(_parseSlot(slotObject, zOrder++));
			}
		}
		
		if (SKIN in rawData)
		{
			for each (var skinObject:Dynamic in rawData[SKIN])
			{
				armature.addSkin(_parseSkin(skinObject));
			}
		}
		
		if (ANIMATION in rawData)
		{
			for each (var animationObject:Dynamic in rawData[ANIMATION])
			{
				armature.addAnimation(_parseAnimation(animationObject));
			}
		}
		
		if (ACTIONS in rawData || DEFAULT_ACTIONS in rawData)
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
		inline var bone:BoneData = BaseObject.borrowObject(BoneData) as BoneData;
		bone.name = _getString(rawData, NAME, null);
		bone.inheritTranslation = _getBoolean(rawData, INHERIT_TRANSLATION, true);
		bone.inheritRotation = _getBoolean(rawData, INHERIT_ROTATION, true);
		bone.inheritScale = _getBoolean(rawData, INHERIT_SCALE, true);
		bone.length = _getNumber(rawData, LENGTH, 0) * _armature.scale;
		
		if (TRANSFORM in rawData)
		{
			_parseTransform(rawData[TRANSFORM], bone.transform);
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
		inline var bone:BoneData = _armature.getBone(_getString(rawData, (BONE in rawData)? BONE: NAME, null));
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
		inline var slot:SlotData = BaseObject.borrowObject(SlotData) as SlotData;
		slot.name = _getString(rawData, NAME, null);
		slot.parent = _armature.getBone(_getString(rawData, PARENT, null));
		slot.displayIndex = _getNumber(rawData, DISPLAY_INDEX, 0);
		slot.zOrder = _getNumber(rawData, Z, zOrder); // Support 2.x ~ 3.x data.
		
		if (COLOR in rawData)
		{
			slot.color = SlotData.generateColor();
			_parseColorTransform(rawData[COLOR], slot.color);
		}
		else
		{
			slot.color = SlotData.DEFAULT_COLOR;
		}
		
		if (BLEND_MODE in rawData && rawData[BLEND_MODE] is String)
		{
			
			slot.blendMode = _getBlendMode(rawData[BLEND_MODE]);
		}
		else
		{
			slot.blendMode = _getNumber(rawData, BLEND_MODE, BlendMode.Normal);
		}
		
		if (ACTIONS in rawData || DEFAULT_ACTIONS in rawData)
		{
			_parseActionData(rawData, slot.actions, null, null);
		}
		
		if (_isOldData) // Support 2.x ~ 3.x data.
		{
			if (COLOR_TRANSFORM in rawData) 
			{
				slot.color = SlotData.generateColor();
				_parseColorTransform(rawData[COLOR_TRANSFORM], slot.color);
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
		inline var skin:SkinData = BaseObject.borrowObject(SkinData) as SkinData;
		skin.name = _getString(rawData, NAME, DEFAULT_NAME) || DEFAULT_NAME;
		
		if (SLOT in rawData)
		{
			_skin = skin;
			var zOrder:Int = 0;
			for each (var slotObject:Dynamic in rawData[SLOT])
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
		inline var slotDisplayDataSet:SkinSlotData = BaseObject.borrowObject(SkinSlotData) as SkinSlotData;
		slotDisplayDataSet.slot = _armature.getSlot(_getString(rawData, NAME, null));
		
		if (DISPLAY in rawData)
		{
			inline var displayObjectSet:Array = rawData[DISPLAY];
			inline var displayDataSet:Vector<DisplayData> = slotDisplayDataSet.displays;
			
			_skinSlotData = slotDisplayDataSet;
			
			for each (var displayObject:Dynamic in displayObjectSet)
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
		inline var display:DisplayData = BaseObject.borrowObject(DisplayData) as DisplayData;
		display.name = _getString(rawData, NAME, null);
		display.path = _getString(rawData, PATH, display.name);
		
		if (TYPE in rawData && rawData[TYPE] is String)
		{
			
			display.type = _getDisplayType(rawData[TYPE]);
		}
		else
		{
			display.type = _getNumber(rawData, TYPE, DisplayType.Image);
		}
		
		display.isRelativePivot = true;
		
		if (PIVOT in rawData)
		{
			inline var rawPivot:Dynamic = rawData[PIVOT];
			display.pivot.x = _getNumber(rawPivot, X, 0);
			display.pivot.y = _getNumber(rawPivot, Y, 0);
		}
		else if (_isOldData) // Support 2.x ~ 3.x data.
		{
			inline var rawTransform:Dynamic = rawData[TRANSFORM];
			display.isRelativePivot = false;
			display.pivot.x = _getNumber(rawTransform, PIVOT_X, 0) * _armature.scale;
			display.pivot.y = _getNumber(rawTransform, PIVOT_Y, 0) * _armature.scale;
		}
		else
		{
			display.pivot.x = 0.5;
			display.pivot.y = 0.5;
		}
		
		if (TRANSFORM in rawData)
		{
			_parseTransform(rawData[TRANSFORM], display.transform);
		}
		
		switch (display.type)
		{
			case DisplayType.Image:
				break;
			
			case DisplayType.Armature:
				break;
			
			case DisplayType.Mesh:
				display.share = _getString(rawData, SHARE, null);
				if (!display.share) 
				{
					display.mesh = _parseMesh(rawData);
					_skinSlotData.addMesh(display.mesh);
				}
				break;
			
			case DisplayType.BoundingBox:
				display.boundingBox = _parseBoundingBox(rawData);
				break;
		}
		
		return display;
	}
	/**
	 * @private
	 */
	private function _parseBoundingBox(rawData:Dynamic): BoundingBoxData 
	{
		inline var boundingBox:BoundingBoxData = BaseObject.borrowObject(BoundingBoxData) as BoundingBoxData;
		
		if (SUB_TYPE in rawData && rawData[SUB_TYPE] is String) {
			boundingBox.type = _getBoundingBoxType(rawData[SUB_TYPE]);
		}
		else 
		{
			boundingBox.type = _getNumber(rawData, SUB_TYPE, BoundingBoxType.Rectangle);
		}
		
		boundingBox.color = _getNumber(rawData, COLOR, 0x000000);
		
		switch (boundingBox.type) 
		{
			case BoundingBoxType.Rectangle:
			case BoundingBoxType.Ellipse:
				boundingBox.width = _getNumber(rawData, WIDTH, 0.0);
				boundingBox.height = _getNumber(rawData, HEIGHT, 0.0);
				break;
			
			case BoundingBoxType.Polygon:
				if (VERTICES in rawData) 
				{
					inline var rawVertices:Array = rawData[VERTICES];
					boundingBox.vertices.length = rawVertices.length;
					boundingBox.vertices.fixed = true;
					
					for (var i:UInt = 0, l:UInt = boundingBox.vertices.length; i < l; i += 2) 
					{
						inline var iN:UInt = i + 1;
						inline var x:Float = rawVertices[i];
						inline var y:Float = rawVertices[iN];
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
					}
				}
				break;
			
			default:
				break;
		}
		
		return boundingBox;
	}
	/**
	 * @private
	 */
	private function _parseMesh(rawData:Dynamic):MeshData
	{
		inline var mesh:MeshData = BaseObject.borrowObject(MeshData) as MeshData;
		
		inline var rawVertices:Array = rawData[VERTICES];
		inline var rawUVs:Array = rawData[UVS];
		inline var rawTriangles:Array = rawData[TRIANGLES];
		
		inline var numVertices:UInt = uint(rawVertices.length / 2);
		inline var numTriangles:UInt = uint(rawTriangles.length / 3);
		
		inline var inverseBindPose:Vector<Matrix> = new Vector<Matrix>(_armature.sortedBones.length, true);
		
		mesh.skinned = WEIGHTS in rawData && (rawData[WEIGHTS] as Array).length > 0;
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
			
			if (SLOT_POSE in rawData)
			{
				inline var rawSlotPose:Array = rawData[SLOT_POSE];
				mesh.slotPose.a = rawSlotPose[0];
				mesh.slotPose.b = rawSlotPose[1];
				mesh.slotPose.c = rawSlotPose[2];
				mesh.slotPose.d = rawSlotPose[3];
				mesh.slotPose.tx = rawSlotPose[4] * _armature.scale;
				mesh.slotPose.ty = rawSlotPose[5] * _armature.scale;
			}
			
			if (BONE_POSE in rawData)
			{
				inline var rawBonePose:Array = rawData[BONE_POSE];
				for (i = 0, l = rawBonePose.length; i < l; i += 7)
				{
					//inline var rawBoneIndex:UInt = rawBonePose[i];
					inline var boneMatrix:Matrix = inverseBindPose[rawBonePose[i]] = new Matrix();
					boneMatrix.a = rawBonePose[i + 1];
					boneMatrix.b = rawBonePose[i + 2];
					boneMatrix.c = rawBonePose[i + 3];
					boneMatrix.d = rawBonePose[i + 4];
					boneMatrix.tx = rawBonePose[i + 5] * _armature.scale;
					boneMatrix.ty = rawBonePose[i + 6] * _armature.scale;
					boneMatrix.invert();
				}
			}
		}
		
		var iW:UInt = 0;
		
		for (i = 0, l = rawVertices.length; i < l; i += 2)
		{
			inline var iN:UInt = i + 1;
			inline var vertexIndex:UInt = i / 2;
			
			var x:Float = mesh.vertices[i] = rawVertices[i] * _armature.scale;
			var y:Float = mesh.vertices[iN] = rawVertices[iN] * _armature.scale;
			mesh.uvs[i] = rawUVs[i];
			mesh.uvs[iN] = rawUVs[iN];
			
			if (mesh.skinned)
			{
				inline var rawWeights:Array = rawData[WEIGHTS];
				inline var numBones:UInt = rawWeights[iW];
				inline var indices:Vector<UInt> = mesh.boneIndices[vertexIndex] = new Vector<UInt>(numBones, true);
				inline var weights:Vector<Float> = mesh.weights[vertexIndex] = new Vector<Float>(numBones, true);
				inline var boneVertices:Vector<Float> = mesh.boneVertices[vertexIndex] = new Vector<Float>(numBones * 2, true);
				
				Transform.transformPoint(mesh.slotPose, x, y, _helpPoint);
				x = mesh.vertices[i] = _helpPoint.x;
				y = mesh.vertices[iN] = _helpPoint.y;
				
				for (var iB:UInt = 0; iB < numBones; ++iB)
				{
					inline var iI:UInt = iW + 1 + iB * 2;
					inline var rawBoneIndex:UInt = rawWeights[iI];
					inline var boneData:BoneData = _rawBones[rawBoneIndex];
					
					var boneIndex:Int = mesh.bones.indexOf(boneData);
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
		}
		
		mesh.bones.fixed = true;
		mesh.inverseBindPose.fixed = true;
		
		for (i = 0, l = rawTriangles.length; i < l; ++i)
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
		inline var animation:AnimationData = BaseObject.borrowObject(AnimationData) as AnimationData;
		animation.name = _getString(rawData, NAME, DEFAULT_NAME) || DEFAULT_NAME;
		animation.frameCount = Math.max(_getNumber(rawData, DURATION, 1), 1);
		animation.duration = animation.frameCount / _armature.frameRate;
		animation.playTimes = _getNumber(rawData, PLAY_TIMES, 1);
		animation.fadeInTime = _getNumber(rawData, FADE_IN_TIME, 0);
		
		_animation = animation;
		
		_parseTimeline(rawData, animation, _parseAnimationFrame);
		
		if (Z_ORDER in rawData) 
		{
			animation.zOrderTimeline = BaseObject.borrowObject(ZOrderTimelineData) as ZOrderTimelineData;
			_parseTimeline(rawData[Z_ORDER], animation.zOrderTimeline, _parseZOrderFrame);
		}
		
		if (BONE in rawData)
		{
			for each (var rawBoneTimeline:Dynamic in rawData[BONE])
			{
				animation.addBoneTimeline(_parseBoneTimeline(rawBoneTimeline));
			}
		}
		
		if (SLOT in rawData)
		{
			for each (var rawSlotTimeline:Dynamic in rawData[SLOT])
			{
				animation.addSlotTimeline(_parseSlotTimeline(rawSlotTimeline));
			}
			
		}
		
		if (FFD in rawData)
		{
			for each (var rawFFDTimeline:Dynamic in rawData[FFD])
			{
				animation.addFFDTimeline(_parseFFDTimeline(rawFFDTimeline));
			}
		}
		
		if (_isOldData) // Support 2.x ~ 3.x data.
		{
			_isAutoTween = _getBoolean(rawData, AUTO_TWEEN, true);
			_animationTweenEasing = _getNumber(rawData, TWEEN_EASING, 0) || 0;
			animation.playTimes = _getNumber(rawData, LOOP, 1);
			
			if (TIMELINE in rawData) 
			{
				inline var rawTimelines:Array = rawData[TIMELINE];
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
		
		for each (var bone:BoneData in _armature.bones)
		{
			if (!animation.getBoneTimeline(bone.name))  // Add default bone timeline for cache if do not have one.
			{
				inline var boneTimeline:BoneTimelineData = BaseObject.borrowObject(BoneTimelineData) as BoneTimelineData;
				inline var boneFrame:BoneFrameData = BaseObject.borrowObject(BoneFrameData) as BoneFrameData;
				boneTimeline.bone = bone;
				boneTimeline.frames.fixed = false;
				boneTimeline.frames[0] = boneFrame;
				boneTimeline.frames.fixed = true;
				animation.addBoneTimeline(boneTimeline);
			}
		}
		
		for each (var slot:SlotData in _armature.slots)
		{
			if (!animation.getSlotTimeline(slot.name)) // Add default slot timeline for cache if do not have one.
			{
				inline var slotTimeline:SlotTimelineData = BaseObject.borrowObject(SlotTimelineData) as SlotTimelineData;
				inline var slotFrame:SlotFrameData = BaseObject.borrowObject(SlotFrameData) as SlotFrameData;
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
		inline var timeline:BoneTimelineData = BaseObject.borrowObject(BoneTimelineData) as BoneTimelineData;
		timeline.bone = _armature.getBone(_getString(rawData, NAME, null));
		
		_parseTimeline(rawData, timeline, _parseBoneFrame);
		
		inline var originTransform:Transform = timeline.originalTransform;
		var prevFrame:BoneFrameData = null;
		
		for each (var frame:BoneFrameData in timeline.frames)
		{
			if (!prevFrame)
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
		
		if (_isOldData && (PIVOT_X in rawData || PIVOT_Y in rawData))  // Support 2.x ~ 3.x data.
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
		inline var timeline:SlotTimelineData = BaseObject.borrowObject(SlotTimelineData) as SlotTimelineData;
		timeline.slot = _armature.getSlot(_getString(rawData, NAME, null));
		
		_parseTimeline(rawData, timeline, _parseSlotFrame);
		
		return timeline;
	}
	
	/**
	 * @private
	 */
	private function _parseFFDTimeline(rawData:Dynamic):FFDTimelineData
	{
		inline var timeline:FFDTimelineData = BaseObject.borrowObject(FFDTimelineData) as FFDTimelineData;
		timeline.skin = _armature.getSkin(_getString(rawData, SKIN, null));
		timeline.slot = timeline.skin.getSlot(_getString(rawData, SLOT, null)); // NAME;
		
		inline var meshName:String = _getString(rawData, NAME, null);
		var l:UInt = timeline.slot.displays.length;
		for (i in 0...l)
		{
			inline var display:DisplayData = timeline.slot.displays[i];
			if (display.mesh && display.name == meshName)
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
		inline var frame:AnimationFrameData = BaseObject.borrowObject(AnimationFrameData) as AnimationFrameData;
		
		_parseFrame(rawData, frame, frameStart, frameCount);
		
		if (ACTION in rawData || ACTIONS in rawData) 
		{
			_parseActionData(rawData, frame.actions, null, null);
		}
		
		if (EVENTS in rawData || EVENT in rawData || SOUND in rawData)
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
		inline var frame:ZOrderFrameData = BaseObject.borrowObject(ZOrderFrameData) as ZOrderFrameData;
		
		_parseFrame(rawData, frame, frameStart, frameCount);
		
		inline var zOrder:Array = rawData[Z_ORDER] as Array;
		if (zOrder && zOrder.length > 0) {
			inline var slotCount:UInt = _armature.sortedSlots.length;
			inline var unchanged:Vector<Int> = new Vector<Int>(slotCount - zOrder.length / 2);
			
			frame.zOrder.length = slotCount;
			var l:UInt = slotCount;
			for (i in 0...l) {
				frame.zOrder[i] = -1;
			}
			
			var originalIndex:Int = 0;
			var unchangedIndex:Int = 0;
			for (i = 0, l = zOrder.length; i < l; i += 2) 
			{
				inline var slotIndex:Int = zOrder[i];
				inline var offset:Int = zOrder[i + 1];
				
				while (originalIndex != slotIndex) 
				{
					unchanged[unchangedIndex++] = originalIndex++;
				}
				
				frame.zOrder[originalIndex + offset] = originalIndex++;
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
		inline var frame:BoneFrameData = BaseObject.borrowObject(BoneFrameData) as BoneFrameData;
		frame.tweenRotate = _getNumber(rawData, TWEEN_ROTATE, 0.0);
		frame.tweenScale = _getBoolean(rawData, TWEEN_SCALE, true);
		
		_parseTweenFrame(rawData, frame, frameStart, frameCount);
		
		if (TRANSFORM in rawData)
		{
			inline var transformObject:Dynamic = rawData[TRANSFORM];
			_parseTransform(rawData[TRANSFORM], frame.transform);
			
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
		
		inline var bone:BoneData = (_timeline as BoneTimelineData).bone;
		inline var actions:Vector<ActionData> = new Vector<ActionData>();
		inline var events:Vector<EventData> = new Vector<EventData>();
		
		if (ACTION in rawData || ACTIONS in rawData)
		{
			inline var slot:SlotData = _armature.getSlot(bone.name);
			_parseActionData(rawData, actions, bone, slot);
		}
		
		if (EVENT in rawData || SOUND in rawData)
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
		inline var frame:SlotFrameData = BaseObject.borrowObject(SlotFrameData) as SlotFrameData;
		frame.displayIndex = _getNumber(rawData, DISPLAY_INDEX, 0);
		
		_parseTweenFrame(rawData, frame, frameStart, frameCount);
		
		if (COLOR in rawData || COLOR_TRANSFORM in rawData) // Support 2.x ~ 3.x data. (colorTransform key)
		{
			frame.color = SlotFrameData.generateColor();
			_parseColorTransform(rawData[COLOR] || rawData[COLOR_TRANSFORM], frame.color);
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
		else if (ACTION in rawData || ACTIONS in rawData)
		{
			inline var slot:SlotData = (_timeline as SlotTimelineData).slot;
			inline var actions:Vector<ActionData> = new Vector<ActionData>();
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
		inline var ffdTimeline:FFDTimelineData = _timeline as FFDTimelineData;
		inline var mesh:MeshData = ffdTimeline.display.mesh;
		inline var frame:ExtensionFrameData = BaseObject.borrowObject(ExtensionFrameData) as ExtensionFrameData;
		
		_parseTweenFrame(rawData, frame, frameStart, frameCount);
		
		inline var rawVertices:Array = rawData[VERTICES];
		inline var offset:UInt = _getNumber(rawData, OFFSET, 0);
		var x:Float = 0.0;
		var y:Float = 0.0;
		for (var i:UInt = 0, l:UInt = mesh.vertices.length ; i < l; i += 2)
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
				
				inline var boneIndices:Vector<UInt> = mesh.boneIndices[i / 2];
				for (var iB:UInt = 0, lB:UInt = boneIndices.length; iB < lB; ++iB)
				{
					inline var boneIndex:UInt = boneIndices[iB];
					Transform.transformPoint(mesh.inverseBindPose[boneIndex], x, y, _helpPoint, true);
					frame.tweens.push(_helpPoint.x, _helpPoint.y);
				}
			}
			else
			{
				frame.tweens.push(x, y);
			}
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
			if (TWEEN_EASING in rawData)
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
			
			if (CURVE in rawData)
			{
				frame.curve = new Vector<Float>(frameCount * 2 - 1, true);
				TweenFrameData.samplingEasingCurve(rawData[CURVE], frame.curve);
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
		
		if (FRAME in rawData)
		{
			inline var rawFrames:Array = rawData[FRAME];
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
				
				for (var i:UInt = 0, iW:UInt = 0, l:UInt = timeline.frames.length; i < l; ++i)
				{
					if (frameStart + frameCount <= i && iW < rawFrames.length)
					{
						inline var rawFrame:Dynamic = rawFrames[iW++];
						frameStart = i;
						frameCount = _getNumber(rawFrame, DURATION, 1);
						frame = frameParser(rawFrame, frameStart, frameCount);
						
						if (prevFrame)
						{
							prevFrame.next = frame;
							frame.prev = prevFrame;
							
							if (_isOldData) // Support 2.x ~ 3.x data.
							{
								if (prevFrame is TweenFrameData && rawFrame[DISPLAY_INDEX] == -1) 
								{
									(prevFrame as TweenFrameData).tweenEasing = DragonBones.NO_TWEEN;
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
					if (prevFrame is TweenFrameData && rawFrames[0][DISPLAY_INDEX] == -1) 
					{
						(prevFrame as TweenFrameData).tweenEasing = DragonBones.NO_TWEEN;
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
		inline var rawActions:Dynamic = rawData[ACTION] || rawData[ACTIONS] || rawData[DEFAULT_ACTIONS];
		
		if (rawActions is String)
		{
			var actionData:ActionData = BaseObject.borrowObject(ActionData) as ActionData;
			actionData.type = ActionType.Play;
			actionData.bone = bone;
			actionData.slot = slot;
			actionData.animationConfig = BaseObject.borrowObject(AnimationConfig) as AnimationConfig;
			actionData.animationConfig.animationName = rawActions as String;
			actions.push(actionData);
		}
		else if (rawActions is Array)
		{
			var l:UInt = rawActions.length;
			for (i in 0...l)
			{
				inline var actionObject:Dynamic = rawActions[i];
				inline var isArray:Bool = actionObject is Array;
				actionData = BaseObject.borrowObject(ActionData) as ActionData;
				inline var animationName:String = isArray ? actionObject[1] : _getString(actionObject, "gotoAndPlay", null);
				
				if (isArray) 
				{
					inline var actionType:Dynamic = actionObject[0];
					if (actionType is String) 
					{
						actionData.type = _getActionType(actionType as String);
					} 
					else 
					{
						actionData.type = actionType as int;
					}
				} 
				else 
				{
					actionData.type = ActionType.Play;
				}
				
				switch (actionData.type)
				{
					case ActionType.Play:
						actionData.animationConfig = BaseObject.borrowObject(AnimationConfig) as AnimationConfig;
						actionData.animationConfig.animationName = animationName;
						break;
					
					default:
						break;
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
		if (SOUND in rawData)
		{
			inline var soundEventData:EventData = BaseObject.borrowObject(EventData) as EventData;
			soundEventData.type = EventType.Sound;
			soundEventData.name = _getString(rawData, SOUND, null);
			soundEventData.bone = bone;
			soundEventData.slot = slot;
			events.push(soundEventData);
		}
		
		if (EVENT in rawData)
		{
			var eventData:EventData = BaseObject.borrowObject(EventData) as EventData;
			eventData.type = EventType.Frame;
			eventData.name = _getString(rawData, EVENT, null);
			eventData.bone = bone;
			eventData.slot = slot;
			
			events.push(eventData);
		}
		
		if (EVENTS in rawData) 
		{
			for each (var rawEvent:Dynamic in rawData[EVENTS]) 
			{
				inline var boneName:String = _getString(rawEvent, BONE, null);
				inline var slotName:String = _getString(rawEvent, SLOT, null);
				eventData = BaseObject.borrowObject(EventData) as EventData;
				
				eventData.type = EventType.Frame;
				eventData.name = _getString(rawEvent, NAME, null);
				eventData.bone = _armature.getBone(boneName);
				eventData.slot = _armature.getSlot(slotName);
				
				if (INTS in rawEvent) 
				{
					if (!eventData.data) 
					{
						eventData.data = BaseObject.borrowObject(CustomData) as CustomData;
					}
					
					for each (var valueInt:Int in rawEvent[INTS] as Array) 
					{
						eventData.data.ints.push(valueInt);
					}
				}
				
				if (FLOATS in rawEvent) 
				{
					if (!eventData.data) 
					{
						eventData.data = BaseObject.borrowObject(CustomData) as CustomData;
					}
					
					for each (var valueFloat:Float in rawEvent[FLOATS] as Array) 
					{
						eventData.data.floats.push(valueFloat);
					}
				}
				
				if (STRINGS in rawEvent) 
				{
					if (!eventData.data) 
					{
						eventData.data = BaseObject.borrowObject(CustomData) as CustomData;
					}
					
					for each (var valueString:String in rawEvent[STRINGS] as Array) 
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
			inline var version:String = _getString(rawData, VERSION, null);
			inline var compatibleVersion:String = _getString(rawData, VERSION, null);
			_isOldData = version === DATA_VERSION_2_3 || version === DATA_VERSION_3_0;
			
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
				inline var data:DragonBonesData = BaseObject.borrowObject(DragonBonesData) as DragonBonesData;
				data.name = _getString(rawData, NAME, null);
				data.frameRate = _getNumber(rawData, FRAME_RATE, 24);
				if (data.frameRate === 0) 
				{
					data.frameRate = 24;
				}
				
				if (ARMATURE in rawData)
				{
					_data = data;
					
					for each (var rawArmature:Dynamic in rawData[ARMATURE])
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
		if (rawData)
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
			
			if (SUB_TEXTURE in rawData)
			{
				for each (var rawTexture:Dynamic in rawData[SUB_TEXTURE])
				{
						inline var textureData:TextureData = textureAtlasData.generateTexture();
						textureData.name = _getString(rawTexture, NAME, null);
					textureData.rotated = _getBoolean(rawTexture, ROTATED, false);
					textureData.region.x = _getNumber(rawTexture, X, 0.0) * scale;
					textureData.region.y = _getNumber(rawTexture, Y, 0.0) * scale;
					textureData.region.width = _getNumber(rawTexture, WIDTH, 0.0) * scale;
					textureData.region.height = _getNumber(rawTexture, HEIGHT, 0.0) * scale;
					
					inline var frameWidth:Float = _getNumber(rawTexture, FRAME_WIDTH, -1.0);
					inline var frameHeight:Float = _getNumber(rawTexture, FRAME_HEIGHT, -1.0);
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
		if (!_instance)
		{
			_instance = new ObjectDataParser();
		}
		
		return _instance;
	}
}
}