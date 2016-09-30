package dragonBones.objects;

/**
 * Copyright 2012-2013. DragonBones. All Rights Reserved.
 * @playerversion Flash 10.0, Flash 10
 * @langversion 3.0
 * @version 2.0
 */

import dragonBones.core.DragonBones;
import dragonBones.textures.TextureData;
import dragonBones.utils.ConstValues;
import dragonBones.utils.DBDataUtil;

import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import dragonBones.objects.DataParser.NamedTextureAtlasData;

/**
 * The XMLDataParser class parses xml data from dragonBones generated maps.
 */
class XMLDataParser
{
	public static function parseTextureAtlasData(rawData:Xml, scale:Float = 1):NamedTextureAtlasData
	{

		var textureAtlasData:Map<String, TextureData> = new Map<String, TextureData>();
		var name = rawData.get(ConstValues.A_NAME);
		var subTextureFrame:Rectangle;
		for (subTextureXML in rawData.elementsNamed(ConstValues.SUB_TEXTURE))
		{
			var subTextureName:String = subTextureXML.get(ConstValues.A_NAME);

			var subTextureRegion:Rectangle = new Rectangle();
			subTextureRegion.x = Std.parseInt(subTextureXML.get(ConstValues.A_X)) / scale;
			subTextureRegion.y = Std.parseInt(subTextureXML.get(ConstValues.A_Y)) / scale;
			subTextureRegion.width = Std.parseInt(subTextureXML.get(ConstValues.A_WIDTH)) / scale;
			subTextureRegion.height = Std.parseInt(subTextureXML.get(ConstValues.A_HEIGHT)) / scale;
			var rotated:Bool = subTextureXML.get(ConstValues.A_ROTATED) == "true";

			var frameWidth:Float = Std.parseInt(subTextureXML.get(ConstValues.A_FRAME_WIDTH)) / scale;
			var frameHeight:Float = Std.parseInt(subTextureXML.get(ConstValues.A_FRAME_HEIGHT)) / scale;

			if(frameWidth > 0 && frameHeight > 0)
			{
				subTextureFrame = new Rectangle();
				subTextureFrame.x = Std.parseInt(subTextureXML.get(ConstValues.A_FRAME_X)) / scale;
				subTextureFrame.y = Std.parseInt(subTextureXML.get(ConstValues.A_FRAME_Y)) / scale;
				subTextureFrame.width = frameWidth;
				subTextureFrame.height = frameHeight;
			}
			else
			{
				subTextureFrame = null;
			}

			textureAtlasData.set(subTextureName, new TextureData(subTextureRegion, subTextureFrame, rotated));
		}

		return { name: name, textureAtlasData: textureAtlasData } ;
	}

	/**
	 * Parse the SkeletonData.
	 * @param xml The SkeletonData xml to parse.
	 * @return A SkeletonData instance.
	 */
	public static function parseSkeletonData(rawData:Xml, ifSkipAnimationData:Bool = false, outputAnimationDictionary:Map<String, Map<String, Xml>> = null):SkeletonData
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
		var isGlobalData:Bool = rawData.get(ConstValues.A_IS_GLOBAL) == "0" ? false : true;
		for (armatureXML in rawData.elementsNamed(ConstValues.ARMATURE))
		{
			data.addArmatureData(parseArmatureData(armatureXML, data, frameRate, isGlobalData, ifSkipAnimationData, outputAnimationDictionary));
		}

