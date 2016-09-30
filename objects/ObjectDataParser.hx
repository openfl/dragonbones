package dragonBones.objects;

import dragonBones.core.DragonBones;
import dragonBones.objects.AnimationData;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.BoneData;
import dragonBones.objects.DBTransform;
import dragonBones.objects.DisplayData;
import dragonBones.objects.Frame;
import dragonBones.objects.SkeletonData;
import dragonBones.objects.SkinData;
import dragonBones.objects.SlotData;
import dragonBones.objects.Timeline;
import dragonBones.objects.TransformFrame;
import dragonBones.objects.TransformTimeline;
import dragonBones.textures.TextureData;
import dragonBones.utils.ConstValues;
import dragonBones.utils.DBDataUtil;

import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import dragonBones.objects.DataParser.NamedTextureAtlasData;

class ObjectDataParser
{

	public static function parseTextureAtlasData(rawData:Dynamic, scale:Float = 1):NamedTextureAtlasData
	{
		var textureAtlasData:Map<String, Dynamic> = new Map<String, Dynamic>();
		var name = rawData.get(ConstValues.A_NAME);
		var subTextureFrame:Rectangle;

		for (subTextureObject in getArray(rawData, ConstValues.SUB_TEXTURE))
		{
			var subTextureName:String = subTextureObject.get(ConstValues.A_NAME);
			var subTextureRegion:Rectangle = new Rectangle();
			subTextureRegion.x = Std.int(subTextureObject.get(ConstValues.A_X)) / scale;
			subTextureRegion.y = Std.int(subTextureObject.get(ConstValues.A_Y)) / scale;
			subTextureRegion.width = Std.int(subTextureObject.get(ConstValues.A_WIDTH)) / scale;
			subTextureRegion.height = Std.int(subTextureObject.get(ConstValues.A_HEIGHT)) / scale;

			var rotated:Bool = subTextureObject.get(ConstValues.A_ROTATED) == "true";

			var frameWidth:Float = Std.int(subTextureObject.get(ConstValues.A_FRAME_WIDTH)) / scale;
			var frameHeight:Float = Std.int(subTextureObject.get(ConstValues.A_FRAME_HEIGHT)) / scale;

			if(frameWidth > 0 && frameHeight > 0)
			{
				subTextureFrame = new Rectangle();
				subTextureFrame.x = Std.int(subTextureObject.get(ConstValues.A_FRAME_X)) / scale;
				subTextureFrame.y = Std.int(subTextureObject.get(ConstValues.A_FRAME_Y)) / scale;
				subTextureFrame.width = frameWidth;
				subTextureFrame.height = frameHeight;
			}
			else
			{
				subTextureFrame = null;
			}

			textureAtlasData[subTextureName] = new TextureData(subTextureRegion, subTextureFrame, rotated);
		}

		return { name: name, textureAtlasData: textureAtlasData};
	}

	public static function parseSkeletonData(rawData:Dynamic, ifSkipAnimationData:Bool=false, outputAnimationDictionary:Map<String, Map<String, Dynamic>> = null):SkeletonData
	{
		if(rawData == null)
		{
			throw "ArgumentError";
		}
		var version:String = rawData.get(ConstValues.A_VERSION);
		if (!(version == "2.3" || version == "3.0" || version == DragonBones.DATA_VERSION)) {
			throw "Nonsupport version!";
		}


		var frameRate:UInt = Std.parseInt(rawData.get(ConstValues.A_FRAME_RATE));

		var data:SkeletonData = new SkeletonData();
		data.name = rawData.get(ConstValues.A_NAME);
		var isGlobalData:Bool = getBoolean(rawData, ConstValues.A_IS_GLOBAL, true);

		for (armatureObject in getArray(rawData, ConstValues.ARMATURE))
		{
			data.addArmatureData(parseArmatureData(armatureObject, data, frameRate, isGlobalData, ifSkipAnimationData, outputAnimationDictionary));
		}

		return data;

	}

