package dragonBones.display;

import flash.display.BlendMode;
import flash.geom.Matrix;
import dragonBones.Armature;
import dragonBones.Slot;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;

class StarlingSlot extends Slot
{
    private var _starlingDisplay:DisplayObject;
    
    public var updateMatrix:Bool;
    
    public function new()
    {
        super(this);
        
        _starlingDisplay = null;
        
        updateMatrix = false;
    }
    
    override public function dispose():Void
    {
        for (content in this._displayList)
        {
            if (Std.is(content, Armature))
            {
                cast(content, Armature).dispose();
            }
            else
            {
                if (Std.is(content, DisplayObject))
                {
                    cast(content, DisplayObject).dispose();
                }
            }
        }
        super.dispose();
        
        _starlingDisplay = null;
    }
    
    override public function updateDisplay(value:Dynamic):Void
    {
        _starlingDisplay = cast(value, DisplayObject);
    }
    
    
    //Abstract method
    
    override public function getDisplayIndex():Int
    {
        if (_starlingDisplay != null && _starlingDisplay.parent != null)
        {
            return _starlingDisplay.parent.getChildIndex(_starlingDisplay);
        }
        return -1;
    }
    
    override public function addDisplayToContainer(container:Dynamic, index:Int = -1):Void
    {
        var starlingContainer:DisplayObjectContainer = cast(container, DisplayObjectContainer);
        if (_starlingDisplay != null && starlingContainer != null)
        {
            if (index < 0)
            {
                starlingContainer.addChild(_starlingDisplay);
            }
            else
            {
                starlingContainer.addChildAt(_starlingDisplay, Std.int(Math.min(index, starlingContainer.numChildren)));
            }
        }
    }
    
    override public function removeDisplayFromContainer():Void
    {
        if (_starlingDisplay != null && _starlingDisplay.parent != null)
        {
            _starlingDisplay.parent.removeChild(_starlingDisplay);
        }
    }
    
    override public function updateTransform():Void
    {
        if (_starlingDisplay != null)
        {
            var pivotX:Float = _starlingDisplay.pivotX;
            var pivotY:Float = _starlingDisplay.pivotY;
            
            if (updateMatrix)
            {
                _starlingDisplay.transformationMatrix = _globalTransformMatrix;
                if ((pivotX != 0 && !Math.isNaN(pivotX)) || (pivotY != 0 && !Math.isNaN(pivotY)))
                {
                    _starlingDisplay.pivotX = pivotX;
                    _starlingDisplay.pivotY = pivotY;
                }
            }
            else
            {
                var displayMatrix:Matrix = _starlingDisplay.transformationMatrix;
                displayMatrix.a = _globalTransformMatrix.a;
                displayMatrix.b = _globalTransformMatrix.b;
                displayMatrix.c = _globalTransformMatrix.c;
                displayMatrix.d = _globalTransformMatrix.d;
                //displayMatrix.copyFrom(_globalTransformMatrix);
                if ((pivotX != 0 && !Math.isNaN(pivotX)) || (pivotY != 0 && !Math.isNaN(pivotY)))
                {
                    displayMatrix.tx = _globalTransformMatrix.tx - (displayMatrix.a * pivotX + displayMatrix.c * pivotY);
                    displayMatrix.ty = _globalTransformMatrix.ty - (displayMatrix.b * pivotX + displayMatrix.d * pivotY);
                }
                else
                {
                    displayMatrix.tx = _globalTransformMatrix.tx;
                    displayMatrix.ty = _globalTransformMatrix.ty;
                }
            }
        }
    }
    
    override public function updateDisplayVisible(value:Bool):Void
    {
        if (_starlingDisplay != null && this._parent != null)
        {
            _starlingDisplay.visible = this._parent.visible && this._visible && value;
        }
    }
    
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
        if (_starlingDisplay != null)
        {
            super.updateDisplayColor(aOffset, rOffset, gOffset, bOffset, aMultiplier, rMultiplier, gMultiplier, bMultiplier);
            _starlingDisplay.alpha = aMultiplier;
            if (Std.is(_starlingDisplay, Quad))
            {
               cast(_starlingDisplay, Quad).color = (Std.int(rMultiplier * 0xff) << 16) + (Std.int(gMultiplier * 0xff) << 8) + Std.int(bMultiplier * 0xff);
            }
        }
    }
    
    override public function updateDisplayBlendMode(value:String):Void
    {
        if (_starlingDisplay != null)
        {
            switch (blendMode)
            {
                case starling.display.BlendMode.NONE, starling.display.BlendMode.AUTO, starling.display.BlendMode.ADD, starling.display.BlendMode.ERASE, starling.display.BlendMode.MULTIPLY, starling.display.BlendMode.NORMAL, starling.display.BlendMode.SCREEN:
                    _starlingDisplay.blendMode = blendMode;
                /*
                case flash.display.BlendMode.ADD:
                    _starlingDisplay.blendMode = starling.display.BlendMode.ADD;
                
                case flash.display.BlendMode.ERASE:
                    _starlingDisplay.blendMode = starling.display.BlendMode.ERASE;
                
                case flash.display.BlendMode.MULTIPLY:
                    _starlingDisplay.blendMode = starling.display.BlendMode.MULTIPLY;
                
                case flash.display.BlendMode.NORMAL:
                    _starlingDisplay.blendMode = starling.display.BlendMode.NORMAL;
                
                case flash.display.BlendMode.SCREEN:
                    _starlingDisplay.blendMode = starling.display.BlendMode.SCREEN;
                    */
                case flash.display.BlendMode.ALPHA, flash.display.BlendMode.DARKEN, flash.display.BlendMode.DIFFERENCE, flash.display.BlendMode.HARDLIGHT, flash.display.BlendMode.INVERT, flash.display.BlendMode.LAYER, flash.display.BlendMode.LIGHTEN, flash.display.BlendMode.OVERLAY, flash.display.BlendMode.SHADER, flash.display.BlendMode.SUBTRACT:
                
                default:
            }
        }
    }
}
