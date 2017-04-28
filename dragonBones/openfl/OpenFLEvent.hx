package dragonBones.openfl;

import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.events.Event;

import dragonBones.events.EventObject;

@:final class OpenFLEvent extends Event
{
	public var eventObject:EventObject<DisplayObject, BitmapData> = null;
	
	public function new(type:String, data:EventObject<DisplayObject, BitmapData>)
	{
		super(type);
		
		eventObject = data;
	}
	
	override public function clone():Event
	{
		var event:OpenFLEvent = new OpenFLEvent(type, eventObject);
		
		return event;
	}
}