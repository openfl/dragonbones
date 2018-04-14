package dragonBones.flixel;


import openfl.events.Event;

import dragonBones.events.EventObject;

@:final class FlixelEvent extends Event
{
	public var eventObject:EventObject = null;
	
	public function new(type:String, data:EventObject)
	{
		super(type);
		
		eventObject = data;
	}
	
	override public function clone():Event
	{
		var event:FlixelEvent = new FlixelEvent(type, eventObject);
		
		return event;
	}
}