	private static function parseArmatureData(armatureObject:Dynamic, data:SkeletonData, frameRate:UInt, isGlobalData:Bool, ifSkipAnimationData:Bool, outputAnimationDictionary:Map<String, Map<String, Dynamic>>):ArmatureData
	{
		var armatureData:ArmatureData = new ArmatureData();
		armatureData.name = armatureObject.get(ConstValues.A_NAME);

		for (boneObject in getArray(armatureObject, ConstValues.BONE))
		{
			armatureData.addBoneData(parseBoneData(boneObject, isGlobalData));
		}

		for (skinObject in getArray(armatureObject, ConstValues.SKIN))
		{
			armatureData.addSkinData(parseSkinData(skinObject, data));
		}

		if(isGlobalData)
		{
			DBDataUtil.transformArmatureData(armatureData);
		}
		armatureData.sortBoneDataList();

		var animationObject:Dynamic;
		if(ifSkipAnimationData)
		{
			if(outputAnimationDictionary!= null)
			{
				outputAnimationDictionary.set(armatureData.name, new Map<String, Dynamic>());
			}

			var index:Int = 0;
			for (animationObject in getArray(armatureObject, ConstValues.ANIMATION))
			{
				if(index == 0)
				{
					armatureData.addAnimationData(parseAnimationData(animationObject, armatureData, frameRate, isGlobalData));
				}
				else if(outputAnimationDictionary != null)
				{
					var dictionary = outputAnimationDictionary.get(armatureData.name);
					dictionary.set(animationObject.get(ConstValues.A_NAME), animationObject);
				}
				index++;
			}
		}
		else
		{
			for (animationObject in getArray(armatureObject, ConstValues.ANIMATION))
			{
				armatureData.addAnimationData(parseAnimationData(animationObject, armatureData, frameRate, isGlobalData));
			}
		}

		for (rectangleObject in getArray(armatureObject, ConstValues.RECTANGLE))
		{
			armatureData.addAreaData(parseRectangleData(rectangleObject));
		}

		for (ellipseObject in getArray(armatureObject, ConstValues.ELLIPSE))
		{
			armatureData.addAreaData(parseEllipseData(ellipseObject));
		}

		return armatureData;
	}

	private static function parseBoneData(boneObject:Dynamic, isGlobalData:Bool):BoneData
	{
		var boneData:BoneData = new BoneData();
		boneData.name = boneObject.get(ConstValues.A_NAME);
		boneData.parent = boneObject.get(ConstValues.A_PARENT);
		boneData.length = getNumberOrDefault(boneObject, ConstValues.A_LENGTH, 0);
		boneData.inheritRotation = getBoolean(boneObject, ConstValues.A_INHERIT_ROTATION, true);
		boneData.inheritScale = getBoolean(boneObject, ConstValues.A_INHERIT_SCALE, true);

		parseTransform(boneObject.get(ConstValues.TRANSFORM), boneData.transform);
		if(isGlobalData)//绝对数据
		{
			boneData.global.copy(boneData.transform);
		}

		for (rectangleObject in getArray(boneObject, ConstValues.RECTANGLE))
		{
			boneObject.addAreaData(parseRectangleData(rectangleObject));
		}

		for (ellipseObject in getArray(boneObject, ConstValues.ELLIPSE))
		{
			boneObject.addAreaData(parseEllipseData(ellipseObject));
		}

		return boneData;
	}

	private static function parseRectangleData(rectangleObject:Dynamic):RectangleData
	{
		var rectangleData:RectangleData = new RectangleData();
		rectangleData.name = rectangleObject.get(ConstValues.A_NAME);
		rectangleData.width = Std.parseFloat(rectangleObject.get(ConstValues.A_WIDTH));
		rectangleData.height = Std.parseFloat(rectangleObject.get(ConstValues.A_HEIGHT));

		parseTransform(rectangleObject.get(ConstValues.TRANSFORM), rectangleData.transform, rectangleData.pivot);

		return rectangleData;
	}

	private static function parseEllipseData(ellipseObject:Dynamic):EllipseData
	{
		var ellipseData:EllipseData = new EllipseData();
		ellipseData.name = ellipseObject.get(ConstValues.A_NAME);
		ellipseData.width = Std.parseFloat(ellipseObject.get(ConstValues.A_WIDTH));
		ellipseData.height = Std.parseFloat(ellipseObject.get(ConstValues.A_HEIGHT));

		parseTransform(ellipseObject.get(ConstValues.TRANSFORM), ellipseData.transform, ellipseData.pivot);

		return ellipseData;
	}

