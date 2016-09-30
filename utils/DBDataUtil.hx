package dragonBones.utils;

import dragonBones.animation.TimelineState;
import dragonBones.objects.AnimationData;
import dragonBones.objects.ArmatureData;
import dragonBones.objects.BoneData;
import dragonBones.objects.DBTransform;
import dragonBones.objects.Frame;
import dragonBones.objects.SkinData;
import dragonBones.objects.SlotData;
import dragonBones.objects.TransformFrame;
import dragonBones.objects.TransformTimeline;
import dragonBones.utils.TransformUtil;

import flash.geom.Matrix;
import flash.geom.Point;

/** @private */
class DBDataUtil
{
	public static function transformArmatureData(armatureData:ArmatureData):Void
	{
		var boneDataList:Array<BoneData> = armatureData.boneDataList;
		var i:Int = boneDataList.length;

		while(i -- > 0)
		{
			var boneData:BoneData = boneDataList[i];
			if(boneData.parent != null)
			{
				var parentBoneData:BoneData = armatureData.getBoneData(boneData.parent);
				if(parentBoneData != null)
				{
					boneData.transform.copy(boneData.global);
					TransformUtil.globalToLocal(boneData.transform, parentBoneData.global);
				}
			}
		}
	}

	public static function transformArmatureDataAnimations(armatureData:ArmatureData):Void
	{
		var animationDataList:Array<AnimationData> = armatureData.animationDataList;
		var i:Int = animationDataList.length;
		while(i -- > 0)
		{
			transformAnimationData(animationDataList[i], armatureData, false);
		}
	}

	public static function transformRelativeAnimationData(animationData:AnimationData, armatureData:ArmatureData):Void
	{

	}

	public static function transformAnimationData(animationData:AnimationData, armatureData:ArmatureData, isGlobalData:Bool):Void
	{
		if(!isGlobalData)
		{
			transformRelativeAnimationData(animationData, armatureData);
			return;
		}

		var skinData:SkinData = armatureData.getSkinData(null);
		var boneDataList:Array<BoneData> = armatureData.boneDataList;
		var slotDataList:Array<SlotData> = null;
		if(skinData != null)
		{
			slotDataList = skinData.slotDataList;
		}

		for(i in 0...boneDataList.length)
		{
			var boneData:BoneData = boneDataList[i];
			var timeline:TransformTimeline = animationData.getTimeline(boneData.name);
			if(timeline == null)
			{
				continue;
			}

			var slotData:SlotData = null;
			if(slotDataList != null)
			{
				for (slotData in slotDataList)
				{
					if(slotData.parent == boneData.name)
					{
						break;
					}
				}
			}

			var frameList:Array<Frame> = timeline.frameList;

			var originTransform:DBTransform = null;
			var originPivot:Point = null;
			var prevFrame:TransformFrame = null;
			var frameListLength:UInt = frameList.length;
			for(j in 0...frameListLength)
			{
				var frame:TransformFrame = cast(frameList[j], TransformFrame);
				setFrameTransform(animationData, armatureData, boneData, frame);

				frame.transform.x -= boneData.transform.x;
				frame.transform.y -= boneData.transform.y;
				frame.transform.skewX -= boneData.transform.skewX;
				frame.transform.skewY -= boneData.transform.skewY;
				frame.transform.scaleX /= boneData.transform.scaleX;
				frame.transform.scaleY /= boneData.transform.scaleY;

				if(timeline.transformed)
				{
					if(slotData != null)
					{
						frame.zOrder -= slotData.zOrder;
					}
				}

				if(originTransform == null)
				{
					originTransform = timeline.originTransform;
					originTransform.copy(frame.transform);
					originTransform.skewX = TransformUtil.formatRadian(originTransform.skewX);
					originTransform.skewY = TransformUtil.formatRadian(originTransform.skewY);
					originPivot = timeline.originPivot;
					originPivot.x = frame.pivot.x;
					originPivot.y = frame.pivot.y;
				}

				frame.transform.x -= originTransform.x;
				frame.transform.y -= originTransform.y;
				frame.transform.skewX = TransformUtil.formatRadian(frame.transform.skewX - originTransform.skewX);
				frame.transform.skewY = TransformUtil.formatRadian(frame.transform.skewY - originTransform.skewY);
				frame.transform.scaleX /= originTransform.scaleX;
				frame.transform.scaleY /= originTransform.scaleY;

				if(timeline.transformed)
				{
					frame.pivot.x -= originPivot.x;
					frame.pivot.y -= originPivot.y;
				}

				if(prevFrame != null)
				{
					var dLX:Float = frame.transform.skewX - prevFrame.transform.skewX;

					if(prevFrame.tweenRotate != 0)
					{

						if(prevFrame.tweenRotate > 0)
						{
							if(dLX < 0)
							{
								frame.transform.skewX += Math.PI * 2;
								frame.transform.skewY += Math.PI * 2;
							}

							if(prevFrame.tweenRotate > 1)
							{
								frame.transform.skewX += Math.PI * 2 * (prevFrame.tweenRotate - 1);
								frame.transform.skewY += Math.PI * 2 * (prevFrame.tweenRotate - 1);
							}
						}
						else
						{
							if(dLX > 0)
							{
								frame.transform.skewX -= Math.PI * 2;
								frame.transform.skewY -= Math.PI * 2;
							}

							if(prevFrame.tweenRotate < 1)
							{
								frame.transform.skewX += Math.PI * 2 * (prevFrame.tweenRotate + 1);
								frame.transform.skewY += Math.PI * 2 * (prevFrame.tweenRotate + 1);
							}
						}
					}
					else
					{
						frame.transform.skewX = prevFrame.transform.skewX + TransformUtil.formatRadian(frame.transform.skewX - prevFrame.transform.skewX);
						frame.transform.skewY = prevFrame.transform.skewY + TransformUtil.formatRadian(frame.transform.skewY - prevFrame.transform.skewY);
					}
				}
				prevFrame = frame;
			}
			timeline.transformed = true;
		}
	}

