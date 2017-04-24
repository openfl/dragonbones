package dragonBones.flash
{
import openfl.events.Event;

import dragonBones.events.EventObject;

public final class FlashEvent extends Event
{
	public var eventObject:EventObject = null;
	
	public function FlashEvent(type:String, data:EventObject)
	{
		super(type);
		
		eventObject = data;
	}
	
	override public function clone():Event
	{
		inline var event:FlashEvent = new FlashEvent(type, eventObject);
		
		return event;
	}
}
}