	private static function parseSkinData(skinObject:Dynamic, data:SkeletonData):SkinData
	{
		var skinData:SkinData = new SkinData();
		skinData.name = skinObject.get(ConstValues.A_NAME);

		for(slotObject in getArray(skinObject, ConstValues.SLOT))
		{
			skinData.addSlotData(parseSlotData(slotObject, data));
		}

		return skinData;
	}

	private static function parseSlotData(slotObject:Dynamic, data:SkeletonData):SlotData
	{
		var slotData:SlotData = new SlotData();
		slotData.name = slotObject.get(ConstValues.A_NAME);
		slotData.parent = slotObject.get(ConstValues.A_PARENT);
		slotData.zOrder = ifNaNOrZeroReturn(getNumber(slotObject, ConstValues.A_Z_ORDER, 0), 0);
		slotData.blendMode = slotObject.get(ConstValues.A_BLENDMODE);

		for (displayObject in getArray(slotObject, ConstValues.DISPLAY))
		{
			slotData.addDisplayData(parseDisplayData(displayObject, data));
		}

		return slotData;
	}

	private static function parseDisplayData(displayObject:Dynamic, data:SkeletonData):DisplayData
	{
		var displayData:DisplayData = new DisplayData();
		displayData.name = displayObject.get(ConstValues.A_NAME);
		displayData.type = displayObject.get(ConstValues.A_TYPE);

		displayData.pivot = data.addSubTexturePivot(
			0,
			0,
			displayData.name
		);

		parseTransform(displayObject.get(ConstValues.TRANSFORM), displayData.transform, displayData.pivot);

		return displayData;
	}

	//
	public static function parseAnimationData(animationObject:Dynamic, armatureData:ArmatureData, frameRate:UInt, isGlobalData:Bool):AnimationData
	{
		var animationData:AnimationData = new AnimationData();
		animationData.name = animationObject.get(ConstValues.A_NAME);
		animationData.frameRate = frameRate;
		animationData.duration = Math.round(ifNaNOrZeroReturn(Std.parseFloat(animationObject.get(ConstValues.A_DURATION)), 1) * 1000 / frameRate);
		animationData.playTimes = Std.int(getNumber(animationObject, ConstValues.A_LOOP, 1));
		animationData.fadeTime = ifNaNOrZeroReturn(getNumber(animationObject, ConstValues.A_FADE_IN_TIME, 0), 0);
		animationData.scale = ifNaNOrZeroReturn(getNumber(animationObject, ConstValues.A_SCALE, 1), 0);
		//use frame tweenEase, NaN
		//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
		animationData.tweenEasing = getNumber(animationObject, ConstValues.A_TWEEN_EASING, Math.NaN);
		animationData.autoTween = getBoolean(animationObject, ConstValues.A_AUTO_TWEEN, true);

		for (frameObject in getArray(animationObject, ConstValues.FRAME))
		{
			var frame:Frame = parseTransformFrame(frameObject, frameRate, isGlobalData);
			animationData.addFrame(frame);
		}

		parseTimeline(animationObject, animationData);

		var lastFrameDuration:Int = animationData.duration;
		for (timelineObject in getArray(animationObject, ConstValues.TIMELINE))
		{
			var timeline:TransformTimeline = parseTransformTimeline(timelineObject, animationData.duration, frameRate, isGlobalData);
			lastFrameDuration = Std.int(Math.min(lastFrameDuration, timeline.frameList[timeline.frameList.length - 1].duration));
			animationData.addTimeline(timeline);
		}

		if(animationData.frameList.length > 0)
		{
			lastFrameDuration = Std.int(Math.min(lastFrameDuration, animationData.frameList[animationData.frameList.length - 1].duration));
		}
		animationData.lastFrameDuration = lastFrameDuration;

		DBDataUtil.addHideTimeline(animationData, armatureData);
		DBDataUtil.transformAnimationData(animationData, armatureData, isGlobalData);

		return animationData;
	}

