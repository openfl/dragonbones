package dragonBones.flixel;

import haxe.Constraints.Function;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;

import dragonBones.events.EventObject;

class FlixelArmatureGroup extends FlxTypedGroup<FlixelArmatureDisplay> 
{
    public var collider(default, null):FlixelArmatureCollider;
    public var x(get, set):Float;
	public var y(get, set):Float;
    public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;

	public function new(_collider:FlixelArmatureCollider) {
		super();
        this.collider = _collider;
	}

    override public function destroy():Void
	{
	    this.collider = FlxDestroyUtil.destroy(collider);
        this.forEach(function(display:FlixelArmatureDisplay) {
            display.dispose();
            display.destroy();
        });
        super.destroy();
    }

    override public function update(elapsed:Float):Void
	{
        this.forEach(function(display:FlixelArmatureDisplay) {
            display.x = collider.x + collider.offsetX;
            display.y = collider.y + collider.offsetY;
        });
        super.update(elapsed);
    }

    public function updatePosition():Void 
	{
		this.forEach(function(display:FlixelArmatureDisplay) {
            display.updatePosition();
        });
	}

    /**
	 * @private
	 */
	private function _dispatchEvent(type:String, eventObject:EventObject):Void
	{
		var event:FlixelEvent = new FlixelEvent(type, eventObject);
		FlxG.stage.dispatchEvent(event);
	}
    /**
	 * @inheritDoc
	 */
	public function hasEvent(type:String):Bool
	{
		return FlxG.stage.hasEventListener(type);
	}
	/**
	 * @inheritDoc
	 */
	public function addEvent(type:String, listener:Function):Void
	{
		FlxG.stage.addEventListener(type, cast listener);
	}
	/**
	 * @inheritDoc
	 */
	public function removeEvent(type:String, listener:Function):Void
	{
		FlxG.stage.removeEventListener(type, cast listener);
	}

    public function get_x():Float
	{
		return this.members[0].x;
	}
	
	public function get_y():Float
	{
		return this.members[0].y;
	}

    public function set_x(value:Float):Float
	{
        collider.y = value;
		return value;
	}
	
	public function set_y(value:Float):Float
	{
        collider.x = value;
		return value;
	}

    public function get_scaleX():Float
	{
		return this.members[0].scaleX;
	}
	
	public function get_scaleY():Float
	{
		return this.members[0].scaleY;
	}

    public function set_scaleX(value:Float):Float
	{
        this.forEach(function(display:FlixelArmatureDisplay) {
            display.scaleX = value;
        });
		return value;
	}
	
	public function set_scaleY(value:Float):Float
	{
        this.forEach(function(display:FlixelArmatureDisplay) {
            display.scaleY = value;
        });
		return value;
	}
}