	private static function setFrameTransform(animationData:AnimationData, armatureData:ArmatureData, boneData:BoneData, frame:TransformFrame):Void
	{
		frame.transform.copy(frame.global);
		var parentData:BoneData = armatureData.getBoneData(boneData.parent);
		if(parentData != null)
		{
			var parentTimeline:TransformTimeline = animationData.getTimeline(parentData.name);
			if(parentTimeline != null)
			{
				var parentTimelineList:Array<TransformTimeline> = new Array<TransformTimeline>();
				var parentDataList:Array<BoneData> = new Array<BoneData>();
				while(parentTimeline != null)
				{
					parentTimelineList.push(parentTimeline);
					parentDataList.push(parentData);
					parentData = armatureData.getBoneData(parentData.parent);
					if(parentData != null)
					{
						parentTimeline = animationData.getTimeline(parentData.name);
					}
					else
					{
						parentTimeline = null;
					}
				}

				var i:Int = parentTimelineList.length;

				//var helpMatrix:Matrix = new Matrix();
				var globalTransform:DBTransform = null;
				var globalTransformMatrix:Matrix = new Matrix();

				var currentTransform:DBTransform = new DBTransform();
				var currentTransformMatrix:Matrix = new Matrix();

				while(i -- > 0)
				{
					parentTimeline = parentTimelineList[i];
					parentData = parentDataList[i];
					getTimelineTransform(parentTimeline, frame.position, currentTransform, globalTransform == null);

					if(globalTransform == null)
					{
						globalTransform = new DBTransform();
						globalTransform.copy(currentTransform);
					}
					else
					{
						currentTransform.x += parentTimeline.originTransform.x + parentData.transform.x;
						currentTransform.y += parentTimeline.originTransform.y + parentData.transform.y;

						currentTransform.skewX += parentTimeline.originTransform.skewX + parentData.transform.skewX;
						currentTransform.skewY += parentTimeline.originTransform.skewY + parentData.transform.skewY;

						currentTransform.scaleX *= parentTimeline.originTransform.scaleX * parentData.transform.scaleX;
						currentTransform.scaleY *= parentTimeline.originTransform.scaleY * parentData.transform.scaleY;

						TransformUtil.transformToMatrix(currentTransform, currentTransformMatrix, true);
						currentTransformMatrix.concat(globalTransformMatrix);
						TransformUtil.matrixToTransform(currentTransformMatrix, globalTransform, currentTransform.scaleX * globalTransform.scaleX >= 0, currentTransform.scaleY * globalTransform.scaleY >= 0);
					}
					TransformUtil.transformToMatrix(globalTransform, globalTransformMatrix, true);
				}
				TransformUtil.globalToLocal(frame.transform, globalTransform);
			}
		}
	}

	private static function getTimelineTransform(timeline:TransformTimeline, position:Int, retult:DBTransform, isGlobal:Bool):Void
	{
		var frameList:Array<Frame> = timeline.frameList;
		var i:Int = frameList.length;

		while(i -- > 0)
		{
			var currentFrame:TransformFrame = cast(frameList[i], TransformFrame);
			if(currentFrame.position <= position && currentFrame.position + currentFrame.duration > position)
			{
				if(i == frameList.length - 1 || position == currentFrame.position)
				{
					retult.copy(isGlobal?currentFrame.global:currentFrame.transform);
				}
				else
				{
					var tweenEasing:Float = currentFrame.tweenEasing;
					var progress:Float = (position - currentFrame.position) / currentFrame.duration;
					if(tweenEasing != 0 && tweenEasing != 10)
					{
						progress = TimelineState.getEaseValue(progress, tweenEasing);
					}
					var nextFrame:TransformFrame = cast(frameList[i + 1], TransformFrame);

					var currentTransform:DBTransform = isGlobal?currentFrame.global:currentFrame.transform;
					var nextTransform:DBTransform = isGlobal?nextFrame.global:nextFrame.transform;

					retult.x = currentTransform.x + (nextTransform.x - currentTransform.x) * progress;
					retult.y = currentTransform.y + (nextTransform.y - currentTransform.y) * progress;
					retult.skewX = TransformUtil.formatRadian(currentTransform.skewX + (nextTransform.skewX - currentTransform.skewX) * progress);
					retult.skewY = TransformUtil.formatRadian(currentTransform.skewY + (nextTransform.skewY - currentTransform.skewY) * progress);
					retult.scaleX = currentTransform.scaleX + (nextTransform.scaleX - currentTransform.scaleX) * progress;
					retult.scaleY = currentTransform.scaleY + (nextTransform.scaleY - currentTransform.scaleY) * progress;
				}
				break;
			}
		}
	}

	public static function addHideTimeline(animationData:AnimationData, armatureData:ArmatureData):Void
	{
		var boneDataList:Array<BoneData> =armatureData.boneDataList;
		var i:Int = boneDataList.length;

		while(i -- > 0)
		{
			var boneData:BoneData = boneDataList[i];
			var boneName:String = boneData.name;
			if(animationData.getTimeline(boneName) == null)
			{
				if(animationData.hideTimelineNameMap.indexOf(boneName) < 0)
				{
					animationData.hideTimelineNameMap.push(boneName);
				}
			}
		}
	}
}