	private static function parseTransformTimeline(timelineObject:Dynamic, duration:Int, frameRate:UInt, isGlobalData:Bool):TransformTimeline
	{
		var timeline:TransformTimeline = new TransformTimeline();
		timeline.name = timelineObject.get(ConstValues.A_NAME);
		timeline.scale = getNumberOrDefault(timelineObject, ConstValues.A_SCALE, 1);
		timeline.offset = getNumberOrDefault(timelineObject, ConstValues.A_OFFSET, 0);
		timeline.originPivot.x = getNumberOrDefault(timelineObject, ConstValues.A_PIVOT_X, 0);
		timeline.originPivot.y = getNumberOrDefault(timelineObject, ConstValues.A_PIVOT_Y, 0);
		timeline.duration = duration;

		for (frameObject in getArray(timelineObject, ConstValues.FRAME))
		{
			var frame:TransformFrame = parseTransformFrame(frameObject, frameRate, isGlobalData);
			timeline.addFrame(frame);
		}

		parseTimeline(timelineObject, timeline);

		return timeline;
	}

	private static function parseMainFrame(frameObject:Dynamic, frameRate:UInt):Frame
	{
		var frame:Frame = new Frame();
		parseFrame(frameObject, frame, frameRate);
		return frame;
	}

	private static function parseTransformFrame(frameObject:Dynamic, frameRate:UInt, isGlobalData:Bool):TransformFrame
	{
		var frame:TransformFrame = new TransformFrame();
		parseFrame(frameObject, frame, frameRate);

		frame.visible = !getBoolean(frameObject, ConstValues.A_HIDE, false);

		//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
		frame.tweenEasing = getNumber(frameObject, ConstValues.A_TWEEN_EASING, 10);
		frame.tweenRotate = Std.int(getNumber(frameObject, ConstValues.A_TWEEN_ROTATE, 0));
		frame.tweenScale = getBoolean(frameObject, ConstValues.A_TWEEN_SCALE, true);
		frame.displayIndex = Std.int(getNumber(frameObject, ConstValues.A_DISPLAY_INDEX, 0));

		//如果为NaN，则说明没有改变过zOrder
		frame.zOrder = getNumber(frameObject, ConstValues.A_Z_ORDER, isGlobalData ? Math.NaN : 0);

		parseTransform(frameObject.get(ConstValues.TRANSFORM), frame.transform, frame.pivot);
		if(isGlobalData)//绝对数据
		{
			frame.global.copy(frame.transform);
		}

		frame.scaleOffset.x = getNumberOrDefault(frameObject, ConstValues.A_SCALE_X_OFFSET, 0);
		frame.scaleOffset.y = getNumberOrDefault(frameObject, ConstValues.A_SCALE_Y_OFFSET, 0);

		var colorTransformObject:Dynamic = frameObject.get(ConstValues.COLOR_TRANSFORM);
		if(colorTransformObject)
		{
			frame.color = new ColorTransform();
			parseColorTransform(colorTransformObject, frame.color);
		}

		return frame;
	}

	private static function parseTimeline(timelineObject:Dynamic, timeline:Timeline):Void
	{
		var position:Int = 0;
		var lastFrame = null;
		for (frame in timeline.frameList)
		{
			frame.position = position;
			position += frame.duration;
			lastFrame = frame;
		}
		if(lastFrame != null)
		{
			lastFrame.duration = timeline.duration - lastFrame.position;
		}
	}

	private static function parseFrame(frameObject:Dynamic, frame:Frame, frameRate:UInt):Void
	{
		frame.duration = Std.int(Math.round(getNumberOrDefault(frameObject, ConstValues.A_DURATION, 1) * 1000 / frameRate));
		frame.action = frameObject.get(ConstValues.A_ACTION);
		frame.event = frameObject.get(ConstValues.A_EVENT);
		frame.sound = frameObject.get(ConstValues.A_SOUND);
	}

