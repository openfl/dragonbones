package dragonBones.parsers
{
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.Vector;

import dragonBones.animation.TweenTimelineState;
import dragonBones.core.BaseObject;
import dragonBones.core.DragonBones;
import dragonBones.core.dragonBones_internal;
import dragonBones.enum.ActionType;
import dragonBones.enum.ArmatureType;
import dragonBones.enum.BlendMode;
import dragonBones.enum.BoundingBoxType;
import dragonBones.enum.DisplayType;
import dragonBones.geom.Transform;
import dragonBones.objects.ActionData;
import dragonBones.objects.AnimationData;
import dragonBones.objects.AnimationFrameData;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.BoneData;
import dragonBones.objects.BoneFrameData;
import dragonBones.objects.BoneTimelineData;
import dragonBones.objects.DragonBonesData;
import dragonBones.objects.EventData;
import dragonBones.objects.FrameData;
import dragonBones.objects.SkinData;
import dragonBones.objects.SkinSlotData;
import dragonBones.objects.TimelineData;
import dragonBones.textures.TextureAtlasData;


/**
 * @private
 */
class DataParser
{
	private static inline var DATA_VERSION_2_3:String = "2.3";
	private static inline var DATA_VERSION_3_0:String = "3.0";
	private static inline var DATA_VERSION_4_0:String = "4.0";
	private static inline var DATA_VERSION_4_5:String = "4.5";
	private static inline var DATA_VERSION_5_0:String = "5.0";
	private static inline var DATA_VERSION:String = DATA_VERSION_5_0;
	private static var DATA_VERSIONS:Vector<String> = Vector<String>([
		DATA_VERSION_5_0,
		DATA_VERSION_4_5,
		DATA_VERSION_4_0,
		DATA_VERSION_3_0,
		DATA_VERSION_2_3
	]);
	
	private static inline var TEXTURE_ATLAS:String = "TextureAtlas";
	private static inline var SUB_TEXTURE:String = "SubTexture";
	private static inline var FORMAT:String = "format";
	private static inline var IMAGE_PATH:String = "imagePath";
	private static inline var WIDTH:String = "width";
	private static inline var HEIGHT:String = "height";
	private static inline var ROTATED:String = "rotated";
	private static inline var FRAME_X:String = "frameX";
	private static inline var FRAME_Y:String = "frameY";
	private static inline var FRAME_WIDTH:String = "frameWidth";
	private static inline var FRAME_HEIGHT:String = "frameHeight";
	
	private static inline var DRADON_BONES:String = "dragonBones";
	private static inline var ARMATURE:String = "armature";
	private static inline var BONE:String = "bone";
	private static inline var IK:String = "ik";
	private static inline var SLOT:String = "slot";
	private static inline var SKIN:String = "skin";
	private static inline var DISPLAY:String = "display";
	private static inline var ANIMATION:String = "animation";
	private static inline var Z_ORDER:String = "zOrder";
	private static inline var FFD:String = "ffd";
	private static inline var FRAME:String = "frame";
	private static inline var ACTIONS:String = "actions";
	private static inline var EVENTS:String = "events";
	private static inline var INTS:String = "ints";
	private static inline var FLOATS:String = "floats";
	private static inline var STRINGS:String = "strings";
	
	private static inline var PIVOT:String = "pivot";
	private static inline var TRANSFORM:String = "transform";
	private static inline var AABB:String = "aabb";
	private static inline var COLOR:String = "color";
	
	private static inline var VERSION:String = "version";
	private static inline var COMPATIBLE_VERSION:String = "compatibleVersion";
	private static inline var FRAME_RATE:String = "frameRate";
	private static inline var TYPE:String = "type";
	private static inline var SUB_TYPE:String = "subType";
	private static inline var NAME:String = "name";
	private static inline var PARENT:String = "parent";
	private static inline var TARGET:String = "target";
	private static inline var SHARE:String = "share";
	private static inline var PATH:String = "path";
	private static inline var LENGTH:String = "length";
	private static inline var DISPLAY_INDEX:String = "displayIndex";
	private static inline var BLEND_MODE:String = "blendMode";
	private static inline var INHERIT_TRANSLATION:String = "inheritTranslation";
	private static inline var INHERIT_ROTATION:String = "inheritRotation";
	private static inline var INHERIT_SCALE:String = "inheritScale";
	private static inline var INHERIT_ANIMATION:String = "inheritAnimation";
	private static inline var BEND_POSITIVE:String = "bendPositive";
	private static inline var CHAIN:String = "chain";
	private static inline var WEIGHT:String = "weight";
	
	private static inline var FADE_IN_TIME:String = "fadeInTime";
	private static inline var PLAY_TIMES:String = "playTimes";
	private static inline var SCALE:String = "scale";
	private static inline var OFFSET:String = "offset";
	private static inline var POSITION:String = "position";
	private static inline var DURATION:String = "duration";
	private static inline var TWEEN_TYPE:String = "tweenType";
	private static inline var TWEEN_EASING:String = "tweenEasing";
	private static inline var TWEEN_ROTATE:String = "tweenRotate";
	private static inline var TWEEN_SCALE:String = "tweenScale";
	private static inline var CURVE:String = "curve";
	private static inline var EVENT:String = "event";
	private static inline var SOUND:String = "sound";
	private static inline var ACTION:String = "action";
	private static inline var DEFAULT_ACTIONS:String = "defaultActions";
	
	private static inline var X:String = "x";
	private static inline var Y:String = "y";
	private static inline var SKEW_X:String = "skX";
	private static inline var SKEW_Y:String = "skY";
	private static inline var SCALE_X:String = "scX";
	private static inline var SCALE_Y:String = "scY";
	
	private static inline var ALPHA_OFFSET:String = "aO";
	private static inline var RED_OFFSET:String = "rO";
	private static inline var GREEN_OFFSET:String = "gO";
	private static inline var BLUE_OFFSET:String = "bO";
	private static inline var ALPHA_MULTIPLIER:String = "aM";
	private static inline var RED_MULTIPLIER:String = "rM";
	private static inline var GREEN_MULTIPLIER:String = "gM";
	private static inline var BLUE_MULTIPLIER:String = "bM";
	
	private static inline var UVS:String = "uvs";
	private static inline var VERTICES:String = "vertices";
	private static inline var TRIANGLES:String = "triangles";
	private static inline var WEIGHTS:String = "weights";
	private static inline var SLOT_POSE:String = "slotPose";
	private static inline var BONE_POSE:String = "bonePose";
	
	private static inline var COLOR_TRANSFORM:String = "colorTransform";
	private static inline var TIMELINE:String = "timeline";
	private static inline var IS_GLOBAL:String = "isGlobal";
	private static inline var PIVOT_X:String = "pX";
	private static inline var PIVOT_Y:String = "pY";
	private static inline var Z:String = "z";
	private static inline var LOOP:String = "loop";
	private static inline var AUTO_TWEEN:String = "autoTween";
	private static inline var HIDE:String = "hide";
	
	private static inline var DEFAULT_NAME:String = "__default";
	
	private static function _getArmatureType(value:String):Int
	{
		switch (value.toLowerCase())
		{
			case "stage":
				return ArmatureType.Stage;
				
			case "armature":
				return ArmatureType.Armature;
				
			case "movieclip":
				return ArmatureType.MovieClip;
				
			default:
				return ArmatureType.None;
		}
	}
	
	private static function _getDisplayType(value:String):Int
	{
		switch (value.toLowerCase())
		{
			case "image":
				return DisplayType.Image;
				
			case "armature":
				return DisplayType.Armature;
				
			case "mesh":
				return DisplayType.Mesh;
				
			case "boundingbox":
				return DisplayType.BoundingBox;
				
			default:
				return DisplayType.None;
		}
	}
	
	private static function _getBoundingBoxType(value: String):Int
	{
		switch (value.toLowerCase()) 
		{
			case "rectangle":
				return BoundingBoxType.Rectangle;
				
			case "ellipse":
				return BoundingBoxType.Ellipse;
				
			case "polygon":
				return BoundingBoxType.Polygon;
				
			default:
				return BoundingBoxType.None;
		}
	}
	
	private static function _getBlendMode(value:String):Int 
	{
		switch (value.toLowerCase()) 
		{
			case "normal":
				return BlendMode.Normal;
				
			case "add":
				return BlendMode.Add;
				
			case "alpha":
				return BlendMode.Alpha;
				
			case "darken":
				return BlendMode.Darken;
				
			case "difference":
				return BlendMode.Difference;
				
			case "erase":
				return BlendMode.Erase;
				
			case "hardlight":
				return BlendMode.HardLight;
				
			case "invert":
				return BlendMode.Invert;
				
			case "layer":
				return BlendMode.Layer;
				
			case "lighten":
				return BlendMode.Lighten;
				
			case "multiply":
				return BlendMode.Multiply;
				
			case "overlay":
				return BlendMode.Overlay;
				
			case "screen":
				return BlendMode.Screen;
				
			case "subtract":
				return BlendMode.Subtract;
				
			default:
				return BlendMode.None;
		}
	}
	
	private static function _getActionType(value:String):Int
	{
		switch (value.toLowerCase())
		{
			case "play":
				return ActionType.Play;
				
			default:
				return ActionType.None;
		}
	}
	
	private var _isOldData:Bool = false;
	private var _isGlobalTransform:Bool = false;
	private var _isAutoTween:Bool = false;
	private var _animationTweenEasing:Float = 0.0;
	private var _timelinePivot:Point = new Point();
	
	private var _helpPoint:Point = new Point();
	private var _helpTransformA:Transform = new Transform();
	private var _helpTransformB:Transform = new Transform();
	private var _helpMatrix:Matrix = new Matrix();
	private var _rawBones:Vector<BoneData> = new Vector<BoneData>();
	
	private var _data:DragonBonesData = null;
	private var _armature:ArmatureData = null;
	private var _skin:SkinData = null;
	private var _skinSlotData:SkinSlotData = null;
	private var _animation:AnimationData = null;
	private var _timeline:TimelineData = null;
	
	private function new() {}
	
	/** 
	 * @private 
	 */
	public function parseDragonBonesData(rawData:Dynamic, scale:Float = 1):DragonBonesData
	{
		throw new Error(DragonBones.ABSTRACT_METHOD_ERROR);
		return null;
	}
	/** 
	 * @private 
	 */
	public function parseTextureAtlasData(rawData:Dynamic, textureAtlasData:TextureAtlasData, scale:Float = 0, rawScale:Float = 0):Void
	{
		throw new Error(DragonBones.ABSTRACT_METHOD_ERROR);
	}
	
	private function _getTimelineFrameMatrix(animation:AnimationData, timeline:BoneTimelineData, position:Float, transform:Transform):Void 
	{
		var frameIndex:UInt = Std.int(position * animation.frameCount / animation.duration);
		if (timeline.frames.length == 1 || frameIndex >= timeline.frames.length) 
		{
			transform.copyFrom((timeline.frames[0] as BoneFrameData).transform);
		} 
		else 
		{
			var frame:BoneFrameData = cast timeline.frames[frameIndex];
			var tweenProgress:Float = 0;
			
			if (frame.tweenEasing != DragonBones.NO_TWEEN) 
			{
				tweenProgress = (position - frame.position) / frame.duration;
				if (frame.tweenEasing != 0) 
				{
					tweenProgress = TweenTimelineState._getEasingValue(tweenProgress, frame.tweenEasing);
				}
			}
			else if (frame.curve != null) 
			{
				tweenProgress = (position - frame.position) / frame.duration;
				tweenProgress = TweenTimelineState._getCurveEasingValue(tweenProgress, frame.curve);
			}
			
			var nextFrame:BoneFrameData = cast frame.next;
			
			transform.x = nextFrame.transform.x - frame.transform.x;
			transform.y = nextFrame.transform.y - frame.transform.y;
			transform.skewX = Transform.normalizeRadian(nextFrame.transform.skewX - frame.transform.skewX);
			transform.skewY = Transform.normalizeRadian(nextFrame.transform.skewY - frame.transform.skewY);
			transform.scaleX = nextFrame.transform.scaleX - frame.transform.scaleX;
			transform.scaleY = nextFrame.transform.scaleY - frame.transform.scaleY;
			
			transform.x = frame.transform.x + transform.x * tweenProgress;
			transform.y = frame.transform.y + transform.y * tweenProgress;
			transform.skewX = frame.transform.skewX + transform.skewX * tweenProgress;
			transform.skewY = frame.transform.skewY + transform.skewY * tweenProgress;
			transform.scaleX = frame.transform.scaleX + transform.scaleX * tweenProgress;
			transform.scaleY = frame.transform.scaleY + transform.scaleY * tweenProgress;
		}
		
		transform.add(timeline.originalTransform);
	}
	
	private function _globalToLocal(armature:ArmatureData):Void // Support 2.x ~ 3.x data.
	{
		var keyFrames:Vector<BoneFrameData> = new Vector<BoneFrameData>();
		var bones:Vector<BoneData> = armature.sortedBones.concat().reverse();
		
		var l:UInt = bones.length;
		var bone:BoneData, frame:BoneFrameData, timeline:BoneTimelineData, parentTimeline:BoneTimelineData;
		var lJ:UInt;
		for (i in 0...l)
		{
			bone = bones[i];
			if (bone.parent != null) 
			{
				bone.parent.transform.toMatrix(_helpMatrix);
				_helpMatrix.invert();
				Transform.transformPoint(_helpMatrix, bone.transform.x, bone.transform.y, _helpPoint);
				bone.transform.x = _helpPoint.x;
				bone.transform.y = _helpPoint.y;
				bone.transform.rotation -= bone.parent.transform.rotation;
			}
			
			frame = null;
			for (animation in armature.animations) 
			{
				timeline = animation.getBoneTimeline(bone.name);
				
				if (timeline == null)
				{
					continue;	
				}
				
				parentTimeline = bone.parent? animation.getBoneTimeline(bone.parent.name): null;
				_helpTransformB.copyFrom(timeline.originalTransform);
				keyFrames.length = 0;
				
				lJ = timeline.frames.length;
				for (j in 0...lJ)
				{
					frame = cast timeline.frames[j];
					
					if (keyFrames.indexOf(frame) >= 0) 
					{
						continue;
					}
					
					keyFrames.push(frame);
					
					if (parentTimeline != null)
					{
						_getTimelineFrameMatrix(animation, parentTimeline, frame.position, _helpTransformA);
						frame.transform.add(_helpTransformB);
						_helpTransformA.toMatrix(_helpMatrix);
						_helpMatrix.invert();
						Transform.transformPoint(_helpMatrix, frame.transform.x, frame.transform.y, _helpPoint);
						frame.transform.x = _helpPoint.x;
						frame.transform.y = _helpPoint.y;
						frame.transform.rotation -= _helpTransformA.rotation;
					} 
					else 
					{
						frame.transform.add(_helpTransformB);
					}
					
					frame.transform.minus(bone.transform);
					
					if (j == 0) 
					{
						timeline.originalTransform.copyFrom(frame.transform);
						frame.transform.identity();
					} 
					else 
					{
						frame.transform.minus(timeline.originalTransform);
					}
				}
			}
		}
	}
	
	private function _mergeFrameToAnimationTimeline(framePositon:Float, actions:Vector<ActionData>, events:Vector<EventData>):Void 
	{
		var frameStart:UInt = Math.floor(framePositon * _armature.frameRate); // uint()
		var frames:Vector<FrameData> = _animation.frames;
		
		frames.fixed = false;
		
		if (frames.length == 0) {
			var startFrame:AnimationFrameData = cast BaseObject.borrowObject(AnimationFrameData); // Add start frame.
			startFrame.position = 0;
			
			if (_animation.frameCount > 1) {
				frames.length = _animation.frameCount + 1; // One more count for zero duration frame.
				
				var endFrame:AnimationFrameData = cast BaseObject.borrowObject(AnimationFrameData); // Add end frame to keep animation timeline has two different frames atleast.
				endFrame.position = _animation.frameCount / _armature.frameRate;
				
				frames[0] = startFrame;
				frames[_animation.frameCount] = endFrame;
			}
		}
		
		var i:UInt = 0, l:UInt = 0;
		var insertedFrame:AnimationFrameData = null;
		var replacedFrame:AnimationFrameData = frames.length? cast(frames[frameStart], AnimationFrameData): null;
		
		if (replacedFrame != null && (frameStart == 0 || frames[frameStart - 1] == replacedFrame.prev)) // Key frame.
		{
			insertedFrame = replacedFrame;
		} 
		else 
		{
			insertedFrame = cast BaseObject.borrowObject(AnimationFrameData); // Create frame.
			insertedFrame.position = frameStart / _armature.frameRate;
			frames[frameStart] = insertedFrame;
			
			for (i in (frameStart + 1)...l) // Clear replaced frame.
			{
				if (replacedFrame && frames[i] == replacedFrame) 
				{
					frames[i] = null;
				}
			}
		}
		
		if (actions != null) // Merge actions.
		{
			insertedFrame.actions.fixed = false;
			
			l = actions.length;
			for (i in 0...l)
			{
				insertedFrame.actions.push(actions[i]);
			}
			
			insertedFrame.actions.fixed = true;
		}
		
		if (events != null) // Merge events.
		{
			insertedFrame.events.fixed = false;
			
			l = events.length;
			for (i in 0...l)
			{
				insertedFrame.events.push(events[i]);
			}
			
			insertedFrame.events.fixed = true;
		}
		
		// Modify frame link and duration.
		var prevFrame:AnimationFrameData = null;
		var nextFrame:AnimationFrameData = null;
		l = frames.length;
		var currentFrame:AnimationFrameData;
		for (i in 0...l)
		{
			currentFrame = cast(frames[i], AnimationFrameData);
			if (currentFrame != null && nextFrame != currentFrame) 
			{
				nextFrame = currentFrame;
				
				if (prevFrame != null) 
				{
					nextFrame.prev = prevFrame;
					prevFrame.next = nextFrame;
					prevFrame.duration = nextFrame.position - prevFrame.position;
				}
				
				prevFrame = nextFrame;
			} 
			else 
			{
				frames[i] = prevFrame;
			}
		}
		
		nextFrame.duration = _animation.duration - nextFrame.position;
		
		nextFrame = cast(frames[0], AnimationFrameData);
		prevFrame.next = nextFrame;
		nextFrame.prev = prevFrame;
		
		frames.fixed = true;
	}
}