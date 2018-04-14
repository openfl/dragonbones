package dragonBones.starling;

import dragonBones.events.EventObject;

import starling.events.Event;

@:final class StarlingEvent extends Event
{
	public function new(type:String, data:EventObject)
	{
		super(type, false, data);
	}
	
	public var eventObject(get, never):EventObject;
	private function get_eventObject():EventObject
	{
		return cast data;
	}
}