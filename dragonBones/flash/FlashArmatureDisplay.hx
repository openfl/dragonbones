package dragonBones.flash
{
import openfl.display.Shape;
import openfl.display.Sprite;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.animation.Animation;
import dragonBones.core.IArmatureDisplay;
import dragonBones.core.dragonBones_internal;
import dragonBones.enum.BoundingBoxType;
import dragonBones.events.EventObject;
import dragonBones.objects.BoundingBoxData;


/**
 * @inheritDoc
 */
public class FlashArmatureDisplay extends Sprite implements IArmatureDisplay
{
	/**
	 * @private
	 */
	@:allow("dragonBones") private var _armature:Armature;
	
	private var _debugDrawer:Sprite;
	/**
	 * @private
	 */
	public function FlashArmatureDisplay()
	{
		super();
	}
	/**
	 * @private
	 */
	public function _onClear():Void
	{
		_armature = null;
		_debugDrawer = null;
	}
	/**
	 * @private
	 */
	public function _dispatchEvent(type:String, eventObject:EventObject):Void
	{
		inline var event:FlashEvent = new FlashEvent(type, eventObject);
		dispatchEvent(event);
	}
	/**
	 * @private
	 */
	public function _debugDraw(isEnabled:Bool):Void
	{
		if (isEnabled)
		{
			if (_debugDrawer == null) 
			{
				_debugDrawer = new Sprite();
			}
			
			addChild(_debugDrawer);
			_debugDrawer.graphics.clear();
			
			inline var bones:Vector<Bone> = _armature.getBones();
			var l:UInt = bones.length;
			for (i in 0...l)
			{
				inline var bone:Bone = bones[i];
				inline var boneLength:Float = bone.length;
				inline var startX:Float = bone.globalTransformMatrix.tx;
				inline var startY:Float = bone.globalTransformMatrix.ty;
				inline var endX:Float = startX + bone.globalTransformMatrix.a * boneLength;
				inline var endY:Float = startY + bone.globalTransformMatrix.b * boneLength;
				
				_debugDrawer.graphics.lineStyle(2.0, bone.ik ? 0xFF0000 : 0x00FFFF, 0.7);
				_debugDrawer.graphics.moveTo(startX, startY);
				_debugDrawer.graphics.lineTo(endX, endY);
				_debugDrawer.graphics.lineStyle(0.0, 0, 0);
				_debugDrawer.graphics.beginFill(0x00FFFF, 0.7);
				_debugDrawer.graphics.drawCircle(startX, startY, 3.0);
				_debugDrawer.graphics.endFill();
			}
			
			inline var slots:Vector<Slot> = _armature.getSlots();
			l = slots.length;
			for (i in 0...l)
			{
				inline var slot:Slot = slots[i];
				inline var boundingBoxData:BoundingBoxData = slot.boundingBoxData;
				
				if (boundingBoxData != null) 
				{
					var child:Shape = _debugDrawer.getChildByName(slot.name) as Shape;
					if (child == null) 
					{
						child = new Shape();
						child.name = slot.name;
						_debugDrawer.addChild(child);
					}
					
					child.graphics.clear();
					child.graphics.beginFill(boundingBoxData.color ? boundingBoxData.color : 0xFF00FF, 0.3);
					
					switch (boundingBoxData.type) 
					{
						case BoundingBoxType.Rectangle:
							child.graphics.drawRect(-boundingBoxData.width * 0.5, -boundingBoxData.height * 0.5, boundingBoxData.width, boundingBoxData.height);
							break;
						
						case BoundingBoxType.Ellipse:
							child.graphics.drawEllipse(-boundingBoxData.width * 0.5, -boundingBoxData.height * 0.5, boundingBoxData.width, boundingBoxData.height);
							break;
						
						case BoundingBoxType.Polygon:
							inline var vertices:Vector<Float> = boundingBoxData.vertices;
							for (var iA:UInt = 0, lA:UInt = boundingBoxData.vertices.length; iA < lA; iA += 2) 
							{
								if (iA === 0) 
								{
									child.graphics.moveTo(vertices[iA], vertices[iA + 1]);
								}
								else 
								{
									child.graphics.lineTo(vertices[iA], vertices[iA + 1]);
								}
							}
							break;
						
						default:
						break;
					}
					
					child.graphics.endFill();
					slot._updateTransformAndMatrix();
					child.transform.matrix = slot.globalTransformMatrix;
				}
				else
				{
					child = _debugDrawer.getChildByName(slot.name) as Shape;
					if (child != null) 
					{
						_debugDrawer.removeChild(child);
					}
				}
			}
		}
		else if (_debugDrawer != null && _debugDrawer.parent == this)
		{
			removeChild(_debugDrawer);
		}
	}
	/**
	 * @inheritDoc
	 */
	public function dispose():Void
	{
		if (_armature != null)
		{
			_armature.dispose();
			_armature = null;
		}
	}
	/**
	 * @inheritDoc
	 */
	public function hasEvent(type:String):Bool
	{
		return hasEventListener(type);
	}
	/**
	 * @inheritDoc
	 */
	public function addEvent(type:String, listener:Function):Void
	{
		addEventListener(type, listener);
	}
	/**
	 * @inheritDoc
	 */
	public function removeEvent(type:String, listener:Function):Void
	{
		removeEventListener(type, listener);
	}
	/**
	 * @inheritDoc
	 */
	public function get armature():Armature
	{
		return _armature;
	}
	/**
	 * @inheritDoc
	 */
	public function get animation():Animation
	{
		return _armature.animation;
	}
	
	/**
	 * @deprecated
	 */
	public function advanceTimeBySelf(on:Bool):Void
	{
		if (on)
		{
			_armature.clock = FlashFactory._clock;
		} 
		else 
		{
			_armature.clock = null;
		}
	}
}
}