		return data;
	}

	private static function parseArmatureData(armatureXML:Xml, data:SkeletonData, frameRate:UInt, isGlobalData:Bool, ifSkipAnimationData:Bool, outputAnimationDictionary:Map<String, Map<String, Xml>>):ArmatureData
	{
		var armatureData:ArmatureData = new ArmatureData();
		armatureData.name = armatureXML.get(ConstValues.A_NAME);

		for (boneXML in armatureXML.elementsNamed(ConstValues.BONE))
		{
			armatureData.addBoneData(parseBoneData(boneXML, isGlobalData));
		}

		for (skinXML in armatureXML.elementsNamed(ConstValues.SKIN))
		{
			armatureData.addSkinData(parseSkinData(skinXML, data));
		}

		if(isGlobalData)
		{
			DBDataUtil.transformArmatureData(armatureData);
		}
		armatureData.sortBoneDataList();

		var animationXML:Xml;
		if(ifSkipAnimationData)
		{
			if(outputAnimationDictionary!= null)
			{
				outputAnimationDictionary.set(armatureData.name, new Map<String, Xml>());
			}

			var index:Int = 0;
			for (animationXML in armatureXML.elementsNamed(ConstValues.ANIMATION))
			{
				if(index == 0)
				{
					armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate, isGlobalData));
				}
				else if(outputAnimationDictionary != null)
				{
				    var dictionary = outputAnimationDictionary.get(armatureData.name);
					dictionary.set(animationXML.get(ConstValues.A_NAME), animationXML);
				}
				index++;
			}
		}
		else
		{
			for (animationXML in armatureXML.elementsNamed(ConstValues.ANIMATION))
			{
				armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate, isGlobalData));
			}
		}

		for (rectangleXML in armatureXML.elementsNamed(ConstValues.RECTANGLE))
		{
			armatureData.addAreaData(parseRectangleData(rectangleXML));
		}

		for (ellipseXML in armatureXML.elementsNamed(ConstValues.ELLIPSE))
		{
			armatureData.addAreaData(parseEllipseData(ellipseXML));
		}

		return armatureData;
	}

	private static function parseBoneData(boneXML:Xml, isGlobalData:Bool):BoneData
	{
		var boneData:BoneData = new BoneData();
		boneData.name = boneXML.get(ConstValues.A_NAME);
		boneData.parent = boneXML.get(ConstValues.A_PARENT);
		boneData.length = Std.parseFloat(boneXML.get(ConstValues.A_LENGTH));
		boneData.inheritRotation = getBoolean(boneXML, ConstValues.A_INHERIT_ROTATION, true);
		boneData.inheritScale = getBoolean(boneXML, ConstValues.A_INHERIT_SCALE, true);


		for (transformXML in boneXML.elementsNamed(ConstValues.TRANSFORM)) {
			parseTransform(transformXML, boneData.transform);
			if(isGlobalData)//绝对数据
			{
				boneData.global.copy(boneData.transform);
			}
		}

		for (rectangleXML in boneXML.elementsNamed(ConstValues.RECTANGLE))
		{
			boneData.addAreaData(parseRectangleData(rectangleXML));
		}

		for (ellipseXML in boneXML.elementsNamed(ConstValues.ELLIPSE))
		{
			boneData.addAreaData(parseEllipseData(ellipseXML));
		}

		return boneData;
	}

	private static function parseRectangleData(rectangleXML:Xml):RectangleData
	{
		var rectangleData:RectangleData = new RectangleData();
		rectangleData.name = rectangleXML.get(ConstValues.A_NAME);
		rectangleData.width = Std.parseFloat(rectangleXML.get(ConstValues.A_WIDTH));
		rectangleData.height = Std.parseFloat(rectangleXML.get(ConstValues.A_HEIGHT));

		for (transformXML in rectangleXML.elementsNamed(ConstValues.TRANSFORM)) {
			parseTransform(transformXML, rectangleData.transform, rectangleData.pivot);
		}

		return rectangleData;
	}

	private static function parseEllipseData(ellipseXML:Xml):EllipseData
	{
		var ellipseData:EllipseData = new EllipseData();
		ellipseData.name = ellipseXML.get(ConstValues.A_NAME);
		ellipseData.width = Std.parseFloat(ellipseXML.get(ConstValues.A_WIDTH));
		ellipseData.height = Std.parseFloat(ellipseXML.get(ConstValues.A_HEIGHT));

		for (transformXML in ellipseXML.elementsNamed(ConstValues.TRANSFORM)) {
			parseTransform(transformXML, ellipseData.transform, ellipseData.pivot);
		}

		return ellipseData;
	}

	private static function parseSkinData(skinXML:Xml, data:SkeletonData):SkinData
	{
		var skinData:SkinData = new SkinData();
		skinData.name = skinXML.get(ConstValues.A_NAME);

		for (slotXML in skinXML.elementsNamed(ConstValues.SLOT))
		{
			skinData.addSlotData(parseSlotData(slotXML, data));
		}

		return skinData;
	}

	private static function parseSlotData(slotXML:Xml, data:SkeletonData):SlotData
	{
		var slotData:SlotData = new SlotData();
		slotData.name = slotXML.get(ConstValues.A_NAME);
		slotData.parent = slotXML.get(ConstValues.A_PARENT);
		slotData.zOrder = ifNaNOrZeroReturn(getNumber(slotXML, ConstValues.A_Z_ORDER, 0), 0);
		slotData.blendMode = slotXML.get(ConstValues.A_BLENDMODE);
		for (displayXML in slotXML.elementsNamed(ConstValues.DISPLAY))
		{
			slotData.addDisplayData(parseDisplayData(displayXML, data));
		}

		return slotData;
	}

	private static function parseDisplayData(displayXML:Xml, data:SkeletonData):DisplayData
	{
		var displayData:DisplayData = new DisplayData();
		displayData.name = displayXML.get(ConstValues.A_NAME);
		displayData.type = displayXML.get(ConstValues.A_TYPE);

		displayData.pivot = data.addSubTexturePivot(
			0,
			0,
			displayData.name
		);

		for (transformXML in displayXML.elementsNamed(ConstValues.TRANSFORM)) {
			parseTransform(transformXML, displayData.transform, displayData.pivot);
		}

		return displayData;
	}

	/** @private */
	public static function parseAnimationData(animationXML:Xml, armatureData:ArmatureData, frameRate:UInt, isGlobalData:Bool):AnimationData
	{
		var animationData:AnimationData = new AnimationData();
		animationData.name = animationXML.get(ConstValues.A_NAME);
		animationData.frameRate = frameRate;
		animationData.duration = Math.round(ifNaNOrZeroReturn(Std.parseFloat(animationXML.get(ConstValues.A_DURATION)), 1) * 1000 / frameRate);
		animationData.playTimes = Std.int(getNumber(animationXML, ConstValues.A_LOOP, 1));
		animationData.fadeTime = ifNaNOrZeroReturn(getNumber(animationXML, ConstValues.A_FADE_IN_TIME, 0), 0);
		animationData.scale = ifNaNOrZeroReturn(getNumber(animationXML, ConstValues.A_SCALE, 1), 0);
		//use frame tweenEase, NaN
		//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
		animationData.tweenEasing = getNumber(animationXML, ConstValues.A_TWEEN_EASING, Math.NaN);
		animationData.autoTween = getBoolean(animationXML, ConstValues.A_AUTO_TWEEN, true);

		for (frameXML in animationXML.elementsNamed(ConstValues.FRAME))
		{
			var frame:Frame = parseTransformFrame(frameXML, frameRate, isGlobalData);
			animationData.addFrame(frame);
		}

		parseTimeline(animationXML, animationData);

		var lastFrameDuration:Int = animationData.duration;
		for (timelineXML in animationXML.elementsNamed(ConstValues.TIMELINE))
		{
			var timeline:TransformTimeline = parseTransformTimeline(timelineXML, animationData.duration, frameRate, isGlobalData);
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

	private static function parseTransformTimeline(timelineXML:Xml, duration:Int, frameRate:UInt, isGlobalData:Bool):TransformTimeline
	{
		var timeline:TransformTimeline = new TransformTimeline();
		timeline.name = timelineXML.get(ConstValues.A_NAME);
		timeline.scale = getNumberOrDefault(timelineXML, ConstValues.A_SCALE, 1);
		timeline.offset = getNumberOrDefault(timelineXML, ConstValues.A_OFFSET, 0);
		timeline.originPivot.x = getNumberOrDefault(timelineXML, ConstValues.A_PIVOT_X, 0);
		timeline.originPivot.y = getNumberOrDefault(timelineXML, ConstValues.A_PIVOT_Y, 0);
		timeline.duration = duration;

		for (frameXML in timelineXML.elementsNamed(ConstValues.FRAME))
		{
			var frame:TransformFrame = parseTransformFrame(frameXML, frameRate, isGlobalData);
			timeline.addFrame(frame);
		}

		parseTimeline(timelineXML, timeline);

		return timeline;
	}

	private static function parseMainFrame(frameXML:Xml, frameRate:UInt):Frame
	{
		var frame:Frame = new Frame();
		parseFrame(frameXML, frame, frameRate);
		return frame;
	}

	private static function parseTransformFrame(frameXML:Xml, frameRate:UInt, isGlobalData:Bool):TransformFrame
	{
		var frame:TransformFrame = new TransformFrame();
		parseFrame(frameXML, frame, frameRate);

		frame.visible = !getBoolean(frameXML, ConstValues.A_HIDE, false);

		//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
		frame.tweenEasing = getNumber(frameXML, ConstValues.A_TWEEN_EASING, 10);
		frame.tweenRotate = Std.int(getNumber(frameXML, ConstValues.A_TWEEN_ROTATE,0));
		frame.tweenScale = getBoolean(frameXML, ConstValues.A_TWEEN_SCALE, true);
		frame.displayIndex = Std.int(getNumber(frameXML, ConstValues.A_DISPLAY_INDEX, 0));

		//如果为NaN，则说明没有改变过zOrder
		frame.zOrder = getNumber(frameXML, ConstValues.A_Z_ORDER, isGlobalData ? Math.NaN : 0);

		for (transformXML in frameXML.elementsNamed(ConstValues.TRANSFORM)) {
			parseTransform(transformXML, frame.transform, frame.pivot);
		}
		if(isGlobalData)//绝对数据
		{
			frame.global.copy(frame.transform);
		}

		frame.scaleOffset.x = getNumberOrDefault(frameXML, ConstValues.A_SCALE_X_OFFSET, 0);
		frame.scaleOffset.y = getNumberOrDefault(frameXML, ConstValues.A_SCALE_Y_OFFSET, 0);

		for (colorTransformXML in frameXML.elementsNamed(ConstValues.COLOR_TRANSFORM)) {
			if(colorTransformXML != null)
			{
				frame.color = new ColorTransform();
				parseColorTransform(colorTransformXML, frame.color);
			}
		}

		return frame;
	}

	private static function parseTimeline(timelineXML:Xml, timeline:Timeline):Void
	{
		var position:Int = 0;
		var frame:Frame = null;
		for (frame in timeline.frameList)
		{
			frame.position = position;
			position += frame.duration;
		}
		if(frame != null)
		{
			frame.duration = timeline.duration - frame.position;
		}
	}

	private static function parseFrame(frameXML:Xml, frame:Frame, frameRate:UInt):Void
	{
		frame.duration = Std.int(Math.round(getNumberOrDefault(frameXML, ConstValues.A_DURATION, 1) * 1000 / frameRate));
		frame.action = frameXML.get(ConstValues.A_ACTION);
		frame.event = frameXML.get(ConstValues.A_EVENT);
		frame.sound = frameXML.get(ConstValues.A_SOUND);
	}

	private static function parseTransform(transformXML:Xml, transform:DBTransform, pivot:Point = null):Void
	{
		if(transformXML != null)
		{
			if(transform != null)
			{
				transform.x = getNumberOrDefault(transformXML, ConstValues.A_X, 0);
				transform.y = getNumberOrDefault(transformXML, ConstValues.A_Y, 0);
				transform.skewX = getNumberOrDefault(transformXML, ConstValues.A_SKEW_X, 0) * ConstValues.ANGLE_TO_RADIAN;
				transform.skewY = getNumberOrDefault(transformXML, ConstValues.A_SKEW_Y, 0) * ConstValues.ANGLE_TO_RADIAN;
				transform.scaleX = ifNaNOrZeroReturn(getNumber(transformXML, ConstValues.A_SCALE_X, 1), 0);
				transform.scaleY = ifNaNOrZeroReturn(getNumber(transformXML, ConstValues.A_SCALE_Y, 1), 0);
			}
			if(pivot != null)
			{
				pivot.x = getNumberOrDefault(transformXML, ConstValues.A_PIVOT_X, 0);
				pivot.y = getNumberOrDefault(transformXML, ConstValues.A_PIVOT_Y, 0);
			}
		}
	}

	private static function parseColorTransform(colorTransformXML:Xml, colorTransform:ColorTransform):Void
	{
		if(colorTransformXML != null)
		{
			if(colorTransform != null)
			{
				colorTransform.alphaOffset = Std.parseInt(colorTransformXML.get(ConstValues.A_ALPHA_OFFSET));
				colorTransform.redOffset = Std.parseInt(colorTransformXML.get(ConstValues.A_RED_OFFSET));
				colorTransform.greenOffset = Std.parseInt(colorTransformXML.get(ConstValues.A_GREEN_OFFSET));
				colorTransform.blueOffset = Std.parseInt(colorTransformXML.get(ConstValues.A_BLUE_OFFSET));

				colorTransform.alphaMultiplier = Std.int(getNumberOrDefault(colorTransformXML, ConstValues.A_ALPHA_MULTIPLIER, 100)) * 0.01;
				colorTransform.redMultiplier = Std.int(getNumberOrDefault(colorTransformXML, ConstValues.A_RED_MULTIPLIER, 100)) * 0.01;
				colorTransform.greenMultiplier = Std.int(getNumberOrDefault(colorTransformXML, ConstValues.A_GREEN_MULTIPLIER, 100)) * 0.01;
				colorTransform.blueMultiplier = Std.int(getNumberOrDefault(colorTransformXML, ConstValues.A_BLUE_MULTIPLIER, 100)) * 0.01;
			}
		}
	}

	private static function getBoolean(data:Xml, key:String, defaultValue:Bool):Bool
	{
		var val = data.get(key);
		if(data != null &&  val != null)
		{
			switch(val)
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
		return defaultValue;
	}

	private static function getNumber(data:Xml, key:String, defaultValue:Float):Float
	{
        var retval = defaultValue, strValue = "<error>";

		if(data != null) {
			var val = data.get(key);
			if (val != null && val.length > 0) {
				switch(val)
				{
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
						retval =  Std.parseFloat(val);
						strValue = val;
				}
			}
		}

		//trace("getNumber " + key + ": " + retval + " from string " + strValue);
		return retval;
	}

    private static function getNumberOrDefault(data:Xml, key:String, defaultValue:Float):Float {
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
