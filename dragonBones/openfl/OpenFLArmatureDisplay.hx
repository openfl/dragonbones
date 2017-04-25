package dragonBones.openfl;

import haxe.Constraints;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.Vector;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.animation.Animation;
import dragonBones.core.IArmatureDisplay;
import dragonBones.enums.BoundingBoxType;
import dragonBones.events.EventObject;
import dragonBones.objects.BoundingBoxData;


/**
 * @inheritDoc
 */
class OpenFLArmatureDisplay extends Sprite implements IArmatureDisplay
{
	/**
	 * @private
	 */
	@:allow("dragonBones") private var _armature:Armature;
	
	private var _debugDrawer:Sprite;
	/**
	 * @private
	 */
	@:allow("dragonBones") private function new() {}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function _onClear():Void
	{
		_armature = null;
		_debugDrawer = null;
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function _dispatchEvent(type:String, eventObject:EventObject):Void
	{
		var event:FlashEvent = new FlashEvent(type, eventObject);
		dispatchEvent(event);
	}
	/**
	 * @private
	 */
	@:allow("dragonBones") private function _debugDraw(isEnabled:Bool):Void
	{
		if (isEnabled)
		{
			if (_debugDrawer == null) 
			{
				_debugDrawer = new Sprite();
			}
			
			addChild(_debugDrawer);
			_debugDrawer.graphics.clear();
			
			var bones:Vector<Bone> = _armature.getBones();
			var l:UInt = bones.length;
			var bone:Bone, boneLength:Float, startX:Float, startY:Float, endX:Float, endY:Float;
			for (i in 0...l)
			{
				bone = bones[i];
				boneLength = bone.length;
				startX = bone.globalTransformMatrix.tx;
				startY = bone.globalTransformMatrix.ty;
				endX = startX + bone.globalTransformMatrix.a * boneLength;
				endY = startY + bone.globalTransformMatrix.b * boneLength;
				
				_debugDrawer.graphics.lineStyle(2.0, bone.ik ? 0xFF0000 : 0x00FFFF, 0.7);
				_debugDrawer.graphics.moveTo(startX, startY);
				_debugDrawer.graphics.lineTo(endX, endY);
				_debugDrawer.graphics.lineStyle(0.0, 0, 0);
				_debugDrawer.graphics.beginFill(0x00FFFF, 0.7);
				_debugDrawer.graphics.drawCircle(startX, startY, 3.0);
				_debugDrawer.graphics.endFill();
			}
			
			var slots:Vector<Slot> = _armature.getSlots();
			l = slots.length;
			var slot:Slot, boundingBoxData:BoundingBoxData, child:Shape, vertices:Vector<Float>;
			var iA:UInt, lA:UInt;
			for (i in 0...l)
			{
				slot = slots[i];
				boundingBoxData = slot.boundingBoxData;
				
				if (boundingBoxData != null) 
				{
					child = cast(_debugDrawer.getChildByName(slot.name), Shape);
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
						
						case BoundingBoxType.Ellipse:
							child.graphics.drawEllipse(-boundingBoxData.width * 0.5, -boundingBoxData.height * 0.5, boundingBoxData.width, boundingBoxData.height);
						
						case BoundingBoxType.Polygon:
							vertices = boundingBoxData.vertices;
							iA = 0;
							lA = boundingBoxData.vertices.length;
							while (iA < lA)
							{
								if (iA == 0) 
								{
									child.graphics.moveTo(vertices[iA], vertices[iA + 1]);
								}
								else 
								{
									child.graphics.lineTo(vertices[iA], vertices[iA + 1]);
								}
								iA += 2;
							}
						
						default:
					}
					
					child.graphics.endFill();
					slot._updateTransformAndMatrix();
					child.transform.matrix = slot.globalTransformMatrix;
				}
				else
				{
					child = cast (_debugDrawer.getChildByName(slot.name), Shape);
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
	public function armature(get, never):Armature;
	private function get_armature():Armature
	{
		return _armature;
	}
	/**
	 * @inheritDoc
	 */
	public function animation(get, never):Animation;
	private function get_animation():Animation
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