	private static function parseTransform(transformObject:Dynamic, transform:DBTransform, pivot:Point = null):Void
	{
		if(transformObject != null)
		{
			if(transform != null)
			{
				transform.x = getNumberOrDefault(transformObject, ConstValues.A_X, 0);
				transform.y = getNumberOrDefault(transformObject, ConstValues.A_Y, 0);
				transform.skewX = getNumberOrDefault(transformObject, ConstValues.A_SKEW_X, 0) * ConstValues.ANGLE_TO_RADIAN;
				transform.skewY = getNumberOrDefault(transformObject, ConstValues.A_SKEW_Y, 0) * ConstValues.ANGLE_TO_RADIAN;
				transform.scaleX = ifNaNOrZeroReturn(getNumber(transformObject, ConstValues.A_SCALE_X, 1), 0);
				transform.scaleY = ifNaNOrZeroReturn(getNumber(transformObject, ConstValues.A_SCALE_Y, 1), 0);
			}
			if(pivot != null)
			{
				pivot.x = getNumberOrDefault(transformObject, ConstValues.A_PIVOT_X, 0);
				pivot.y = getNumberOrDefault(transformObject, ConstValues.A_PIVOT_Y, 0);
			}
		}
	}

	private static function parseColorTransform(colorTransformObject:Dynamic, colorTransform:ColorTransform):Void
	{

		if(colorTransformObject != null)
		{
			if(colorTransform != null)
			{
				colorTransform.alphaOffset = Std.int(colorTransformObject.get(ConstValues.A_ALPHA_OFFSET));
				colorTransform.redOffset = Std.int(colorTransformObject.get(ConstValues.A_RED_OFFSET));
				colorTransform.greenOffset = Std.int(colorTransformObject.get(ConstValues.A_GREEN_OFFSET));
				colorTransform.blueOffset = Std.int(colorTransformObject.get(ConstValues.A_BLUE_OFFSET));

				colorTransform.alphaMultiplier = Std.int(getNumberOrDefault(colorTransformObject, ConstValues.A_ALPHA_MULTIPLIER,100)) * 0.01;
				colorTransform.redMultiplier = Std.int(getNumberOrDefault(colorTransformObject,ConstValues.A_RED_MULTIPLIER,100)) * 0.01;
				colorTransform.greenMultiplier = Std.int(getNumberOrDefault(colorTransformObject,ConstValues.A_GREEN_MULTIPLIER,100)) * 0.01;
				colorTransform.blueMultiplier = Std.int(getNumberOrDefault(colorTransformObject,ConstValues.A_BLUE_MULTIPLIER,100)) * 0.01;
			}
		}
	}

	private static function getArray(data:Dynamic, key:String):Array<Dynamic>
	{
		var retval = null;
		if (data != null)
		{
			retval = data.get(key);
		}
		if (retval == null) {
			retval = new Array<Dynamic>();
		}

		return retval;
	}

	private static function getBoolean(data:Dynamic, key:String, defaultValue:Bool):Bool
	{

		if(data != null)
		{
			var val:Dynamic = data.get(key);
			var v = Std.string(val);

			if (v != null && v.length > 0) {
				switch(v)
				{
					case "0":
						return false;
					case "NaN":
						return false;
					case "":
						return false;
					case "false":
						return false;
					case "null":
						return false;
					case "undefined":
						return false;

					case "1":
						return true;
					case "true":
						return true;
					default:
						return true;
				}
			}
		}
		return defaultValue;
	}


	private static function getNumber(data:Dynamic, key:String, defaultValue:Float):Float
	{
		var retval = defaultValue, strValue = "<error>";

		if(data != null) {
			var val:Dynamic = data.get(key);
			var v:String = Std.string(val);

			if (v != null && v.length > 0) {
				switch(v)
				{
					case "Infinity":
						retval = Math.NaN;
					case "-Infinity":
						retval = Math.NaN;
					case "NaN":
						retval = Math.NaN;
					case "":
						retval =  Math.NaN;
					case "false":
						retval =  Math.NaN;
					case "null":
						retval =  Math.NaN;
					case "undefined":
						retval =  Math.NaN;

					default:
						retval =  Std.parseFloat(v);
						strValue = v;
				}
			}
		}

//trace("getNumber " + key + ": " + retval + " from string " + strValue);
		return retval;
	}

	private static function getNumberOrDefault(data:Dynamic, key:String, defaultValue:Float):Float {
		var val = getNumber(data, key, defaultValue);
		if (Math.isNaN(val)) {
			return defaultValue;
		}
		return val;
	}

	private static function ifNaNOrZeroReturn(n:Float, r:Float):Float {
		if (Math.isNaN(n) || n == 0) {
			return r;
		}
		return n;
	}


}
