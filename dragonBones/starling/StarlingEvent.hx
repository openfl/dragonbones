package dragonBones.starling;

import dragonBones.events.EventObject;

import starling.display.DisplayObject;
import starling.events.Event;
import starling.textures.Texture;

@:final class StarlingEvent extends Event
{
	public function new(type:String, data:EventObject<DisplayObject, Texture>)
	{
		super(type, false, data);
	}
	
	public var eventObject(get, never):EventObject<DisplayObject, Texture>;
	private function get_eventObject():EventObject<DisplayObject, Texture>
	{
		return data;
	}
}