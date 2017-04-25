package dragonBones.openfl;

import openfl.events.Event;

import dragonBones.events.EventObject;

@:final class OpenFLEvent extends Event
{
	public var eventObject:EventObject = null;
	
	public function new(type:String, data:EventObject)
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