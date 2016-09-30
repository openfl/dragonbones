package dragonBones.display;

import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.geom.ColorTransform;

import dragonBones.Slot;


class NativeSlot extends Slot
{
	private var _nativeDisplay:DisplayObject;

	public function new()
	{
		super(this);
		_nativeDisplay = null;
	}

	override public function dispose():Void
	{
		super.dispose();

		_nativeDisplay = null;
	}


	//Abstract method

	/** @private */
	override public function updateDisplay(value:Dynamic):Void
	{
		_nativeDisplay = cast(value, DisplayObject);
	}

	/** @private */
	override public function getDisplayIndex():Int
	{
		if(_nativeDisplay != null && _nativeDisplay.parent != null)
		{
			return _nativeDisplay.parent.getChildIndex(_nativeDisplay);
		}
		return -1;
	}

	/** @private */
	override public function addDisplayToContainer(container:Dynamic, index:Int = -1):Void
	{
		var nativeContainer:DisplayObjectContainer = cast(container, DisplayObjectContainer);
		if(_nativeDisplay != null && nativeContainer != null)
		{
			if (index < 0)
			{
				nativeContainer.addChild(_nativeDisplay);
			}
			else
			{
				nativeContainer.addChildAt(_nativeDisplay, Std.int(Math.min(index, nativeContainer.numChildren)));
			}
		}
	}

	/** @private */
	override public function removeDisplayFromContainer():Void
	{
		if(_nativeDisplay != null && _nativeDisplay.parent != null)
		{
			_nativeDisplay.parent.removeChild(_nativeDisplay);
		}
	}

	/** @private */
	override public function updateTransform():Void
	{
		if(_nativeDisplay != null)
		{
			_nativeDisplay.transform.matrix = this._globalTransformMatrix;
		}
	}

	/** @private */
	override public function updateDisplayVisible(value:Bool):Void
	{
		if(_nativeDisplay != null)
		{
			_nativeDisplay.visible = this._parent.visible && this._visible && value;
		}
	}

	/** @private */
	override public function updateDisplayColor(
		aOffset:Float,
		rOffset:Float,
		gOffset:Float,
		bOffset:Float,
		aMultiplier:Float,
		rMultiplier:Float,
		gMultiplier:Float,
		bMultiplier:Float):Void
	{
		if(_nativeDisplay != null)
		{
			super.updateDisplayColor(aOffset, rOffset, gOffset, bOffset, aMultiplier, rMultiplier, gMultiplier, bMultiplier);
			_nativeDisplay.transform.colorTransform = _colorTransform;
			#if html5
			// fixes alpha change bug in html5
			_nativeDisplay.alpha = aMultiplier;
			#end
		}
	}

	/** @private */
	override public function updateDisplayBlendMode(value:String):Void
	{
		if(_nativeDisplay != null)
		{
			/*switch(blendMode)
			{
				case BlendMode.ADD:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.ALPHA:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.DARKEN:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.DIFFERENCE:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.ERASE:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.HARDLIGHT:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.INVERT:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.LAYER:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.LIGHTEN:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.MULTIPLY:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.NORMAL:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.OVERLAY:
					_nativeDisplay.blendMode = blendMode;
				case BlendMode.SCREEN:
					_nativeDisplay.blendMode = blendMode;
				//case BlendMode.SHADER:
				//	_nativeDisplay.blendMode = blendMode;
				case BlendMode.SUBTRACT:
					_nativeDisplay.blendMode = blendMode;

				default:

			}*/
		}
	}
}
